import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_style.dart';

class OutlinedDropdown extends StatelessWidget {
  const OutlinedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.hintWidget,
  });

  final String? value;
  final String? hintText;
  final Widget? hintWidget;
  final List<DropdownMenuItem<String?>> items;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final hintChild =
        hintWidget ??
        Text(
          hintText ?? '',
          style: AppTypography.medium14(color: Colors.grey[600]),
        );

    return Container(
      margin: EdgeInsets.only(top: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.grey[600],
            size: 24.sp,
          ),
          hint: hintChild,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
