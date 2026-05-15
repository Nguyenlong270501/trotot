import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class PriceBracketFilter extends StatelessWidget {
  final Set<int> selectedIndexes;
  final Function(int) onSelected;

  const PriceBracketFilter({
    super.key,
    required this.selectedIndexes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.6,
      ),
      itemCount: PropertyConstants.priceFilterLabels.length,
      itemBuilder: (context, index) {
        final isSelected = selectedIndexes.contains(index);

        return GestureDetector(
          onTap: () => onSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              PropertyConstants.priceFilterLabels[index],
              style: isSelected
                  ? AppTypography.bold12(color: AppColors.primary)
                  : AppTypography.medium12(color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}
