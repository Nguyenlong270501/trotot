import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/property_helper.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_model.dart';

class FavoritePropertyModel {
  const FavoritePropertyModel({
    required this.propertyId,
    required this.title,
    required this.address,
    required this.createdAt,
    required this.previewImageUrls,
    this.favoritedAt,
    this.previewRoomId,
  });

  final String propertyId;
  final String title;
  final String address;
  final DateTime createdAt;
  final List<String> previewImageUrls;
  final DateTime? favoritedAt;

  /// Phòng đang xem khi lưu yêu thích (để mở lại đúng phòng từ tab yêu thích).
  final String? previewRoomId;

  factory FavoritePropertyModel.fromProperty(
    PropertyModel property, {
    RoomModel? previewRoom,
  }) {
    List<String> preview;
    if (previewRoom != null && previewRoom.imageUrls.isNotEmpty) {
      preview = List<String>.from(previewRoom.imageUrls);
    } else if ((property.rooms?.isNotEmpty ?? false) &&
        property.rooms!.first.imageUrls.isNotEmpty) {
      preview = List<String>.from(property.rooms!.first.imageUrls);
    } else {
      preview = const <String>[];
    }
    final roomId = previewRoom?.roomId.trim() ?? '';
    return FavoritePropertyModel(
      propertyId: property.propertyId,
      title: property.title,
      address: PropertyHelper.propertyLocationSubtitle(property),
      createdAt: property.createdAt,
      previewImageUrls: preview,
      previewRoomId: roomId.isEmpty ? null : roomId,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'propertyId': propertyId,
      'title': title,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'previewImageUrls': previewImageUrls,
      'favoritedAt': FieldValue.serverTimestamp(),
    };
    final roomId = previewRoomId?.trim();
    if (roomId != null && roomId.isNotEmpty) {
      map['previewRoomId'] = roomId;
    }
    return map;
  }

  factory FavoritePropertyModel.fromMap(Map<String, dynamic> map) {
    return FavoritePropertyModel(
      propertyId: (map['propertyId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      createdAt: _parseDateTime(map['createdAt']),
      previewImageUrls: _parsePreviewImageUrls(map),
      favoritedAt: _parseNullableDateTime(map['favoritedAt']),
      previewRoomId: _parsePreviewRoomId(map),
    );
  }

  static String? _parsePreviewRoomId(Map<String, dynamic> map) {
    final s = (map['previewRoomId'] ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  static List<String> _parsePreviewImageUrls(Map<String, dynamic> map) {
    final rawList = map['previewImageUrls'];
    if (rawList is List) {
      return rawList
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Backward compatibility with old schema previewImageUrl: String
    final rawSingle = (map['previewImageUrl'] ?? '').toString().trim();
    if (rawSingle.isNotEmpty) {
      return [rawSingle];
    }
    return const <String>[];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
