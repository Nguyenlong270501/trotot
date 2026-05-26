import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/widgets/app_alerts.dart';
import '../../../search/blocs/room_filter/room_filter_cubit.dart';
import '../../data/models/goong_place_detail_model.dart';
import '../blocs/map_place_search/map_place_search_cubit.dart';
import '../blocs/map_search/map_search_cubit.dart';
import '../map/map_search_map_coordinator.dart';

class MapPlaceSearchFlowController {
  MapPlaceSearchFlowController({
    required this.mapCoordinator,
    required this.mapCubit,
    required this.mounted,
    required this.scheduleRegionSearch,
  });

  final MapSearchMapCoordinator mapCoordinator;
  final MapSearchCubit? Function() mapCubit;
  final bool Function() mounted;
  final void Function({bool forceBounds}) scheduleRegionSearch;

  Future<void> refreshBias(BuildContext context) async {
    final cubit = mapCubit();
    if (cubit == null) {
      return;
    }

    final bias = await mapCoordinator.placeSearchBias(cubit.state);

    if (!mounted()) {
      return;
    }

    context.read<MapPlaceSearchCubit>().updateBias(
      latitude: bias.latitude,
      longitude: bias.longitude,
    );
  }

  Future<void> moveToPlace(
    BuildContext context,
    GoongPlaceDetailModel place,
  ) async {
    final cubit = mapCubit();
    if (!mapCoordinator.isReady || cubit == null || !mounted()) {
      return;
    }

    if (cubit.state.isFilterMode) {
      await context.read<RoomFilterCubit>().stopFilterWatch();
      if (!mounted()) return;
      cubit.exitFilterMode();
      await mapCoordinator.clearPropertyMarkers();
    } else {
      cubit.clearSelection();
    }

    final moved = await mapCoordinator.animateTo(
      LatLng(place.latitude, place.longitude),
      zoom: MapSearchMapCoordinator.mapZoom,
      mounted: mounted(),
    );
    if (!moved && mounted()) {
      Alerts.of(context).showError('Không thể di chuyển tới địa điểm này');
    }

    scheduleRegionSearch(forceBounds: true);
  }
}
