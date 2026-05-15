import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_style.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.isDisabled = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDisabled
        ? const Color(0xFFE8E8EE)
        : isActive
        ? const Color(0xFF6F6BCB)
        : const Color(0xFFF0F1F6);
    final fg = isDisabled
        ? Colors.black26
        : isActive
        ? Colors.white
        : Colors.black54;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: fg, size: 22),
            ),
            AppSizes.gapH8,
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.medium10(
                color: isActive ? const Color(0xFF6662BE) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
