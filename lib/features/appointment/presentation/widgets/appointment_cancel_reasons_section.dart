import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import 'appointment_section.dart';

class AppointmentCancelReasonsSection extends StatelessWidget {
  const AppointmentCancelReasonsSection({
    super.key,
    this.landlordCancelReason,
    this.tenantCancelReason,
  });

  final String? landlordCancelReason;
  final String? tenantCancelReason;

  @override
  Widget build(BuildContext context) {
    final landlordReason = landlordCancelReason?.trim() ?? '';
    final tenantReason = tenantCancelReason?.trim() ?? '';
    if (landlordReason.isEmpty && tenantReason.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (landlordReason.isNotEmpty) ...[
          const AppointmentDivider(),
          AppointmentSection(
            label: 'Lý do từ chối (chủ trọ)',
            child: _ReasonCard(text: landlordReason),
          ),
        ],
        if (tenantReason.isNotEmpty) ...[
          const AppointmentDivider(),
          AppointmentSection(
            label: 'Lý do từ chối (người thuê)',
            child: _ReasonCard(text: tenantReason),
          ),
        ],
        AppSizes.gapH8,
      ],
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: AppTypography.medium14(color: AppColors.textSecondary),
      ),
    );
  }
}
