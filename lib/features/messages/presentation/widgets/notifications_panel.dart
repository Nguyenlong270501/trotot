import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../blocs/notifications_feed/notifications_feed_cubit.dart';
import '../../blocs/notifications_feed/notifications_feed_state.dart';
import '../utils/notification_time_label.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/route/app_routes.dart';
import '../../data/repositories/messages_repository.dart';
import '../../../profile/data/repositories/landlord_register_repository.dart';

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});

  Future<void> _handleNotificationTap(
    BuildContext context,
    dynamic item,
  ) async {
    if (!item.isRead) {
      context.read<NotificationsFeedCubit>().markRead(item.notificationId);
    }

    if (item.type == 'appointment' && item.propertyId != null) {
      final propertyId = item.propertyId!.trim();
      final appointmentId = item.appointmentId?.trim() ?? '';
      if (propertyId.isEmpty) return;

      final navData = await context
          .read<MessagesRepository>()
          .getAppointmentNavigationData(
            propertyId: propertyId,
            appointmentId: appointmentId,
          );

      if (!context.mounted || navData == null) return;

      context.push(RouteNames.appointmentPage, extra: navData);
    } else if (item.type == 'landlord_request') {
      final request = await context
          .read<LandlordRegisterRepository>()
          .getCurrentUserRequest();

      if (!context.mounted) return;

      if (request != null) {
        context.pushNamed(RouteNames.landlordRegisterPage, extra: request);
      } else {
        context.go(RouteNames.homepage, extra: {'initialBottomNavIndex': 3});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsFeedCubit, NotificationsFeedState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          return Center(
            child: Text(
              state.errorMessage!,
              style: AppTypography.medium14(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (state.items.isEmpty) {
          return Center(
            child: Text(
              'Chưa có thông báo',
              style: AppTypography.medium14(color: AppColors.textPrimary),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            return _NotificationItem(
              title: item.title,
              description: item.content,
              time: formatNotificationTimeLabel(item.createdAt),
              isRead: item.isRead,
              onTap: () => _handleNotificationTap(context, item),
            );
          },
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.onTap,
  });

  final String title;
  final String description;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.surface.withValues(alpha: 0.6)
              : AppColors.success.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14.r),
          border: isRead
              ? null
              : Border.all(color: AppColors.accentIcon.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.bold14(color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: AppTypography.medium12(color: AppColors.textSecondary),
            ),
            SizedBox(height: 4.h),
            Text(
              time,
              style: AppTypography.medium10(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
