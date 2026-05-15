import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/route/app_routes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../appointment/data/models/appointment_model.dart';
import '../../../../data/models/property_model.dart';
import '../../../../data/models/room_model.dart';

class PropertyBottomActionBar extends StatelessWidget {
  const PropertyBottomActionBar({
    super.key,
    required this.property,
    required this.rooms,
    required this.hasExistingAppointment,
    required this.isCheckingAppointment,
    required this.isOwnProperty,
    this.initialAppointment,
  });

  final PropertyModel property;
  final List<RoomModel> rooms;
  final bool hasExistingAppointment;
  final bool isCheckingAppointment;
  final bool isOwnProperty;
  final AppointmentModel? initialAppointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.textDisabled,
                  size: 20.sp,
                ),
                label: Text(
                  'Liên hệ ngay',
                  style: AppTypography.bold14(color: AppColors.textDisabled),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: const BorderSide(color: AppColors.textDisabled),
                  disabledForegroundColor: AppColors.textDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            AppSizes.gapW16,
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: isOwnProperty || isCheckingAppointment
                    ? null
                    : () {
                        context.push(
                          RouteNames.appointmentPage,
                          extra: {
                            'property': property,
                            'rooms': rooms,
                            if (hasExistingAppointment &&
                                initialAppointment != null)
                              'initialAppointment': initialAppointment,
                          },
                        );
                      },
                icon: Icon(
                  isOwnProperty
                      ? Icons.home_work_outlined
                      : (isCheckingAppointment
                            ? Icons.hourglass_top_rounded
                            : (hasExistingAppointment
                                  ? Icons.calendar_today_outlined
                                  : Icons.event_available_outlined)),
                  color: Colors.white,
                  size: 20.sp,
                ),
                label: Text(
                  isOwnProperty
                      ? 'Bài đăng của bạn'
                      : (isCheckingAppointment
                            ? 'Đang kiểm tra...'
                            : (hasExistingAppointment
                                  ? 'Xem lịch hẹn'
                                  : 'Đặt lịch hẹn')),
                  style: AppTypography.bold14(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  backgroundColor: isOwnProperty || isCheckingAppointment
                      ? AppColors.textDisabled
                      : AppColors.primary,
                  disabledBackgroundColor: AppColors.textDisabled,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
