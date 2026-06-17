import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../home/data/models/property_model.dart';
import '../../data/models/goong_place_detail_model.dart';
import '../../blocs/map_search/map_search_cubit.dart';
import '../../blocs/map_search/map_search_state.dart';
import '../../blocs/map_search/filter_marker_focus.dart';
import 'map_filter_result_bar.dart';
import 'map_loading_overlay.dart';
import 'map_search_map_controls.dart';
import 'map_search_top_bar.dart';
import 'map_selection_card_overlay.dart';

class MapSearchOverlays extends StatelessWidget {
  const MapSearchOverlays({
    super.key,
    required this.isFilterSheetOpenListenable,
    required this.isPlaceSearchFocusedListenable,
    required this.topBarController,
    required this.onOpenDetails,
    required this.onClearFilter,
    required this.onRefreshPlaceSearchBias,
    required this.onPlaceSearchFocusChanged,
    required this.onPlaceSelected,
    required this.onMyLocationTap,
    required this.onPreviousFilterMarker,
    required this.onNextFilterMarker,
  });

  final ValueListenable<bool> isFilterSheetOpenListenable;
  final ValueListenable<bool> isPlaceSearchFocusedListenable;
  final MapSearchTopBarController topBarController;
  final void Function(PropertyModel property) onOpenDetails;
  final Future<void> Function() onClearFilter;
  final Future<void> Function() onRefreshPlaceSearchBias;
  final ValueChanged<bool> onPlaceSearchFocusChanged;
  final Future<void> Function(GoongPlaceDetailModel place) onPlaceSelected;
  final VoidCallback onMyLocationTap;
  final Future<void> Function() onPreviousFilterMarker;
  final Future<void> Function() onNextFilterMarker;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        BlocBuilder<MapSearchCubit, MapSearchState>(
          buildWhen: (previous, current) =>
              previous.isResolvingLocation != current.isResolvingLocation ||
              previous.isLoadingProperties != current.isLoadingProperties ||
              previous.selectedPropertyId != current.selectedPropertyId ||
              previous.selectedProperty != current.selectedProperty ||
              previous.isLoadingSelectedProperty !=
                  current.isLoadingSelectedProperty ||
              previous.selectedPropertyError != current.selectedPropertyError ||
              previous.isFilterMode != current.isFilterMode ||
              previous.filteredResultCount != current.filteredResultCount ||
              previous.filteredPinnedCount != current.filteredPinnedCount ||
              previous.focusedFilterPropertyId !=
                  current.focusedFilterPropertyId,
          builder: (context, state) {
            return Stack(
              fit: StackFit.expand,
              children: [
                MapLoadingOverlay(
                  isResolvingLocation: state.isResolvingLocation,
                  isLoadingProperties: state.isLoadingProperties,
                  top: 72,
                ),
                MapSelectionCardOverlay(
                  state: state,
                  onOpenDetails: onOpenDetails,
                ),
                if (state.isFilterMode && state.selectedPropertyId == null)
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 24.h,
                    child: SafeArea(
                      top: false,
                      child: MapFilterResultBar(
                        count: state.filteredResultCount,
                        pinnedCount: state.filteredPinnedCount,
                        focusedIndex: FilterMarkerFocus.oneBasedIndexOf(
                          state.properties,
                          state.focusedFilterPropertyId,
                        ),
                        onPrevious: () =>
                            unawaited(onPreviousFilterMarker()),
                        onNext: () => unawaited(onNextFilterMarker()),
                        onClear: () => unawaited(onClearFilter()),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isFilterSheetOpenListenable,
          builder: (context, isFilterSheetOpen, child) {
            if (isFilterSheetOpen) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: 16.w,
              right: 16.w,
              top: 12.h,
              child: MapSearchTopBar(
                controller: topBarController,
                onFocus: () => unawaited(onRefreshPlaceSearchBias()),
                onFocusChanged: onPlaceSearchFocusChanged,
                onPlaceSelected: onPlaceSelected,
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isPlaceSearchFocusedListenable,
          builder: (context, isFocused, child) {
            if (isFocused) {
              return const SizedBox.shrink();
            }
            return MapSearchMapControls(
              top: 72,
              onMyLocationTap: onMyLocationTap,
            );
          },
        ),
      ],
    );
  }
}
