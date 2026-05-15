import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../auth/blocs/auth_blocs/auth_cubit.dart';
import '../../../auth/blocs/auth_blocs/auth_state.dart';
import '../../../auth/data/models/user.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../blocs/landlord_status/landlord_status_cubit.dart';
import '../../blocs/landlord_status/landlord_status_state.dart';
import '../../data/models/landlord_request.dart';
import '../widgets/menu_item.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _onLogoutTap(BuildContext context) async {
    await context.read<AuthenticationCubit>().signout();
    if (!context.mounted) {
      return;
    }
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is UnAuthenticationState) {
      context.goNamed(RouteNames.loginpage);
      return;
    }
    if (authState is AuthenticationErrorState) {
      Alerts.of(context).showError(authState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        UserModel? user;
        if (state is AuthenticationSuccessState) {
          user = state.user;
        }

        final name = (user?.userName.isNotEmpty ?? false)
            ? user!.userName
            : 'Người dùng';
        final email = user?.email ?? 'Chưa có email';
        final avatarUrl = user?.avatarUrl ?? '';
        final isLandlord = user?.isLandlord ?? false;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSheet,
                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                ),
                child: Text(
                  'Tài khoản cá nhân',
                  style: AppTypography.bold22(color: AppColors.accent),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(10.w, 10.w, 10.w, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSheet,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ProfileAvatar(
                      name: name,
                      email: email,
                      avatarUrl: avatarUrl,
                      isLandlord: isLandlord,
                    ),
                  ),
                  AppSizes.gapH16,
                  _ProfileMenuSection(user: user),
                  AppSizes.gapH24,
                  Center(
                    child: _LogoutButton(onTap: () => _onLogoutTap(context)),
                  ),
                  AppSizes.gapH16,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileMenuSection extends StatefulWidget {
  const _ProfileMenuSection({required this.user});

  final UserModel? user;

  @override
  State<_ProfileMenuSection> createState() => _ProfileMenuSectionState();
}

class _ProfileMenuSectionState extends State<_ProfileMenuSection> {
  Future<void> _openNotificationSettings() async {
    final opened = await openAppSettings();
    if (!opened && mounted) {
      Alerts.of(context).showError('Không thể mở cài đặt hệ thống.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Tài khoản của tôi'),
        _ProfileSectionCard(
          children: [
            MenuItem(
              grouped: true,
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () => context.pushNamed(
                RouteNames.editProfilePage,
                extra: widget.user,
              ),
            ),
            _ProfileMenuDivider(),
            MenuItem(
              grouped: true,
              icon: Icons.security,
              title: 'Bảo mật & Mật khẩu',
              onTap: () => context.pushNamed(RouteNames.securityPasswordPage),
            ),
            _ProfileMenuDivider(),
            const _LandlordStatusMenuItem(),
          ],
        ),
        _buildSectionTitle('Cài đặt hệ thống'),
        _ProfileSectionCard(
          children: [
            MenuItem(
              grouped: true,
              icon: Icons.notifications_none,
              title: 'Cài đặt thông báo',
              onTap: _openNotificationSettings,
            ),
            _ProfileMenuDivider(),
            const MenuItem(
              grouped: true,
              icon: Icons.location_on_outlined,
              title: 'Cài đặt vị trí',
            ),
          ],
        ),
        _buildSectionTitle('Hỗ trợ & Thông tin'),
        _ProfileSectionCard(
          children: const [
            MenuItem(
              grouped: true,
              icon: Icons.headset_mic_outlined,
              title: 'Trung tâm hỗ trợ',
            ),
            _ProfileMenuDivider(),
            MenuItem(
              grouped: true,
              icon: Icons.article_outlined,
              title: 'Điều khoản & Chính sách',
            ),
            _ProfileMenuDivider(),
            MenuItem(
              grouped: true,
              icon: Icons.info_outline,
              title: 'Về Trọ Tốt (v1.0.0)',
              showTrailing: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ProfileMenuDivider extends StatelessWidget {
  const _ProfileMenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 54.w,
      endIndent: 16.w,
    );
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 8.h, top: 4.h),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: AppTypography.bold14(color: AppColors.textSecondary),
      ),
    ),
  );
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: AppSizes.iconSizeSmall,
              color: AppColors.danger,
            ),
            AppSizes.gapW8,
            Text(
              'Đăng xuất',
              style: AppTypography.bold18(color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandlordStatusMenuItem extends StatelessWidget {
  const _LandlordStatusMenuItem();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordStatusCubit, LandlordStatusState>(
      builder: (context, state) {
        if (state is LandlordStatusInitial || state is LandlordStatusError) {
          return MenuItem(
            grouped: true,
            icon: Icons.add_business_rounded,
            iconColor: Colors.orange,
            title: 'Trở thành Chủ trọ',
            onTap: () => context.pushNamed(RouteNames.landlordRegisterPage),
          );
        }

        if (state is LandlordStatusLoaded) {
          final status = state.request.status;

          switch (status) {
            case LandlordRequestStatus.pending:
              return MenuItem(
                grouped: true,
                icon: Icons.hourglass_top_rounded,
                iconColor: Colors.amber,
                title: 'Hồ sơ đang chờ duyệt',
                onTap: () => context.pushNamed(
                  RouteNames.landlordRegisterPage,
                  extra: state.request,
                ),
              );

            case LandlordRequestStatus.rejected:
              return MenuItem(
                grouped: true,
                icon: Icons.error_outline_rounded,
                iconColor: Colors.redAccent,
                title: 'Hồ sơ bị từ chối (Cập nhật)',
                onTap: () => context.pushNamed(
                  RouteNames.landlordRegisterPage,
                  extra: state.request,
                ),
              );

            case LandlordRequestStatus.approved:
              return MenuItem(
                grouped: true,
                icon: Icons.playlist_add_check_rounded,
                iconColor: Colors.green,
                title: 'Hồ sơ đã được duyệt',
                onTap: () => context.pushNamed(
                  RouteNames.landlordRegisterPage,
                  extra: state.request,
                ),
              );
          }
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
