import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_enums.dart' as app_enums;
import '../models/user.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  bool _isGoogleInitialized = false;

  Future<UserModel> loginWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    return _getUserData(user.uid);
  }

  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String userName,
  ) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'operation-not-allowed');
    }

    await saveUserData(
      UserModel(
        userId: user.uid,
        email: email,
        userName: userName,
        phoneNumber: user.phoneNumber ?? '',
        avatarUrl: '',
        authProvider: app_enums.AuthProvider.email,
        isLandlord: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return _getUserData(user.uid);
  }

  Future<UserModel> signInWithGoogle() async {
    await _initGoogleSignIn();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;

    final authorization = await googleUser.authorizationClient
        .authorizationForScopes(['email', 'profile']);

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authorization?.accessToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await saveUserData(
        UserModel(
          userId: user.uid,
          email: user.email ?? '',
          userName: user.displayName ?? 'User',
          phoneNumber: user.phoneNumber ?? '',
          avatarUrl: user.photoURL ?? '',
          isLandlord: false,
          authProvider: app_enums.AuthProvider.google,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return _getUserData(user.uid);
  }

  Future<UserModel> signInWithFacebook() async {
    final loginResult = await FacebookAuth.instance.login();
    if (loginResult.status == LoginStatus.cancelled) {
      throw Exception('facebook-cancelled');
    }
    if (loginResult.status != LoginStatus.success) {
      throw Exception('facebook-failed');
    }

    final token = loginResult.accessToken?.tokenString;
    if (token == null || token.isEmpty) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final credential = FacebookAuthProvider.credential(token);
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await saveUserData(
        UserModel(
          userId: user.uid,
          email: user.email ?? '',
          userName: user.displayName ?? 'User',
          phoneNumber: user.phoneNumber ?? '',
          avatarUrl: user.photoURL ?? '',
          authProvider: app_enums.AuthProvider.facebook,
          isLandlord: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return _getUserData(user.uid);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> saveUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toMap());
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      return await _getUserData(firebaseUser.uid);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> _getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('user-data-not-found');
    }
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> _initGoogleSignIn() async {
    if (_isGoogleInitialized) {
      return;
    }

    await _googleSignIn.initialize(
      serverClientId:
        '1012146705116-ov659bo6stbcmdc0fri3vkh7ese7jr2l.apps.googleusercontent.com',
    );
    _isGoogleInitialized = true;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Stream<UserModel?> watchCurrentUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }
}
