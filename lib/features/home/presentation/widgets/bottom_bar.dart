import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../../core/constants/app_sizes.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        height: 55.h,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEAF3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: GNav(
          selectedIndex: currentIndex,
          onTabChange: onTabChange,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          backgroundColor: Colors.transparent,
          color: const Color(0xFF8D8D8D),
          activeColor: const Color(0xFF6F6BCB),
          tabBackgroundColor: const Color(0xFFDCD8FF),
          padding: const EdgeInsets.all(8),
          gap: 4,
          iconSize: AppSizes.iconSizeSmall,
          tabs: const [
            GButton(icon: Icons.home_rounded, text: 'Trang chủ'),
            GButton(icon: Icons.favorite_border_rounded, text: 'Yêu thích'),
            GButton(icon: Icons.chat_bubble_outline_rounded, text: 'Tin nhắn'),
            GButton(icon: Icons.person_outline_rounded, text: 'Tài khoản'),
          ],
        ),
      ),
    );
  }
}
