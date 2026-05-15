import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/image_carousel.dart';

class PropertyHeaderImage extends StatelessWidget {
  const PropertyHeaderImage({
    super.key,
    required this.imageUrls,
    required this.topPadding,
    required this.isFavorited,
    required this.isFavoriteLoading,
    required this.onFavoriteTap,
  });

  final List<String> imageUrls;
  final double topPadding;
  final bool isFavorited;
  final bool isFavoriteLoading;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ẢNH CAROUSEL
        SizedBox(
          height: 280.h,
          width: double.infinity,
          child: ImageCarousel(images: imageUrls),
        ),

        // CÁC NÚT HÀNH ĐỘNG NỔI
        Positioned(
          top: topPadding + 8.h,
          left: 16.w,
          right: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút Back
              _CircleActionButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => context.pop(),
              ),
              // Cụm Share + Tim
              Row(
                children: [
                  _CircleActionButton(icon: Icons.share_outlined, onTap: () {}),
                  SizedBox(width: 12.w),
                  _CircleActionButton(
                    icon: isFavorited
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    iconColor: isFavorited ? Colors.red : AppColors.textPrimary,
                    onTap: isFavoriteLoading ? () {} : onFavoriteTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===============================================
// WIDGET CON: NÚT TRÒN TRẮNG NỔI
// ===============================================
class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: iconColor),
      ),
    );
  }
}
