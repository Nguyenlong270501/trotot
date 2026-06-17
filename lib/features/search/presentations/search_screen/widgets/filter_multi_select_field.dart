import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../blocs/room_filter/room_filter_cubit.dart';
import '../../../blocs/room_filter/room_filter_state.dart';
import 'filter_multi_select_sheet.dart';
import 'filter_sheet_options.dart';

class FilterMultiSelectField extends StatelessWidget {
  const FilterMultiSelectField({
    super.key,
    required this.sheetType,
    required this.sheetTitle,
    required this.searchHint,
    required this.placeholder,
    required this.city,
    required this.selected,
    required this.buildOptions,
    required this.isWard,
  });

  final FilterSheetType sheetType;
  final String sheetTitle;
  final String searchHint;
  final String placeholder;
  final String? city;
  final Set<String> selected;
  final List<FilterSheetOption> Function(String? city) buildOptions;
  final bool isWard;

  Future<void> _openSheet(BuildContext context) async {
    final cubit = context.read<RoomFilterCubit>();
    final options = buildOptions(city);
    cubit.startSheetEdit(
      type: sheetType,
      title: sheetTitle,
      searchHint: searchHint,
      options: options,
      initialSelection: selected,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.92,
        child: BlocProvider.value(
          value: cubit,
          child: const FilterMultiSelectSheet(),
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }
    if (cubit.state.activeSheetType != FilterSheetType.none) {
      cubit.cancelSheetEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = buildOptions(city);
    final summary = buildFilterSelectionSummary(
      selected: selected,
      options: options,
      city: city,
      isWard: isWard,
    );
    final hasSelection = selected.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openSheet(context),
        borderRadius: BorderRadius.circular(12.r),
        child: InputDecorator(
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hasSelection ? null : placeholder,
            hintStyle: AppTypography.medium14(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 15.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
              size: 28.sp,
            ),
          ),
          isEmpty: !hasSelection,
          child: hasSelection
              ? Text(
                  summary,
                  style: AppTypography.medium14(color: AppColors.textPrimary),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
