import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/property_review_model.dart';
import 'reviews_remote_data_source.dart';

class FirebaseReviewsRemoteDataSource implements ReviewsRemoteDataSource {
  FirebaseReviewsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _propertiesRef =>
      _firestore.collection('properties');

  CollectionReference<Map<String, dynamic>> _reviewsRef(String propertyId) =>
      _propertiesRef.doc(propertyId).collection('reviews');

  @override
  Stream<List<PropertyReviewModel>> watchReviews({
    required String propertyId,
    int limit = 20,
  }) {
    return _reviewsRef(propertyId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    PropertyReviewModel.fromMap(doc.data(), reviewId: doc.id),
              )
              .toList(),
        );
  }

  @override
  Stream<PropertyReviewModel?> watchCurrentUserReview({
    required String propertyId,
    required String userId,
  }) {
    return _reviewsRef(propertyId).doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return PropertyReviewModel.fromMap(
        snapshot.data() ?? <String, dynamic>{},
        reviewId: snapshot.id,
      );
    });
  }

  @override
  Future<void> upsertReview({
    required String propertyId,
    required String userId,
    required String userName,
    required int rating,
    required String content,
  }) async {
    final reviewRef = _reviewsRef(propertyId).doc(userId);
    final current = await reviewRef.get();
    await reviewRef.set({
      'propertyId': propertyId.trim(),
      'userId': userId.trim(),
      'userName': userName.trim(),
      'rating': rating,
      'content': content.trim(),
      'createdAt': current.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteReview({
    required String propertyId,
    required String userId,
  }) async {
    await _reviewsRef(propertyId).doc(userId).delete();
  }
}