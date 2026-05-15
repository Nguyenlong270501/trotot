import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class RoomMiniCard extends StatelessWidget {
  const RoomMiniCard({
    super.key,
    required this.name,
    required this.priceLabel,
    this.onTap,
  });

  final String name;
  final String priceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: AppColors.scaffoldBackground,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.bold14(color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                priceLabel,
                style: AppTypography.bold12(color: AppColors.primary),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
