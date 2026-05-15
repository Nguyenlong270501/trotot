import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trotot/core/constants/app_sizes.dart';
import 'package:trotot/core/widgets/image_carousel.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_helper.dart';
import '../../../../data/models/property_model.dart';
import '../../../../data/models/room_model.dart';
import '../../../widgets/property_card/info_row.dart';

class PropertyHeaderInfo extends StatelessWidget {
  final PropertyModel property;
  final List<RoomModel> rooms;

  const PropertyHeaderInfo({
    super.key,
    required this.property,
    required this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        AppSizes.gapH6,
        InfoRow(
          label: 'Loại hình',
          value: PropertyHelper.orPlaceholder(
            property.propertyType,
            'Cho thuê',
          ),
        ),
        AppSizes.gapH6,
        _buildAddress(),
        AppSizes.gapH1,
        _buildPriceInfo(),
        AppSizes.gapH1,
        _buildRatingRow(),
        AppSizes.gapH8,
        if (property.imageUrls != null && property.imageUrls!.isNotEmpty)
          _buildImage(),
      ],
    );
  }

  Widget _buildTitle() {
    final timeAgo = PropertyHelper.formatTimeAgo(property.createdAt);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          property.title,
          style: AppTypography.bold16(color: AppColors.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            timeAgo,
            style: AppTypography.medium12(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildAddress() {
    final address = PropertyHelper.propertyLocationSubtitle(property);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 15.sp,
          color: AppColors.textMuted,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            address,
            style: AppTypography.medium14(color: AppColors.textPrimary),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    final (priceTitle, priceLabel) = PropertyHelper.priceRangeLabel(rooms);
    return InfoRow(label: priceTitle, value: priceLabel, highlight: true);
  }

  Widget _buildRatingRow() {
    final ratingAverage = property.ratingAverage;
    final totalReviews = property.totalReviews;

    return Row(
      children: [
        _StarRow(rating: ratingAverage, size: 16.sp),
        AppSizes.gapW6,
        Text(
          ratingAverage.toStringAsFixed(1),
          style: AppTypography.medium14(color: AppColors.textPrimary),
        ),
        AppSizes.gapW4,
        Text(
          ' · $totalReviews đánh giá',
          style: AppTypography.medium14(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình ảnh chung bên ngoài: ',
          style: AppTypography.bold14(color: AppColors.textPrimary),
        ),
        AppSizes.gapH8,
        Container(
          height: 200.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
          child: ImageCarousel(images: property.imageUrls!),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final partial = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : partial
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          size: size,
          color: AppColors.starColor,
        );
      }),
    );
  }
}
