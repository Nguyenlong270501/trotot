import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Stacked map controls below the app bar (top-right).
class MapSearchMapControls extends StatelessWidget {
  const MapSearchMapControls({
    super.key,
    this.top = 12,
    this.onMyLocationTap,
  });

  final double top;
  final VoidCallback? onMyLocationTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top.h,
      right: 12.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapControlIconButton(
            icon: Icons.navigation_rounded,
            onTap: onMyLocationTap,
          ),
          SizedBox(height: 8.h),
          const _MapControlIconButton(
            icon: Icons.location_on_outlined,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _MapControlIconButton extends StatelessWidget {
  const _MapControlIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: _size.w,
          height: _size.h,
          child: Icon(icon, size: 22.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
