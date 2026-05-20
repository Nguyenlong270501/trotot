import '../models/property_review_model.dart';

abstract class ReviewsRepository {
  Stream<List<PropertyReviewModel>> watchReviews({
    required String propertyId,
    int limit,
  });

  Stream<PropertyReviewModel?> watchCurrentUserReview({
    required String propertyId,
    required String userId,
  });

  Future<void> upsertReview({
    required String propertyId,
    required String userId,
    required String userName,
    required String? avatarUrl,
    required int rating,
    required String content,
  });

  Future<void> deleteReview({
    required String propertyId,
    required String userId,
  });
}
