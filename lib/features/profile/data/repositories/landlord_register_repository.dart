import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/landlord_request.dart';

class LandlordRegisterRepository {
  LandlordRegisterRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    ImagePickerService? imagePickerService,
    StorageService? storageService,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _imagePickerService = imagePickerService ?? ImagePickerService(),
       _storageService = storageService ?? StorageService();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final ImagePickerService _imagePickerService;
  final StorageService _storageService;

  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  Future<XFile?> pickImageFromGallery() {
    return _imagePickerService.pickImageFromGallery(
      imageQuality: 70,
      maxWidth: 1280,
    );
  }

  Future<void> submitRequest({
    required String fullName,
    required String phone,
    required String address,
    required List<int> numOfRoomsList,
    required File cccdFrontFile,
    required File cccdBackFile,
    required List<File> optionalFiles,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Bạn chưa đăng nhập');
    }
    final uid = user.uid;

    final folderPath = 'landlord_requests/$uid';

    final frontUrl = await _storageService.uploadSingleImage(
      cccdFrontFile,
      folderPath,
    );
    if (frontUrl == null) throw Exception('Lỗi upload CCCD mặt trước');

    final backUrl = await _storageService.uploadSingleImage(
      cccdBackFile,
      folderPath,
    );
    if (backUrl == null) throw Exception('Lỗi upload CCCD mặt sau');

    List<String> optionalUrls = [];
    if (optionalFiles.isNotEmpty) {
      optionalUrls = await _storageService.uploadMultipleImagesBatched(
        imageFiles: optionalFiles,
        folderPath: folderPath,
      );
    }

    final request = LandlordRequest(
      userId: uid,
      fullName: fullName.trim(),
      phone: phone.trim(),
      address: address.trim(),
      numOfRoomsList: numOfRoomsList,
      cccdFrontUrl: frontUrl,
      cccdBackUrl: backUrl,
      optionalDocumentUrls: optionalUrls,
      rejectionReason: '',
      status: LandlordRequestStatus.pending,
    );

    final docRef = _firestore.collection('landlord_requests').doc(uid);
    final existing = await docRef.get();

    final data = request.toFirestoreMap();
    data['updatedAt'] = FieldValue.serverTimestamp();

    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(data, SetOptions(merge: true));
  }

  Future<List<XFile>> pickMultipleImages() async {
    return await _imagePickerService.pickMultipleImages(
      imageQuality: 70,
      maxWidth: 1280,
    );
  }

  Stream<LandlordRequest?> watchCurrentUserRequest() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('landlord_requests')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) {
            return null;
          }
          return LandlordRequest.fromFirestore(doc.data()!);
        });
  }
}
