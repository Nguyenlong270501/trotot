import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class PropertyDescriptionSection extends StatefulWidget {
  final String description;

  const PropertyDescriptionSection({super.key, required this.description});

  @override
  State<PropertyDescriptionSection> createState() =>
      _PropertyDescriptionSectionState();
}

class _PropertyDescriptionSectionState
    extends State<PropertyDescriptionSection> {
  final ValueNotifier<bool> _expandedNotifier = ValueNotifier<bool>(false);
  static const int _maxLines = 3;

  @override
  void dispose() {
    _expandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.medium14(color: AppColors.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final span = TextSpan(text: widget.description, style: textStyle);
            final tp = TextPainter(
              text: span,
              maxLines: _maxLines,
              textDirection: TextDirection.ltr,
            );
            tp.layout(maxWidth: constraints.maxWidth);

            final isOverflowing = tp.didExceedMaxLines;
            if (!isOverflowing) {
              return Text(widget.description, style: textStyle);
            }

            return ValueListenableBuilder<bool>(
              valueListenable: _expandedNotifier,
              builder: (context, isExpanded, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        widget.description,
                        style: textStyle,
                        maxLines: _maxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(widget.description, style: textStyle),
                    ),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () => _expandedNotifier.value = !isExpanded,
                      child: Text(
                        isExpanded ? 'Thu gọn' : 'Xem thêm',
                        style: AppTypography.medium14(color: AppColors.primary),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
