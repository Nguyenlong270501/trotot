import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';

class AppointmentPhoneField extends StatelessWidget {
  const AppointmentPhoneField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      style: AppTypography.medium14(color: AppColors.textSecondary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.medium14(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: EdgeInsets.all(12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.warning, width: 1.5),
        ),
      ),
    );
  }
}
