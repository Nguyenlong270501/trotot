import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/storage_service.dart';

class ProfileImageRepository {
  ProfileImageRepository({
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

  Future<XFile?> pickImageFromGallery() {
    return _imagePickerService.pickImageFromGallery(
      imageQuality: 50,
      maxWidth: 500,
      maxHeight: 500,
    );
  }

  Future<String> cachePickedAvatar(XFile file) async {
    final source = File(file.path);
    if (!await source.exists()) {
      throw Exception('Không đọc được ảnh đã chọn');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/pending_avatar');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${p.basename(file.path)}';
    final cachedPath = '${cacheDir.path}/$fileName';
    await source.copy(cachedPath);
    return cachedPath;
  }

  Future<String> uploadAvatarFromLocalPath(
    String localPath, {
    String? previousAvatarUrl,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final file = File(localPath);
    if (!await file.exists()) {
      throw Exception('Ảnh tạm không tồn tại, vui lòng chọn lại');
    }

    final uid = currentUser.uid;
    final avatarFolder = 'users/avatars/$uid';

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final firestoreAvatarUrl =
        (userDoc.data()?['avatarUrl'] as String?)?.trim() ?? '';
    final passedPreviousUrl = previousAvatarUrl?.trim() ?? '';
    final oldAvatarUrl = firestoreAvatarUrl.isNotEmpty
        ? firestoreAvatarUrl
        : passedPreviousUrl;

    final newAvatarUrl = await _storageService.uploadSingleImage(
      file,
      avatarFolder,
    );

    if (newAvatarUrl == null) {
      throw Exception('Không thể upload ảnh, vui lòng thử lại!');
    }

    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': newAvatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final trimmedNewUrl = newAvatarUrl.trim();
    if (oldAvatarUrl.isNotEmpty && oldAvatarUrl != trimmedNewUrl) {
      await _storageService.deleteDownloadUrlIfFirebaseStorage(oldAvatarUrl);
    }

    await _storageService.deleteStorageFilesExcept(
      folderPath: avatarFolder,
      keepDownloadUrl: trimmedNewUrl,
    );

    return trimmedNewUrl;
  }

  Future<void> updateProfileInfo({
    required String userName,
    required String phoneNumber,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    await _firestore.collection('users').doc(currentUser.uid).update({
      'userName': userName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
