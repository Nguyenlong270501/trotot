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
import 'widgets/app_bar.dart';
import 'widgets/home_category_bar.dart';
import 'widgets/search_bar.dart';
import '../../widgets/property_card.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
            sliver: SliverToBoxAdapter(
              child:
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
                        onMapTap: () {
                          context.push(RouteNames.mapSearchPage);
                        },
                        onCitySelected: (city) => context
                            .read<HomeSuggestedRoomsCubit>()
                            .changeCity(city),
                      );
                    },
                  ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 14.h),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSizes.gapH4,
                    const HomeCategoryBar(),
                    const _CategoryRefreshIndicator(),
                  ],
                ),
              ),
            ),
          ),
          const _SuggestionFeedSliver(),
          SliverPadding(padding: EdgeInsets.only(bottom: 16.h)),
        ],
      ),
    );
  }
}

class _CategoryRefreshIndicator extends StatelessWidget {
  const _CategoryRefreshIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeSuggestedRoomsCubit, HomeSuggestedRoomsState, bool>(
      selector: (state) =>
          state is HomeSuggestedRoomsLoaded && state.isRefreshingCategory,
      builder: (context, isRefreshing) {
        if (!isRefreshing) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            AppSizes.gapH8,
            LinearProgressIndicator(minHeight: 2, color: AppColors.accent),
            AppSizes.gapH8,
          ],
        );
      },
    );
  }
}

class _SuggestionFeedSliver extends StatelessWidget {
  const _SuggestionFeedSliver();

  static bool _feedBuildWhen(
    HomeSuggestedRoomsState previous,
    HomeSuggestedRoomsState current,
  ) {
    if (previous.runtimeType != current.runtimeType) {
      return true;
    }
    if (previous is HomeSuggestedRoomsLoaded &&
        current is HomeSuggestedRoomsLoaded) {
      return previous.properties != current.properties;
    }
    if (previous is HomeSuggestedRoomsFailure &&
        current is HomeSuggestedRoomsFailure) {
      return previous.message != current.message;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeSuggestedRoomsCubit, HomeSuggestedRoomsState>(
      buildWhen: _feedBuildWhen,
      builder: (context, state) {
        switch (state) {
          case HomeSuggestedRoomsLoaded(:final properties):
            final withRooms = properties
                .where((p) => (p.rooms ?? []).isNotEmpty)
                .toList();
            if (withRooms.isEmpty) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120.h,
                    child: Center(
                      child: Text(
                        'Chưa có phòng trống',
                        style: AppTypography.medium14(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              sliver: SliverList.separated(
                itemCount: withRooms.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final property = withRooms[index];
                  return RepaintBoundary(
                    child: _PropertyCardFromFirstRoom(property: property),
                  );
                },
              ),
            );
          case HomeSuggestedRoomsFailure(:final message):
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
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
                ),
              ),
            );
          case HomeSuggestedRoomsLoading():
          case HomeSuggestedRoomsInitial():
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 200.h,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          default:
            return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
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
