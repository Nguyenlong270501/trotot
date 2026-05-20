import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_style.dart';
import '../../../core/utils/property_helper.dart';
import '../../../core/widgets/app_alerts.dart';
import '../../home/data/models/property_model.dart';
import '../../profile/presentation/screens/landlord_register/section_card.dart';
import '../data/models/property_review_model.dart';
import '../data/repositories/reviews_repository.dart';
import '../blocs/review_form/review_form_cubit.dart';
import '../blocs/review_form/review_form_state.dart';
import 'review_editor_dialog.dart';

class PropertyReviewsSection extends StatelessWidget {
  const PropertyReviewsSection({
    super.key,
    required this.property,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserAvatarUrl,
    required this.reviews,
    required this.currentUserReview,
  });

  final PropertyModel property;
  final String currentUserId;
  final String currentUserName;
  final String? currentUserAvatarUrl;
  final List<PropertyReviewModel> reviews;
  final PropertyReviewModel? currentUserReview;

  bool get _isPropertyOwner =>
      currentUserId.isNotEmpty && currentUserId == property.landlordId.trim();

  bool get _canWriteOrEditReview =>
      currentUserId.isNotEmpty && !_isPropertyOwner;

  Future<void> _openReviewEditor(BuildContext context) async {
    final cubit = context.read<ReviewFormCubit>();
    cubit.hydrateDraft(currentUserReview);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: ReviewEditorDialog(
          property: property,
          currentUserId: currentUserId,
          currentUserName: currentUserName,
          currentUserAvatarUrl: currentUserAvatarUrl,
          existingReview: currentUserReview,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewFormCubit(context.read<ReviewsRepository>()),
      child: BlocListener<ReviewFormCubit, ReviewFormState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          final error = state.errorMessage;
          if (error != null && error.isNotEmpty) {
            Alerts.of(context).showError(error);
            context.read<ReviewFormCubit>().clearFeedback();
            return;
          }
          final success = state.successMessage;
          if (success != null && success.isNotEmpty) {
            Alerts.of(context).showSuccess(success);
            context.read<ReviewFormCubit>().clearFeedback();
          }
        },
        child: Builder(builder: (innerContext) => _buildContent(innerContext)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final total = reviews.isNotEmpty ? reviews.length : property.totalReviews;
    final average = reviews.isNotEmpty
        ? reviews.fold<int>(0, (sum, item) => sum + item.rating) /
              reviews.length
        : property.ratingAverage;
    final distribution = reviews.isNotEmpty
        ? _distributionFromReviews(reviews)
        : _normalizeDistribution(property.ratingDistribution);

    return SectionCard(
      title: 'Đánh giá ($total)',
      trailing: Row(
        children: [
          Icon(Icons.star_rounded, color: AppColors.starColor, size: 20.sp),
          AppSizes.gapW4,
          Text(
            average.toStringAsFixed(1),
            style: AppTypography.bold16(color: AppColors.textPrimary),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final star in [5, 4, 3, 2, 1]) ...[
            _buildRatingBar(star, distribution['$star'] ?? 0, total),
            if (star != 1) AppSizes.gapH8,
          ],
          AppSizes.gapH14,
          _buildReviewAction(context),
          AppSizes.gapH16,
          if (reviews.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'Chưa có đánh giá nào.',
                style: AppTypography.medium14(color: AppColors.textMuted),
              ),
            )
          else
            ...reviews.map((review) => _buildReviewItem(context, review)),
        ],
      ),
    );
  }

  Widget _buildReviewAction(BuildContext context) {
    if (!_canWriteOrEditReview) {
      if (_isPropertyOwner) {
        return Text(
          'Chủ trọ không thể đánh giá bài đăng của mình.',
          style: AppTypography.medium12(color: AppColors.textMuted),
        );
      }
      return const SizedBox.shrink();
    }

    final hasReview = currentUserReview != null;
    return Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.icon(
        onPressed: () => _openReviewEditor(context),
        icon: Icon(
          hasReview ? Icons.edit_outlined : Icons.rate_review_outlined,
          size: 18.sp,
        ),
        label: Text(hasReview ? 'Sửa đánh giá' : 'Viết đánh giá'),
      ),
    );
  }

  Map<String, int> _normalizeDistribution(Map<String, int> distribution) {
    return <String, int>{
      '1': distribution['1'] ?? 0,
      '2': distribution['2'] ?? 0,
      '3': distribution['3'] ?? 0,
      '4': distribution['4'] ?? 0,
      '5': distribution['5'] ?? 0,
    };
  }

  Map<String, int> _distributionFromReviews(List<PropertyReviewModel> reviews) {
    final result = <String, int>{'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};
    for (final review in reviews) {
      final key = review.rating.toString();
      if (!result.containsKey(key)) {
        continue;
      }
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }

  Widget _buildRatingBar(int star, int count, int total) {
    final percent = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        Text(
          star.toString(),
          style: AppTypography.medium14(color: AppColors.textPrimary),
        ),
        AppSizes.gapW8,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6.h,
              backgroundColor: AppColors.border.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.starColor,
              ),
            ),
          ),
        ),
        AppSizes.gapW12,
        SizedBox(
          width: 28.w,
          child: Text(
            count.toString(),
            style: AppTypography.medium14(color: AppColors.textPrimary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context, PropertyReviewModel review) {
    final isOwnReview =
        _canWriteOrEditReview && review.userId.trim() == currentUserId.trim();
    final avatarUrl = review.avatarUrl?.trim() ?? '';
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              avatarUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 18.r,
                      backgroundColor: const Color.fromARGB(255, 17, 18, 19),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          width: 36.r,
                          height: 36.r,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/profile.png'),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.infoLight,
                      child: ClipOval(
                        child: Image.asset('assets/images/profile.png'),
                      ),
                    ),
              AppSizes.gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTypography.bold14(color: AppColors.textPrimary),
                    ),
                    Text(
                      PropertyHelper.formatTimeAgo(review.updatedAt),
                      style: AppTypography.medium12(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.starColor,
                      size: 16.sp,
                    );
                  }),
                  if (isOwnReview) ...[
                    AppSizes.gapW4,
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Sửa đánh giá',
                      onPressed: () => _openReviewEditor(context),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          AppSizes.gapH10,
          Text(
            review.content,
            style: AppTypography.medium14(
              color: AppColors.textPrimary,
            ).copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}
