import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';

class MapFilterResultBar extends StatelessWidget {
  const MapFilterResultBar({
    super.key,
    required this.count,
    required this.onClear,
  });

  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = count > 0
        ? '$count kết quả phù hợp'
        : 'Không có kết quả phù hợp';

    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12.r),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.medium14(color: AppColors.textPrimary),
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              tooltip: 'Xóa bộ lọc',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
