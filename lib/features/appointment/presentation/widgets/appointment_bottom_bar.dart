import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';

class AppointmentBottomBar extends StatelessWidget {
  const AppointmentBottomBar({
    super.key,
    required this.confirmed,
    required this.onMessageTap,
    required this.onConfirmTap,
    this.isLoading = false,
    this.isUpdateMode = false,
    this.isSubmitEnabled = true,
    this.successLabel = '✓  Đã đặt lịch thành công!',
    this.showRescheduleResponse = false,
    this.onAcceptRescheduleTap,
    this.onRejectRescheduleTap,
  });

  final bool confirmed;
  final bool isLoading;
  final bool isUpdateMode;
  final bool isSubmitEnabled;
  final String successLabel;
  final bool showRescheduleResponse;
  final VoidCallback onMessageTap;
  final VoidCallback onConfirmTap;
  final VoidCallback? onAcceptRescheduleTap;
  final VoidCallback? onRejectRescheduleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 14.h),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMessageTap,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(Icons.message, color: AppColors.primary, size: 18.sp),
            ),
          ),
          AppSizes.gapW10,
          if (showRescheduleResponse)
            Expanded(child: _buildRescheduleActions())
          else
            Expanded(child: _buildConfirmButton()),
        ],
      ),
    );
  }

  Widget _buildRescheduleActions() {
    final enabled = !isLoading;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: enabled ? onRejectRescheduleTap : null,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.surfaceCard
                    : AppColors.textDisabled.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: enabled ? AppColors.danger : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'Từ chối',
                  style: AppTypography.medium12(
                    color: enabled ? AppColors.danger : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
        AppSizes.gapW10,
        Expanded(
          child: GestureDetector(
            onTap: enabled ? onAcceptRescheduleTap : null,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: enabled ? AppColors.primary : AppColors.textDisabled,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : Text(
                        'Đồng ý',
                        style: AppTypography.medium12(color: AppColors.surface),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: !isSubmitEnabled || isLoading ? null : onConfirmTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 44.h,
        decoration: BoxDecoration(
          color: !isSubmitEnabled
              ? AppColors.textDisabled
              : (confirmed ? AppColors.success : AppColors.primary),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.surface,
                ),
              )
            else
              Text(
                confirmed
                    ? successLabel
                    : (isUpdateMode ? 'Cập nhật lịch hẹn' : 'Xác nhận đặt lịch'),
                style: AppTypography.medium12(color: AppColors.surface),
              ),
            if (!confirmed && !isLoading && isSubmitEnabled) ...[
              AppSizes.gapW6,
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.surface,
                size: 16.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
