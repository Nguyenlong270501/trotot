import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';

class MapFilterResultBar extends StatelessWidget {
  const MapFilterResultBar({
    super.key,
    required this.count,
    required this.pinnedCount,
    required this.focusedIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onClear,
  });

  final int count;
  final int pinnedCount;
  final int focusedIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.medium14(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (count > 0 && pinnedCount != count)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        'Hiển thị $pinnedCount vị trí trên bản đồ',
                        style: AppTypography.medium12(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (pinnedCount > 1) ...[
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Vi tri truoc',
                visualDensity: VisualDensity.compact,
              ),
              Text(
                '$focusedIndex/$pinnedCount',
                style: AppTypography.medium12(color: AppColors.textPrimary),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Vi tri tiep theo',
                visualDensity: VisualDensity.compact,
              ),
            ],
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
