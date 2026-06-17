import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';

class AppointmentTimeSlots extends StatelessWidget {
  const AppointmentTimeSlots({
    super.key,
    required this.selectedTimeLabel,
    required this.onPickTime,
  });

  final String selectedTimeLabel;
  final Future<void> Function() onPickTime;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPickTime,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
            AppSizes.gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giờ xem phòng',
                    style: AppTypography.medium12(color: AppColors.textMuted),
                  ),
                  AppSizes.gapH4,
                  Text(
                    selectedTimeLabel,
                    style: AppTypography.bold14(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
