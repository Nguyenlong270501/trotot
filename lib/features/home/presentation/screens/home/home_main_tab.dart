import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../blocs/home_suggested_rooms/home_suggested_rooms_cubit.dart';
import '../../../blocs/home_suggested_rooms/home_suggested_rooms_state.dart';
import '../../../../search/blocs/room_filter/room_filter_cubit.dart';
import '../../../data/models/property_model.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/category_item.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/property_card/property_card.dart';

class HomeMainTab extends StatelessWidget {
  const HomeMainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Container(
            height: 55.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.all(Radius.circular(28)),
            ),
            child: const MyAppBar(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.fromLTRB(10.h, 10.h, 10.h, 0),
            child: Column(
              children: [
                BlocSelector<
                  HomeSuggestedRoomsCubit,
                  HomeSuggestedRoomsState,
                  String
                >(
                  selector: (state) => state.selectedCity,
                  builder: (context, selectedCity) {
                    return SearchBarCard(
                      onTap: () {
                        context.read<RoomFilterCubit>().setCity(
                          selectedCity,
                          resetWard: true,
                        );
                        context.push(RouteNames.searchPage);
                      },
                      locationName: selectedCity,
                      cityOptions: PropertyConstants.cities,
                      onCitySelected: (city) => context
                          .read<HomeSuggestedRoomsCubit>()
                          .changeCity(city),
                    );
                  },
                ),
                AppSizes.gapH12,
                Container(
                  padding: EdgeInsets.fromLTRB(10.h, 10.h, 10.h, 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSizes.gapH8,
                      const _CategoryLabel(),
                      AppSizes.gapH16,
                      const _SuggestionSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel();

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
    return BlocBuilder<HomeSuggestedRoomsCubit, HomeSuggestedRoomsState>(
      builder: (context, state) {
        final selectedCategory = state.selectedCategory;
        final disabledTypes = state.disabledCategoryTypes;
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
                  isActive: selectedCategory ==
                      PropertyConstants.normalizePropertyType(
                        _categories[i].propertyType,
                      ),
                  isDisabled: disabledTypes.contains(
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

class _SuggestionSection extends StatelessWidget {
  const _SuggestionSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gợi ý cho bạn',
              style: AppTypography.bold18(color: AppColors.accent),
            ),
          ],
        ),
        AppSizes.gapH12,
        BlocBuilder<HomeSuggestedRoomsCubit, HomeSuggestedRoomsState>(
          builder: (context, state) {
            switch (state) {
              case HomeSuggestedRoomsLoaded(
                :final properties,
                :final isRefreshingCategory,
              ):
                final withRooms = properties
                    .where((p) => (p.rooms ?? []).isNotEmpty)
                    .toList();
                if (withRooms.isEmpty) {
                  return SizedBox(
                    height: 120.h,
                    child: Center(
                      child: isRefreshingCategory
                          ? const CircularProgressIndicator(
                              color: AppColors.accent,
                            )
                          : Text(
                              'Chưa có phòng trống',
                              style: AppTypography.medium14(
                                color: AppColors.textPrimary,
                              ),
                            ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isRefreshingCategory) ...[
                      const LinearProgressIndicator(
                        minHeight: 2,
                        color: AppColors.accent,
                      ),
                      AppSizes.gapH12,
                    ],
                    for (var i = 0; i < withRooms.length; i++) ...[
                      if (i > 0) AppSizes.gapH16,
                      _PropertyCardFromFirstRoom(property: withRooms[i]),
                    ],
                  ],
                );
              case HomeSuggestedRoomsFailure(:final message):
                return SizedBox(
                  height: 200.h,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: AppTypography.medium14(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AppSizes.gapH8,
                        TextButton(
                          onPressed: () =>
                              context.read<HomeSuggestedRoomsCubit>().watch(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              case HomeSuggestedRoomsLoading():
              case HomeSuggestedRoomsInitial():
                return SizedBox(
                  height: 200.h,
                  child: const Center(child: CircularProgressIndicator()),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}

class _PropertyCardFromFirstRoom extends StatelessWidget {
  const _PropertyCardFromFirstRoom({required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    return PropertyCard(
      property: property,
      onTap: () {
        context.push(
          RouteNames.propertyDetailsPage,
          extra: {'property': property, 'rooms': property.rooms ?? []},
        );
      },
    );
  }
}
