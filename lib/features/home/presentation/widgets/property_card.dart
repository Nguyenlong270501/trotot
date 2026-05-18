import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/property_image_precache.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../../core/utils/property_helper.dart';
import '../../data/models/preview_stat.dart';
import '../../data/models/property_model.dart';
import 'emoji_lable.dart';
import '../../../../core/widgets/image_carousel.dart';
import 'info_row.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property, this.onTap});

  final PropertyModel property;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final rooms = property.rooms ?? [];
    final first = rooms.isNotEmpty ? rooms.first : null;

    final images = _resolveImages(first);

    final address = PropertyHelper.propertyLocationSubtitle(property);

    final typeLabel = PropertyHelper.orPlaceholder(
      property.propertyType,
      'Cho thuê',
    );

    final (pricePrefix, priceValue) = PropertyHelper.priceRangeLabel(rooms);

    final stats = _buildStats(first);

    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              precachePropertyCardHeroImage(context, images);
              onTap!();
            },
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
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
              if (images.isNotEmpty) _buildImage(images),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          AppSizes.gapW8,
                          Icon(
                            Icons.star_rounded,
                            size: 16.sp,
                            color: AppColors.starColor,
                          ),
                          AppSizes.gapW4,
                          Text(
                            property.ratingAverage.toStringAsFixed(1),
                            style: AppTypography.medium14(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          AppSizes.gapW4,
                          Text(
                            '(${property.totalReviews})',
                            style: AppTypography.medium14(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSizes.gapH8,

                    InfoRowList(
                      label: 'Loại hình: ',
                      value: [typeLabel],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSizes.gapH4,

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
                            address,
                            style: AppTypography.medium14(
                              color: AppColors.textPrimary,
                            ).copyWith(height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.gapH4,

                    InfoRow(label: 'Mô tả: ', value: property.description),
                    AppSizes.gapH6,

                    InfoRow(
                      label: pricePrefix,
                      value: priceValue,
                      highlight: true,
                    ),
                    AppSizes.gapH6,

                    EmojiLable(stats: stats),

                    AppSizes.gapH10,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  List<String> _resolveImages(dynamic first) {
    if (first != null && first.imageUrls.isNotEmpty) {
      return List<String>.from(first.imageUrls);
    }
    return List<String>.from(property.imageUrls ?? []);
  }

  List<PreviewStat> _buildStats(dynamic first) {
    final rooms = property.rooms ?? [];
    return [
      PreviewStat(
        value: rooms.isNotEmpty
            ? '${rooms.where((r) => r.isAvailable == true).length}'
            : '—',
        label: 'Phòng trống',
        emoji: '🛏️',
      ),
      PreviewStat(
        value: first != null && first.area > 0
            ? PropertyHelper.formatAreaLabel(first.area.toString())
            : '—',
        label: 'Diện tích',
        emoji: '📐',
      ),
      PreviewStat(
        value: first != null && first.maxTenants > 0
            ? '${first.maxTenants}'
            : '—',
        label: 'Người / phòng',
        emoji: '👥',
      ),
    ];
  }

  Widget _buildImage(List<String> images) {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageCarousel(images: images, enableFullScreenOnTap: false),

          if (PropertyHelper.isNewListing(property.createdAt))
            Positioned(top: 10.h, right: 10.w, child: const _NewBadge()),
        ],
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
