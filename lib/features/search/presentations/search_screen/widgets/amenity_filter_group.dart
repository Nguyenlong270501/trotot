import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../home/data/models/amenity_option.dart';

class AmenityFilterGroup extends StatelessWidget {
  final List<AmenityOption> options;
  final Set<String> selectedLabels;
  final Function(String) onToggle;

  const AmenityFilterGroup({
    super.key,
    required this.options,
    required this.selectedLabels,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w, // Khoảng cách ngang giữa các nút
      runSpacing: 10.h, // Khoảng cách dọc (xuống dòng)
      children: [
        for (final option in options)
          _buildCustomAmenityChip(option),
      ],
    );
  }

  Widget _buildCustomAmenityChip(AmenityOption option) {
    final isSelected = selectedLabels.contains(option.label);

    return GestureDetector(
      onTap: () => onToggle(option.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Padding bên trong nút để nó ôm vừa vặn cả icon lẫn text
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8.r), // Bo góc 8 giống nút Giá
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        // Dùng Row bọc icon và text
        child: Row(
          mainAxisSize: MainAxisSize.min, // Cực kỳ quan trọng: Ép Row chỉ dài bằng nội dung bên trong
          children: [
            // Hiển thị Emoji / Icon
            Text(
              option.emoji,
              style: TextStyle(fontSize: 14.sp), 
            ),
            SizedBox(width: 6.w),
            // Hiển thị Tên tiện ích
            Text(
              option.label,
              style: isSelected
                  ? AppTypography.bold12(color: AppColors.primary) // Chữ in đậm màu nổi khi chọn
                  : AppTypography.medium12(color: Colors.black87), // Chữ thường khi chưa chọn
            ),
          ],
        ),
      ),
    );
  }
}