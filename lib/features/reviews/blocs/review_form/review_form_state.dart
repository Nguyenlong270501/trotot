import 'package:equatable/equatable.dart';

import '../../data/models/property_review_model.dart';

final class ReviewFormState extends Equatable {
  const ReviewFormState({
    this.isLoading = false,
    this.currentUserReview,
    this.draftRating = 5,
    this.draftContent = '',
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final PropertyReviewModel? currentUserReview;
  final int draftRating;
  final String draftContent;
  final String? errorMessage;
  final String? successMessage;

  ReviewFormState copyWith({
    bool? isLoading,
    PropertyReviewModel? currentUserReview,
    bool clearCurrentReview = false,
    int? draftRating,
    String? draftContent,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ReviewFormState(
      isLoading: isLoading ?? this.isLoading,
      currentUserReview: clearCurrentReview
          ? null
          : (currentUserReview ?? this.currentUserReview),
      draftRating: draftRating ?? this.draftRating,
      draftContent: draftContent ?? this.draftContent,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentUserReview,
    draftRating,
    draftContent,
    errorMessage,
    successMessage,
  ];
}
