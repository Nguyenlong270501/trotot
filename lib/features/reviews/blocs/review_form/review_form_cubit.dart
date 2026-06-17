import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/property_review_model.dart';
import '../../data/repositories/reviews_repository.dart';
import 'review_form_state.dart';

class ReviewFormCubit extends Cubit<ReviewFormState> {
  ReviewFormCubit(this._repository) : super(const ReviewFormState());

  final ReviewsRepository _repository;
  StreamSubscription? _subscription;

  void watchCurrentUserReview({
    required String propertyId,
    required String userId,
  }) {
    final normalizedPropertyId = propertyId.trim();
    final normalizedUserId = userId.trim();
    if (normalizedPropertyId.isEmpty || normalizedUserId.isEmpty) {
      emit(
        state.copyWith(
          clearCurrentReview: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
      return;
    }
    _subscription?.cancel();
    _subscription = _repository
        .watchCurrentUserReview(
          propertyId: normalizedPropertyId,
          userId: normalizedUserId,
        )
        .listen(
          (review) => emit(
            state.copyWith(
              currentUserReview: review,
              clearError: true,
              clearSuccess: true,
            ),
          ),
          onError: (error) => emit(
            state.copyWith(errorMessage: error.toString(), clearSuccess: true),
          ),
        );
  }

  Future<void> upsertReview({
    required String propertyId,
    required String userId,
    required String userName,
    required String? avatarUrl,
    required int rating,
    required String content,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _repository.upsertReview(
        propertyId: propertyId,
        userId: userId,
        userName: userName,
        avatarUrl: avatarUrl,
        rating: rating,
        content: content,
      );
      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Đã lưu đánh giá của bạn',
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  void hydrateDraft(PropertyReviewModel? review) {
    emit(
      state.copyWith(
        draftRating: review?.rating ?? 5,
        draftContent: review?.content ?? '',
      ),
    );
  }

  void setDraftRating(int rating) {
    emit(state.copyWith(draftRating: rating));
  }

  void setDraftContent(String content) {
    emit(state.copyWith(draftContent: content));
  }

  Future<void> deleteReview({
    required String propertyId,
    required String userId,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _repository.deleteReview(propertyId: propertyId, userId: userId);
      emit(
        state.copyWith(
          isLoading: false,
          clearCurrentReview: true,
          successMessage: 'Đã xóa đánh giá',
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  void clearFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
