import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../home/data/models/property_model.dart';
import '../../../search/blocs/room_filter/room_filter_cubit.dart';
import '../../blocs/map_search/map_search_cubit.dart';
import '../map/map_search_map_coordinator.dart';
import '../widgets/map_filter_bottom_sheet.dart';

class MapFilterFlowController {
  MapFilterFlowController({
    required this.isSheetOpenNotifier,
    required this.mapCoordinator,
    required this.mapCubit,
    required this.mounted,
    required this.scheduleRegionSearch,
  });

  final ValueNotifier<bool> isSheetOpenNotifier;
  final MapSearchMapCoordinator mapCoordinator;
  final MapSearchCubit? Function() mapCubit;
  final bool Function() mounted;
  final void Function({bool forceBounds}) scheduleRegionSearch;

  void applyFromSheet(BuildContext context, List<PropertyModel> results) {
    if (!mounted()) {
      return;
    }

    final cubit = mapCubit();
    if (cubit == null) {
      return;
    }

    cubit.applyFilterResults(results);
    cubit.focusFirstFilterProperty();
    unawaited(syncAndFitResults());

    if (results.isEmpty) {
      Alerts.of(context).showError('Không tìm thấy phòng phù hợp với bộ lọc');
    }
  }

  Future<void> syncAndFitResults() async {
    final cubit = mapCubit();
    if (cubit == null || !cubit.state.isFilterMode) {
      return;
    }

    await mapCoordinator.syncPropertyMarkers(cubit.state);
    final pin = mapCoordinator.pinFor(
      cubit.state.focusedFilterPropertyId,
      cubit.state.properties,
    );
    if (pin != null) {
      await mapCoordinator.fitCameraToPins(
        [pin],
        mounted: mounted(),
      );
    }
  }

  void applyRealtimeUpdate(BuildContext context, List<PropertyModel> results) {
    if (!mounted()) {
      return;
    }

    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return;
    }

    final cubit = mapCubit();
    if (cubit == null || !cubit.state.isFilterMode) {
      return;
    }

    final previousFocusedPropertyId = cubit.state.focusedFilterPropertyId;
    cubit.applyFilterResults(results);
    unawaited(
      syncRealtimeResults(
        shouldFocus:
            cubit.state.focusedFilterPropertyId != previousFocusedPropertyId,
      ),
    );
  }

  Future<void> syncRealtimeResults({required bool shouldFocus}) async {
    final cubit = mapCubit();
    if (cubit == null || !cubit.state.isFilterMode) {
      return;
    }

    await mapCoordinator.syncPropertyMarkers(cubit.state);
    if (!shouldFocus) {
      return;
    }

    final pin = mapCoordinator.pinFor(
      cubit.state.focusedFilterPropertyId,
      cubit.state.properties,
    );
    if (pin != null) {
      await mapCoordinator.centerMapOnPin(pin, mounted: mounted());
    }
  }

  Future<void> openSheet(BuildContext context) async {
    if (isSheetOpenNotifier.value) {
      return;
    }
    isSheetOpenNotifier.value = true;
    try {
      await showMapFilterBottomSheet(
        context,
        onFilterApplied: (results) => applyFromSheet(context, results),
      );
    } finally {
      if (mounted()) {
        isSheetOpenNotifier.value = false;
      }
    }
  }

  Future<void> clear(BuildContext context) async {
    await context.read<RoomFilterCubit>().stopFilterWatch();
    context.read<MapSearchCubit>().exitFilterMode();
    await mapCoordinator.clearPropertyMarkers();
    mapCoordinator.lastSearchBounds = null;
    scheduleRegionSearch(forceBounds: true);
  }
}
