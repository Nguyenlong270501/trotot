import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../blocs/property_details_live/property_details_live_cubit.dart';
import '../../../../blocs/property_details_live/property_details_live_state.dart';

class PropertyDetailsAppBar extends StatelessWidget {
  const PropertyDetailsAppBar({
    super.key,
    required this.showSolidAppBar,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  final ValueNotifier<bool> showSolidAppBar;
  final Future<void> Function() onFavoriteTap;
  final Future<void> Function() onShareTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showSolidAppBar,
      builder: (context, showSolid, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: showSolid
              ? _SolidAppBar(
                  key: const ValueKey('solid_app_bar'),
                  onFavoriteTap: onFavoriteTap,
                  onShareTap: onShareTap,
                )
              : _OverlayAppBar(
                  key: const ValueKey('overlay_app_bar'),
                  onFavoriteTap: onFavoriteTap,
                  onShareTap: onShareTap,
                ),
        );
      },
    );
  }
}

class _OverlayAppBar extends StatelessWidget {
  const _OverlayAppBar({
    super.key,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  final Future<void> Function() onFavoriteTap;
  final Future<void> Function() onShareTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleActionButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => context.pop(),
            ),
            Row(
              children: [
                _CircleActionButton(
                  icon: Icons.share_outlined,
                  onTap: () => onShareTap(),
                ),
                SizedBox(width: 12.w),
                _FavoriteCircleButton(onFavoriteTap: onFavoriteTap),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _noop() {}
}

class _SolidAppBar extends StatelessWidget {
  const _SolidAppBar({
    super.key,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  final Future<void> Function() onFavoriteTap;
  final Future<void> Function() onShareTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20.sp,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    'Chi tiết bài đăng',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bold16(color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    size: 22.sp,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => onShareTap(),
                ),
                _FavoriteIconButton(onFavoriteTap: onFavoriteTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteCircleButton extends StatelessWidget {
  const _FavoriteCircleButton({required this.onFavoriteTap});

  final Future<void> Function() onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      PropertyDetailsLiveCubit,
      PropertyDetailsLiveState,
      (bool, bool)
    >(
      selector: (state) => (state.isFavorited, state.isFavoriteLoading),
      builder: (context, favoriteState) {
        final (isFavorited, isLoading) = favoriteState;
        return _CircleActionButton(
          icon: isFavorited ? Icons.favorite_rounded : Icons.favorite_border,
          iconColor: isFavorited ? Colors.red : AppColors.textPrimary,
          onTap: isLoading ? _OverlayAppBar._noop : () => onFavoriteTap(),
        );
      },
    );
  }
}

class _FavoriteIconButton extends StatelessWidget {
  const _FavoriteIconButton({required this.onFavoriteTap});

  final Future<void> Function() onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      PropertyDetailsLiveCubit,
      PropertyDetailsLiveState,
      (bool, bool)
    >(
      selector: (state) => (state.isFavorited, state.isFavoriteLoading),
      builder: (context, favoriteState) {
        final (isFavorited, isLoading) = favoriteState;
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite_rounded : Icons.favorite_border,
            size: 22.sp,
            color: isFavorited ? Colors.red : AppColors.textPrimary,
          ),
          onPressed: isLoading ? null : () => onFavoriteTap(),
        );
      },
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: iconColor),
      ),
    );
  }
}
