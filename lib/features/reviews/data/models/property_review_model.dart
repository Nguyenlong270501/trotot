import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyReviewModel {
  const PropertyReviewModel({
    required this.reviewId,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String reviewId;
  final String propertyId;
  final String userId;
  final String userName;
  final int rating;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyReviewModel copyWith({
    String? reviewId,
    String? propertyId,
    String? userId,
    String? userName,
    int? rating,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyReviewModel(
      reviewId: reviewId ?? this.reviewId,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PropertyReviewModel.fromMap(
    Map<String, dynamic> map, {
    required String reviewId,
  }) {
    return PropertyReviewModel(
      reviewId: reviewId,
      propertyId: (map['propertyId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? '').toString(),
      rating: (map['rating'] ?? 0).toInt(),
      content: (map['content'] ?? '').toString(),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}