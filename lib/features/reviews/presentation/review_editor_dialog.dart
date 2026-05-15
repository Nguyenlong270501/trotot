import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../home/data/models/property_model.dart';
import '../data/models/property_review_model.dart';
import '../blocs/review_form/review_form_cubit.dart';
import '../blocs/review_form/review_form_state.dart';

class ReviewEditorDialog extends StatelessWidget {
  const ReviewEditorDialog({
    super.key,
    required this.property,
    required this.currentUserId,
    required this.currentUserName,
    this.existingReview,
  });

  final PropertyModel property;
  final String currentUserId;
  final String currentUserName;
  final PropertyReviewModel? existingReview;

  @override
  Widget build(BuildContext context) {
    final formCubit = context.read<ReviewFormCubit>();
    return BlocBuilder<ReviewFormCubit, ReviewFormState>(
      bloc: formCubit,
      builder: (context, formState) {
        return AlertDialog(
          title: Text(
            existingReview == null ? 'Viết đánh giá' : 'Sửa đánh giá',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mức độ hài lòng',
                  style: AppTypography.bold14(color: AppColors.textPrimary),
                ),
                AppSizes.gapH8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    final selected = star <= formState.draftRating;
                    return IconButton(
                      onPressed: () => formCubit.setDraftRating(star),
                      icon: Icon(
                        selected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.starColor,
                      ),
                    );
                  }),
                ),
                AppSizes.gapH8,
                TextFormField(
                  key: ValueKey(existingReview?.reviewId ?? 'new-review'),
                  initialValue: formState.draftContent,
                  maxLength: 500,
                  maxLines: 4,
                  onChanged: formCubit.setDraftContent,
                  decoration: const InputDecoration(
                    hintText: 'Chia sẻ trải nghiệm của bạn...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (existingReview != null)
              TextButton(
                onPressed: () async {
                  await formCubit.deleteReview(
                    propertyId: property.propertyId,
                    userId: currentUserId,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Xóa'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                await formCubit.upsertReview(
                  propertyId: property.propertyId,
                  userId: currentUserId,
                  userName: currentUserName,
                  rating: formState.draftRating,
                  content: formState.draftContent,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(existingReview == null ? 'Gửi' : 'Cập nhật'),
            ),
          ],
        );
      },
    );
  }
}
