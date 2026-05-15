import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart' show XFile;

class StorageService {
  StorageService({FirebaseStorage? firebaseStorage})
      : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseStorage _firebaseStorage;
  final Random _random = Random();

  // ==========================================
  // 1. UPLOAD 1 ẢNH (BẰNG FILE)
  // ==========================================
  Future<String?> uploadSingleImage(File file, String folderPath) async {
    try {
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}.jpg';
      final ref = _firebaseStorage.ref().child('$folderPath/$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      log('Lỗi upload ảnh: $e');
      return null;
    }
  }

  // ==========================================
  // 2. UPLOAD 1 ẢNH (BẰNG MẢNG BYTE)
  // Chống móm cho các trường hợp lỗi đường dẫn Android/Web
  // ==========================================
  Future<String?> uploadJpegBytes(Uint8List bytes, String folderPath) async {
    try {
      if (bytes.isEmpty) return null;
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}.jpg';
      final ref = _firebaseStorage.ref().child('$folderPath/$fileName');
      
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      log('Lỗi upload ảnh (bytes): $e');
      return null;
    }
  }

  // ==========================================
  // 3. UPLOAD NHIỀU ẢNH THEO CỤM (SIÊU NHANH)
  // ==========================================
  Future<List<String>> uploadMultipleImagesBatched({
    required List<File> imageFiles,
    required String folderPath,
    int batchSize = 5,
  }) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < imageFiles.length; i += batchSize) {
      final chunk = imageFiles.skip(i).take(batchSize).toList();
      final urls = await Future.wait(
        chunk.map((file) => uploadSingleImage(file, folderPath)),
      );
      downloadUrls.addAll(urls.whereType<String>());
    }

    return downloadUrls;
  }

  // ==========================================
  // 4. XỬ LÝ HỖN HỢP: LINK MẠNG + FILE LOCAL
  // (Đỉnh cao cho chức năng Cập nhật/Chỉnh sửa)
  // ==========================================
  Future<List<String>> uploadMixedPaths({
    required List<String> pathsOrUrls,
    required String folderPath,
    Map<String, String>? localPathDedupeCache,
  }) async {
    final result = <String>[];
    for (final raw in pathsOrUrls) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      
      final lower = trimmed.toLowerCase();
      if (lower.startsWith('http://') || lower.startsWith('https://')) {
        result.add(trimmed);
        continue;
      }

      final cache = localPathDedupeCache;
      if (cache != null && cache.containsKey(trimmed)) {
        result.add(cache[trimmed]!);
        continue;
      }

      final file = File(trimmed);
      if (await file.exists()) {
        final url = await uploadSingleImage(file, folderPath);
        if (url != null) {
          result.add(url);
          cache?[trimmed] = url;
        }
        continue;
      }
      
      try {
        final bytes = await XFile(trimmed).readAsBytes();
        final url = await uploadJpegBytes(bytes, folderPath);
        if (url != null) {
          result.add(url);
          cache?[trimmed] = url;
        }
      } catch (e) {
        log('Không upload được ảnh local ($trimmed): $e');
      }
    }
    return result;
  }

  // ==========================================
  // 5. XÓA ẢNH TRÊN FIREBASE THEO LINK DOWNLAD
  // ==========================================
  bool _looksLikeFirebaseStorageDownloadUrl(String url) {
    final u = url.trim().toLowerCase();
    return u.contains('firebasestorage.googleapis.com') ||
        u.contains('firebasestorage.app');
  }

  Future<void> deleteDownloadUrlIfFirebaseStorage(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty || !_looksLikeFirebaseStorageDownloadUrl(trimmed)) {
      return;
    }
    try {
      await _firebaseStorage.refFromURL(trimmed).delete();
      log('Đã xóa ảnh trên Firebase Storage: $trimmed');
    } catch (e) {
      log('Bỏ qua xóa ảnh Storage: $e');
    }
  }

  /// Xóa mọi file avatar cũ trong [folderPath] trừ file có [keepDownloadUrl].
  Future<void> deleteStorageFilesExcept({
    required String folderPath,
    required String keepDownloadUrl,
  }) async {
    final keep = keepDownloadUrl.trim();
    if (keep.isEmpty) {
      return;
    }

    try {
      final folderRef = _firebaseStorage.ref().child(folderPath);
      final listing = await folderRef.listAll();
      for (final item in listing.items) {
        try {
          final itemUrl = await item.getDownloadURL();
          if (itemUrl.trim() == keep) {
            continue;
          }
          await item.delete();
          log('Đã xóa avatar cũ trên Storage: $itemUrl');
        } catch (e) {
          log('Bỏ qua xóa file trong $folderPath: $e');
        }
      }
    } catch (e) {
      log('Không liệt kê được folder Storage $folderPath: $e');
    }
  }

  // ==========================================
  // 6. ĐỒNG BỘ DỌN RÁC (COMPARE VÀ XÓA)
  // ==========================================
  Future<void> syncDeletedFirebaseImages({
    required Iterable<String> previousUrls,
    required Iterable<String> nextUrls,
  }) async {
    final nextSet =
        nextUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
        
    for (final prev in previousUrls) {
      final p = prev.trim();
      if (p.isEmpty || nextSet.contains(p)) continue;
      await deleteDownloadUrlIfFirebaseStorage(p);
    }
  }
}