import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../../core/utils/property_helper.dart';
import '../../../../core/utils/property_image_precache.dart';
import '../../../../core/widgets/image_carousel.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/presentation/widgets/info_row.dart';

class PropertyMapCard extends StatelessWidget {
  const PropertyMapCard({
    super.key,
    required this.property,
    this.onTap,
    this.onClose,
    this.onFavoriteTap,
  });

  final PropertyModel property;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final rooms = property.rooms ?? [];
    final first = rooms.isNotEmpty ? rooms.first : null;

    final images = _resolveImages(first);
    final typeLabel = PropertyHelper.orPlaceholder(
      property.propertyType,
      'Cho thuê',
    );
    final (pricePrefix, priceValue) = PropertyHelper.priceRangeLabel(rooms);

    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              precachePropertyCardHeroImage(context, images);
              onTap!();
            },
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 320.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty) _buildImage(images),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: AppTypography.bold16(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (property.ratingAverage > 0) ...[
                        AppSizes.gapW6,
                        Icon(
                          Icons.star_rounded,
                          size: 15.sp,
                          color: AppColors.starColor,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          property.ratingAverage.toStringAsFixed(1),
                          style: AppTypography.medium14(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  AppSizes.gapH6,

                  InfoRowList(
                    label: 'Loại hình: ',
                    value: [typeLabel],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (property.description.trim().isNotEmpty) ...[
                    AppSizes.gapH4,
                    Text(
                      property.description,
                      style: AppTypography.medium14(
                        color: AppColors.textMuted,
                      ).copyWith(height: 1.25),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  AppSizes.gapH8,

                  InfoRow(
                    label: pricePrefix,
                    value: priceValue,
                    highlight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _resolveImages(dynamic first) {
    if (first != null && first.imageUrls.isNotEmpty) {
      return List<String>.from(first.imageUrls);
    }
    return List<String>.from(property.imageUrls ?? []);
  }

  Widget _buildImage(List<String> images) {
    return SizedBox(
      height: 150.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageCarousel(images: images, enableFullScreenOnTap: false),

          if (onFavoriteTap != null)
            Positioned(
              top: 10.h,
              right: onClose == null ? 10.w : 52.w,
              child: _CircleIconButton(
                icon: Icons.favorite_border_rounded,
                onTap: onFavoriteTap!,
              ),
            ),

          if (onClose != null)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: _CircleIconButton(
                icon: Icons.close_rounded,
                onTap: onClose!,
              ),
            ),

          if (PropertyHelper.isNewListing(property.createdAt))
            Positioned(top: 10.h, left: 10.w, child: const _NewBadge()),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(7.w),
          child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12.sp, color: AppColors.orangePrimary),
          SizedBox(width: 4.w),
          Text(
            'MỚI',
            style: AppTypography.bold10(color: AppColors.orangePrimary),
          ),
        ],
      ),
    );
  }
}
