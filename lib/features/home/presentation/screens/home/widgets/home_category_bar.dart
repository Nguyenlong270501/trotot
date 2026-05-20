import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/constants/property_constants.dart';
import '../../../../blocs/home_suggested_rooms/home_suggested_rooms_cubit.dart';
import '../../../../blocs/home_suggested_rooms/home_suggested_rooms_state.dart';
import 'category_item.dart';

/// Category chips — rebuilds only when selection or disabled set changes.
class HomeCategoryBar extends StatelessWidget {
  const HomeCategoryBar({super.key});

  static final _categories = [
    (
      icon: Icons.cottage_outlined,
      label: 'PHÒNG TRỌ',
      propertyType: PropertyConstants.propertyTypes[0],
    ),
    (
      icon: Icons.apartment_rounded,
      label: 'CHUNG CƯ',
      propertyType: PropertyConstants.propertyTypes[1],
    ),
    (
      icon: Icons.home_work_outlined,
      label: 'NGUYÊN CĂN',
      propertyType: PropertyConstants.propertyTypes[4],
    ),
    (
      icon: Icons.bed_outlined,
      label: 'Ở GHÉP',
      propertyType: PropertyConstants.propertyTypes[3],
    ),
    (
      icon: Icons.house_outlined,
      label: 'STUDIO',
      propertyType: PropertyConstants.propertyTypes[2],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      HomeSuggestedRoomsCubit,
      HomeSuggestedRoomsState,
      ({String? selected, Set<String> disabled})
    >(
      selector: (state) => (
        selected: state.selectedCategory,
        disabled: state.disabledCategoryTypes,
      ),
      builder: (context, data) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _categories.length; i++) ...[
                if (i > 0) AppSizes.gapW10,
                CategoryItem(
                  icon: _categories[i].icon,
                  label: _categories[i].label,
                  isActive:
                      data.selected ==
                      PropertyConstants.normalizePropertyType(
                        _categories[i].propertyType,
                      ),
                  isDisabled: data.disabled.contains(
                    PropertyConstants.normalizePropertyType(
                      _categories[i].propertyType,
                    ),
                  ),
                  onTap: () => context
                      .read<HomeSuggestedRoomsCubit>()
                      .selectCategory(_categories[i].propertyType),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
