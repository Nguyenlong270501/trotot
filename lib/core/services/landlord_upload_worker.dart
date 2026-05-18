import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'storage_service.dart';

class LandlordUploadWorker {
  static const String boxName = 'landlord_upload_queue';

  static Future<void> saveDraftToQueue({
    required String uid,
    required String fullName,
    required String phone,
    required String address,
    required List<int> numOfRoomsList,
    required String cccdFrontPath,
    required String cccdBackPath,
    required List<String> optionalDocPaths,
  }) async {
    final box = await Hive.openBox(boxName);

    final appDir = await getApplicationDocumentsDirectory();
    final safeDir = Directory('${appDir.path}/pending_landlord');
    if (!await safeDir.exists()) await safeDir.create(recursive: true);

    Future<String> moveToSafeZone(String originalPath) async {
      if (originalPath.startsWith('http')) return originalPath;

      final file = File(originalPath);
      if (!await file.exists()) return originalPath;

      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${p.basename(originalPath)}';
      final safePath = '${safeDir.path}/$fileName';
      await file.copy(safePath);
      return safePath;
    }

    final safeFront = await moveToSafeZone(cccdFrontPath);
    final safeBack = await moveToSafeZone(cccdBackPath);
    final safeDocs = await Future.wait(
      optionalDocPaths.map((path) => moveToSafeZone(path)),
    );

    final draft = <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'numOfRoomsList': numOfRoomsList,
      'cccdFrontPath': safeFront,
      'cccdBackPath': safeBack,
      'optionalDocPaths': safeDocs,
      'queuedAt': DateTime.now().toIso8601String(),
    };

    await box.add(draft);
    log('[LandlordUploadWorker] Đã thêm vào hàng đợi (${box.length} đơn chờ)');
  }

  static Future<void> checkAndUploadDraft({void Function()? onSuccess}) async {
    final box = await Hive.openBox(boxName);

    if (box.isEmpty) {
      log('[LandlordUploadWorker] Queue rỗng.');
      return;
    }

    log('[LandlordUploadWorker] Phát hiện ${box.length} đơn chờ!');

    final storageService = StorageService();
    final firestore = FirebaseFirestore.instance;
    final keys = box.keys.toList();

    for (final key in keys) {
      try {
        final draft = Map<String, dynamic>.from(box.get(key));
        final uid = draft['uid'] as String;

        final folderPath = 'landlord_requests/$uid';

        final frontUrl = await _uploadLocalFile(
          storageService,
          draft['cccdFrontPath'] as String,
          folderPath,
        );
        if (frontUrl == null) throw Exception('Lỗi upload CCCD mặt trước');

        final backUrl = await _uploadLocalFile(
          storageService,
          draft['cccdBackPath'] as String,
          folderPath,
        );
        if (backUrl == null) throw Exception('Lỗi upload CCCD mặt sau');

        final optionalPaths = List<String>.from(
          draft['optionalDocPaths'] ?? [],
        );
        final optionalUrls = <String>[];
        for (final path in optionalPaths) {
          final url = await _uploadLocalFile(storageService, path, folderPath);
          if (url != null) optionalUrls.add(url);
        }

        final docRef = firestore.collection('landlord_requests').doc(uid);
        final existing = await docRef.get();

        final data = <String, dynamic>{
          'userId': uid,
          'fullName': (draft['fullName'] as String).trim(),
          'phone': (draft['phone'] as String).trim(),
          'address': (draft['address'] as String).trim(),
          'numOfRoomsList': List<int>.from(draft['numOfRoomsList'] ?? []),
          'cccdFrontUrl': frontUrl,
          'cccdBackUrl': backUrl,
          'optionalDocumentUrls': optionalUrls,
          'status': 'pending',
          'rejectionReason': '',
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (!existing.exists) {
          data['createdAt'] = FieldValue.serverTimestamp();
        }

        await docRef.set(data, SetOptions(merge: true));

        _cleanupSafeFiles([
          draft['cccdFrontPath'] as String,
          draft['cccdBackPath'] as String,
          ...optionalPaths,
        ]);

        await box.delete(key);
        log('[LandlordUploadWorker] Upload thành công đơn của $uid!');
        onSuccess?.call();
      } catch (e) {
        log('[LandlordUploadWorker] Lỗi upload đơn $key: $e');
        continue;
      }
    }
  }

  static Future<String?> _uploadLocalFile(
    StorageService storageService,
    String path,
    String folderPath,
  ) async {
    if (path.startsWith('http')) return path;

    final file = File(path);
    if (await file.exists()) {
      return storageService.uploadSingleImage(file, folderPath);
    }
    return null;
  }

  static void _cleanupSafeFiles(List<String> paths) {
    for (final path in paths) {
      try {
        final file = File(path);
        if (file.existsSync() && path.contains('pending_landlord')) {
          file.deleteSync();
        }
      } catch (_) {}
    }
  }
}
