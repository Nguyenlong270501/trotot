import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class AppointmentSummaryBox extends StatelessWidget {
  const AppointmentSummaryBox({
    super.key,
    required this.dayName,
    required this.selectedDate,
    required this.formattedTime,
    required this.landlordName,
    required this.landlordPhone,
  });

  final String dayName;
  final DateTime selectedDate;
  final String formattedTime;
  final String landlordName;
  final String landlordPhone;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TÓM TẮT LỊCH HẸN',
            style: AppTypography.medium10(
              color: AppColors.textMuted,
            ).copyWith(letterSpacing: 0.8),
          ),
          AppSizes.gapH12,
          _SummaryRow(
            icon: Icons.calendar_today_rounded,
            value: '$dayName, ${selectedDate.day} tháng 5 · 2026',
          ),
          AppSizes.gapH8,
          _SummaryRow(
            icon: Icons.access_time_rounded,
            value: '$formattedTime · ~30 phút',
          ),
          AppSizes.gapH8,
          _SummaryRow(
            icon: Icons.person_rounded,
            value: 'Chủ nhà: $landlordName',
            subtitle: landlordPhone,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.value, this.subtitle});

  final IconData icon;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 14.sp),
        ),
        AppSizes.gapW10,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.medium12(color: AppColors.textPrimary),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTypography.medium10(color: AppColors.textMuted),
              ),
          ],
        ),
      ],
    );
  }
}
