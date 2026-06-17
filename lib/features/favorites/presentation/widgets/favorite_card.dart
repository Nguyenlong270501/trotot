import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../../core/widgets/image_carousel.dart';
import '../../data/models/favorite_property_model.dart';

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({super.key, required this.item, this.onTap});

  final FavoritePropertyModel item;
  final VoidCallback? onTap;

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '—';
    }
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final images = item.previewImageUrls;
    return InkWell(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180.h,
              width: double.infinity,
              child: images.isEmpty
                  ? const Center(child: Icon(Icons.home_work_outlined))
                  : ImageCarousel(images: images, enableFullScreenOnTap: false),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bold16(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSizes.gapH6,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                      AppSizes.gapW4,
                      Expanded(
                        child: Text(
                          item.address,
                          style: AppTypography.medium14(
                            color: AppColors.textPrimary,
                          ).copyWith(height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.gapH8,
                  Text(
                    'Ngày đăng: ${_formatDate(item.createdAt)}',
                    style: AppTypography.medium12(color: AppColors.textMuted),
                  ),
                  AppSizes.gapH4,
                  Text(
                    'Đã lưu: ${_formatDate(item.favoritedAt)}',
                    style: AppTypography.medium12(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
