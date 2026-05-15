import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../data/models/appointment_models.dart';

class AppointmentPurposeGrid extends StatelessWidget {
  const AppointmentPurposeGrid({
    super.key,
    required this.purposes,
    required this.selectedPurpose,
    required this.onSelectPurpose,
  });

  final List<BookingPurpose> purposes;
  final int selectedPurpose;
  final ValueChanged<int> onSelectPurpose;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 2.6,
      ),
      itemCount: purposes.length,
      itemBuilder: (_, index) {
        final selected = selectedPurpose == index;
        final purpose = purposes[index];
        return GestureDetector(
          onTap: () => onSelectPurpose(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.12)
                        : AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(
                    purpose.icon,
                    size: 16.sp,
                    color: selected ? AppColors.surface : AppColors.warning,
                  ),
                ),
                AppSizes.gapW8,
                Expanded(
                  child: Text(
                    purpose.label,
                    style: AppTypography.medium12(
                      color: selected
                          ? AppColors.surface
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
