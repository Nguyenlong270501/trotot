import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../blocs/room_filter/room_filter_cubit.dart';
import '../../../blocs/room_filter/room_filter_state.dart';
import '../../../../home/data/models/room_filter_draft.dart';
import 'amenity_filter_group.dart';
import 'city_dropdown.dart';
import 'filter_multi_select_field.dart';
import 'filter_sheet_options.dart';
import 'price_bracket_filter.dart';

/// Pure filter form sections for SearchScreen and map filter sheet.
class RoomFilterFormSlivers extends StatelessWidget {
  const RoomFilterFormSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = context.select<RoomFilterCubit, RoomFilterDraft>(
      (cubit) => cubit.state.draft,
    );
    final city = draft.city;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text('Thành phố', style: AppTypography.bold14()),
          AppSizes.gapH8,
          CityDropdown(city: city),
          AppSizes.gapH20,
          Text('Xã / Phường', style: AppTypography.bold14()),
          AppSizes.gapH8,
          FilterMultiSelectField(
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
          Text('Loại hình nhà cho thuê', style: AppTypography.bold14()),
          AppSizes.gapH8,
          FilterMultiSelectField(
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
            onSelected: (index) =>
                context.read<RoomFilterCubit>().togglePriceBracket(index),
          ),
          AppSizes.gapH20,
          Text('Tiện ích phòng', style: AppTypography.bold14()),
          AppSizes.gapH8,
          AmenityFilterGroup(
            options: PropertyConstants.roomAmenities,
            selectedLabels: draft.selectedAmenityLabels,
            onToggle: (label) =>
                context.read<RoomFilterCubit>().toggleAmenityLabel(label),
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
            onToggle: (label) =>
                context.read<RoomFilterCubit>().toggleAmenityLabel(label),
          ),
          AppSizes.gapH24,
        ]),
      ),
    );
  }
}
