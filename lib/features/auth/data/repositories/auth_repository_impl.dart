import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final FirebaseAuthDataSource _remoteDataSource;

  @override
  Future<Either<String, UserModel>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteDataSource.loginWithEmail(email, password);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseError(e, fallback: 'Lỗi đăng nhập'));
    } catch (_) {
      return const Left('Đăng nhập thất bại');
    }
  }

  @override
  Future<Either<String, UserModel>> signUpWithEmail(
    String email,
    String password,
    String userName,
  ) async {
    try {
      final user = await _remoteDataSource.signUpWithEmail(
        email,
        password,
        userName,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseError(e, fallback: 'Đăng ký thất bại'));
    } catch (_) {
      return const Left('Đăng ký thất bại');
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Right(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Left('Google login cancelled');
      }
      return const Left('Google login failed');
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseError(e, fallback: 'Đăng nhập Google thất bại'));
    } catch (_) {
      return const Left('Đăng nhập Google thất bại');
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithFacebook() async {
    try {
      final user = await _remoteDataSource.signInWithFacebook();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(
        _mapFirebaseError(e, fallback: 'Đăng nhập Facebook thất bại'),
      );
    } catch (e) {
      if (e.toString().contains('facebook-cancelled')) {
        return const Left('Facebook login cancelled');
      }
      return const Left('Facebook login failed');
    }
  }

  @override
  Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
        _mapFirebaseError(e, fallback: 'Không thể gửi email đặt lại mật khẩu'),
      );
    } catch (_) {
      return const Left('Không thể gửi email đặt lại mật khẩu');
    }
  }

  @override
  Stream<UserModel?> watchCurrentUserData(String userId) {
    return _remoteDataSource.watchCurrentUserData(userId);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<Either<String, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseError(e, fallback: 'Không thể đổi mật khẩu'));
    } catch (_) {
      return const Left('Không thể đổi mật khẩu');
    }
  }

  String _mapFirebaseError(
    FirebaseAuthException e, {
    required String fallback,
  }) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      case 'email-already-in-use':
        return 'Email đã được đăng ký';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập không được bật';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã được đăng ký bằng phương thức khác';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ hoặc đã hết hạn';
      default:
        return e.message ?? fallback;
    }
  }
}
