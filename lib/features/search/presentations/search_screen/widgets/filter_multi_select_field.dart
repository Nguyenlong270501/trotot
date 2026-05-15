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
        child: Container(
          margin: EdgeInsets.only(top: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasSelection ? summary : placeholder,
                  style: AppTypography.medium14(
                    color: hasSelection
                        ? AppColors.textPrimary
                        : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
