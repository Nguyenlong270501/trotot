import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';

class AppointmentCalendar extends StatelessWidget {
  const AppointmentCalendar({
    super.key,
    required this.selectedDate,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final Future<void> Function() onPickDate;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
    return InkWell(
      onTap: onPickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: AppColors.accent,
              ),
            ),
            AppSizes.gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày xem phòng',
                    style: AppTypography.medium12(color: AppColors.textMuted),
                  ),
                  AppSizes.gapH4,
                  Text(
                    dateLabel,
                    style: AppTypography.bold14(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
