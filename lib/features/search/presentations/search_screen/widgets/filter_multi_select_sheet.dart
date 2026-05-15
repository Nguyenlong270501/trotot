import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../blocs/room_filter/room_filter_cubit.dart';
import '../../../blocs/room_filter/room_filter_state.dart';
import 'filter_sheet_options.dart';

class FilterMultiSelectSheet extends StatefulWidget {
  const FilterMultiSelectSheet({super.key});

  /// Chiều cao vùng chip ~3 hàng (chip ~28.h + khoảng cách 6.h).
  static double chipsAreaHeight(double chipHeight, double runSpacing) =>
      chipHeight * 3 + runSpacing * 2;

  @override
  State<FilterMultiSelectSheet> createState() => _FilterMultiSelectSheetState();
}

class _FilterMultiSelectSheetState extends State<FilterMultiSelectSheet> {
  late final TextEditingController _searchController;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    final query = context.read<RoomFilterCubit>().state.sheetQuery;
    _searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onDismiss(BuildContext context) {
    if (!_confirmed) {
      context.read<RoomFilterCubit>().cancelSheetEdit();
    }
  }

  void _onConfirm(BuildContext context) {
    _confirmed = true;
    context.read<RoomFilterCubit>().confirmSheetEdit();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _onDismiss(context);
        }
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: BlocBuilder<RoomFilterCubit, RoomFilterState>(
            buildWhen: (prev, curr) =>
                prev.sheetTitle != curr.sheetTitle ||
                prev.sheetSearchHint != curr.sheetSearchHint ||
                prev.sheetQuery != curr.sheetQuery ||
                prev.sheetFilteredOptions != curr.sheetFilteredOptions ||
                prev.sheetStagedSelection != curr.sheetStagedSelection,
            builder: (context, state) {
              final cubit = context.read<RoomFilterCubit>();
              final isWard = state.activeSheetType == FilterSheetType.ward;
              final city = state.draft.city;
              final selectedChips = state.sheetStagedSelection
                  .map(
                    (value) => (
                      value,
                      labelForSheetValue(
                        selected: state.sheetStagedSelection,
                        value: value,
                        options: state.sheetAllOptions,
                        city: city,
                        isWard: isWard,
                      ),
                    ),
                  )
                  .toList();

              if (_searchController.text != state.sheetQuery) {
                _searchController.value = _searchController.value.copyWith(
                  text: state.sheetQuery,
                  selection: TextSelection.collapsed(
                    offset: state.sheetQuery.length,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 8.h, 8.w, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            state.sheetTitle,
                            style: AppTypography.bold16(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                    child: TextField(
                      controller: _searchController,
                      onChanged: cubit.updateSheetQuery,
                      decoration: InputDecoration(
                        hintText: state.sheetSearchHint,
                        hintStyle: AppTypography.medium14(
                          color: Colors.grey[600],
                        ),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.sheetFilteredOptions.isEmpty
                        ? Center(
                            child: Text(
                              'Không tìm thấy kết quả',
                              style: AppTypography.medium14(
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: state.sheetFilteredOptions.length,
                            itemBuilder: (context, index) {
                              final option =
                                  state.sheetFilteredOptions[index];
                              final isSelected = state.sheetStagedSelection
                                  .contains(option.value);
                              return Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Material(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6.r),
                                    onTap: () => cubit.toggleSheetOption(
                                      option.value,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 36.w,
                                            height: 36.h,
                                            child: Checkbox(
                                              value: isSelected,
                                              onChanged: (_) => cubit
                                                  .toggleSheetOption(
                                                    option.value,
                                                  ),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              activeColor: Colors.white,
                                              checkColor: AppColors.primary,
                                              side: BorderSide(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey[400]!,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              option.label,
                                              style: AppTypography.medium14(
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đã chọn: ${state.sheetStagedSelection.length}',
                              style: AppTypography.bold14(),
                            ),
                            TextButton(
                              onPressed: state.sheetStagedSelection.isEmpty
                                  ? null
                                  : cubit.clearSheetSelection,
                              child: const Text('Xóa tất cả'),
                            ),
                          ],
                        ),
                        if (selectedChips.isNotEmpty) ...[
                          AppSizes.gapH8,
                          SizedBox(
                            height: FilterMultiSelectSheet.chipsAreaHeight(
                              28.h,
                              6.h,
                            ),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 6.w,
                                runSpacing: 6.h,
                                children: selectedChips.map((chip) {
                                  return InputChip(
                                    label: Text(
                                      chip.$2,
                                      style: AppTypography.medium12(
                                        color: Colors.white,
                                      ),
                                    ),
                                    labelPadding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor: AppColors.primary,
                                    deleteIconColor: Colors.white,
                                    onDeleted: () => cubit.removeSheetOption(
                                      chip.$1,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                        AppSizes.gapH8,
                        FilledButton(
                          onPressed: () => _onConfirm(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: Size(double.infinity, 40.h),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Xác nhận',
                            style: AppTypography.medium14(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
