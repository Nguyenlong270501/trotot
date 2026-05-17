import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/property_constants.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../home/data/models/room_filter_draft.dart';
import '../../blocs/room_filter/room_filter_cubit.dart';
import '../../blocs/room_filter/room_filter_state.dart';
import 'widgets/amenity_filter_group.dart';
import 'widgets/city_dropdown.dart';
import 'widgets/filter_multi_select_field.dart';
import 'widgets/filter_sheet_options.dart';
import 'widgets/price_bracket_filter.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomFilterCubit, RoomFilterState>(
      listenWhen: (prev, curr) {
        final readyForResults =
            prev.isApplying &&
            !curr.isApplying &&
            curr.applyError == null &&
            curr.isWatchingFilterResults;
        final hasNewError =
            curr.applyError != null &&
            curr.applyError != prev.applyError &&
            !curr.isApplying;
        return readyForResults || hasNewError;
      },
      listener: (context, state) {
        if (!state.isApplying &&
            state.applyError == null &&
            state.isWatchingFilterResults) {
          context.push(RouteNames.filterResultsPage);
          return;
        }
        final err = state.applyError;
        if (err != null && err.isNotEmpty) {
          Alerts.of(context).showError(err);
        }
      },
      builder: (context, state) {
        final draft = state.draft;
        final city = draft.city;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lọc tìm phòng'),
            centerTitle: true,
            leading: BackButton(onPressed: () => context.pop()),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                onPressed: draft == RoomFilterDraft.initial
                    ? null
                    : () =>
                          context.read<RoomFilterCubit>().resetDraftToInitial(),
                child: const Text('Đặt lại'),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Thành phố', style: AppTypography.bold14()),
                      AppSizes.gapH8,
                      CityDropdown(city: city),
                      AppSizes.gapH20,
                      FilterMultiSelectField(
                        label: 'Xã / Phường',
                        sheetType: FilterSheetType.ward,
                        sheetTitle: 'Chọn phường/xã',
                        searchHint: 'Nhập nội dung tìm kiếm',
                        placeholder: 'Chọn phường/xã',
                        city: city,
                        selected: draft.selectedWards,
                        buildOptions: buildWardSheetOptions,
                        isWard: true,
                      ),
                      AppSizes.gapH20,
                      FilterMultiSelectField(
                        label: 'Loại hình nhà cho thuê',
                        sheetType: FilterSheetType.propertyType,
                        sheetTitle: 'Chọn loại hình nhà cho thuê',
                        searchHint: 'Nhập nội dung tìm kiếm',
                        placeholder: 'Chọn loại hình nhà cho thuê',
                        city: city,
                        selected: draft.selectedPropertyTypes,
                        buildOptions: (_) => buildPropertyTypeSheetOptions(),
                        isWard: false,
                      ),
                      AppSizes.gapH20,
                      Text(
                        'Mức giá (có thể chọn nhiều)',
                        style: AppTypography.bold14(),
                      ),
                      AppSizes.gapH8,
                      PriceBracketFilter(
                        selectedIndexes: draft.selectedPriceBracketIndexes,
                        onSelected: (index) => context
                            .read<RoomFilterCubit>()
                            .togglePriceBracket(index),
                      ),
                      AppSizes.gapH20,
                      Text('Tiện ích phòng', style: AppTypography.bold14()),
                      AppSizes.gapH8,
                      AmenityFilterGroup(
                        options: PropertyConstants.roomAmenities,
                        selectedLabels: draft.selectedAmenityLabels,
                        onToggle: (label) => context
                            .read<RoomFilterCubit>()
                            .toggleAmenityLabel(label),
                      ),
                      AppSizes.gapH16,
                      Text(
                        'Tiện ích nhà cho thuê',
                        style: AppTypography.bold14(),
                      ),
                      AppSizes.gapH8,
                      AmenityFilterGroup(
                        options: PropertyConstants.amenities,
                        selectedLabels: draft.selectedAmenityLabels,
                        onToggle: (label) => context
                            .read<RoomFilterCubit>()
                            .toggleAmenityLabel(label),
                      ),
                      AppSizes.gapH24,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  0,
                  16.w,
                  16.h + MediaQuery.paddingOf(context).bottom,
                ),
                child: FilledButton(
                  onPressed: state.isApplying
                      ? null
                      : () => context.read<RoomFilterCubit>().applyFilter(),
                  child: state.isApplying
                      ? SizedBox(
                          height: 22.h,
                          width: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
