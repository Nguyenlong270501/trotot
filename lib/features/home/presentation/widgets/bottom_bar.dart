import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trotot/core/theme/app_style.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChange;

  static const _items = [
    _BottomItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Trang chủ',
    ),
    _BottomItem(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Yêu thích',
    ),
    _BottomItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Tin nhắn',
    ),
    _BottomItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Tài khoản',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeWeight = 2.h;
    final inactiveWeight = 1.h;
    final totalWeight = activeWeight + (_items.length - 1) * inactiveWeight;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        height: 58.h,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEAF3),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;

            return Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isActive = currentIndex == index;
                final targetWidth = isActive
                    ? totalWidth * activeWeight / totalWeight
                    : totalWidth * inactiveWeight / totalWeight;

                return TweenAnimationBuilder<double>(
                  tween: Tween(end: targetWidth),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  builder: (context, width, child) {
                    return SizedBox(width: width, child: child);
                  },
                  child: GestureDetector(
                    onTap: () => onTabChange(index),
                    child: _BottomItemContent(item: item, isActive: isActive),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _BottomItemContent extends StatelessWidget {
  const _BottomItemContent({required this.item, required this.isActive});

  final _BottomItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accentIcon : AppColors.textMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentLight : Colors.transparent,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? item.activeIcon : item.icon,
            size: AppSizes.iconSizeSmall,
            color: color,
          ),
          if (isActive) ...[
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.medium14().copyWith(color: color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomItem {
  const _BottomItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
