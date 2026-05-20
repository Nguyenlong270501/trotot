import '../datasources/reviews_remote_data_source.dart';
import '../models/property_review_model.dart';
import 'reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  ReviewsRepositoryImpl(this._remoteDataSource);

  final ReviewsRemoteDataSource _remoteDataSource;

  @override
  Stream<List<PropertyReviewModel>> watchReviews({
    required String propertyId,
    int limit = 20,
  }) {
    return _remoteDataSource.watchReviews(propertyId: propertyId, limit: limit);
  }

  @override
  Stream<PropertyReviewModel?> watchCurrentUserReview({
    required String propertyId,
    required String userId,
  }) {
    return _remoteDataSource.watchCurrentUserReview(
      propertyId: propertyId,
      userId: userId,
    );
  }

  @override
  Future<void> upsertReview({
    required String propertyId,
    required String userId,
    required String userName,
    required String? avatarUrl,
    required int rating,
    required String content,
  }) {
    return _remoteDataSource.upsertReview(
      propertyId: propertyId,
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
      rating: rating,
      content: content,
    );
  }

  @override
  Future<void> deleteReview({
    required String propertyId,
    required String userId,
  }) {
    return _remoteDataSource.deleteReview(propertyId: propertyId, userId: userId);
  }
}
