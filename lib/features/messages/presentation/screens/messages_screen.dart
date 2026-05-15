import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../auth/blocs/auth_blocs/auth_cubit.dart';
import '../../../auth/blocs/auth_blocs/auth_state.dart';
import '../../data/repositories/messages_repository.dart';
import '../blocs/appointments_feed/appointments_feed_cubit.dart';
import '../blocs/notifications_feed/notifications_feed_cubit.dart';
import '../widgets/appointments_panel.dart';
import '../widgets/conversations_panel.dart';
import '../widgets/messages_tabs.dart';
import '../widgets/messages_top_bar.dart';
import '../widgets/notifications_panel.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationSuccessState) {
          return _buildAuthRequired(context, authState);
        }

        final userId = authState.user.userId;
        return DefaultTabController(
          length: 3,
          initialIndex: initialTabIndex.clamp(0, 2),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(150.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [MessagesTopBar(), MessagesTabs()],
              ),
            ),
            body: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      AppointmentsFeedCubit(context.read<MessagesRepository>())
                        ..watch(userId),
                ),
                BlocProvider(
                  create: (context) =>
                      NotificationsFeedCubit(context.read<MessagesRepository>())
                        ..watch(userId),
                ),
              ],
              child: const TabBarView(
                children: [
                  ConversationsPanel(),
                  NotificationsPanel(),
                  AppointmentsPanel(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthRequired(BuildContext context, AuthenticationState authState) {
    final message = switch (authState) {
      AuthenticationErrorState(:final error) => error,
      AuthenticationLoadingState() => 'Đang đăng xuất...',
      _ => 'Vui lòng đăng nhập để xem tin nhắn và thông báo.',
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceSheet,
              borderRadius: const BorderRadius.all(Radius.circular(28)),
            ),
            child: Text(
              'Tin nhắn',
              style: AppTypography.bold22(color: AppColors.accent),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            message,
            style: AppTypography.medium14(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
