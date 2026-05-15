import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../../core/utils/property_helper.dart';
import '../../../home/data/models/property_model.dart';

class AppointmentPropertyBriefCard extends StatelessWidget {
  const AppointmentPropertyBriefCard({super.key, required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final address = PropertyHelper.propertyLocationSubtitle(property);
    final landlordName =
        property.landlordSummary?.userName.trim().isNotEmpty == true
        ? property.landlordSummary!.userName
        : 'Chủ trọ';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.home_rounded,
              size: 22.sp,
              color: AppColors.warning,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bold14(color: AppColors.textPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.medium12(color: AppColors.textSecondary),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Chủ trọ : $landlordName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.medium12(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
