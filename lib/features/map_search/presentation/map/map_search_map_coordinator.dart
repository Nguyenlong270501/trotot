import 'dart:async';
import 'dart:math' show max, min;

import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/constants/map_search_constants.dart';
import '../../data/models/map_property_pin.dart';
import '../../data/models/map_visible_bounds.dart';
import '../blocs/map_search/map_search_cubit.dart';
import '../blocs/map_search/map_search_state.dart';
import 'map_location_pin_marker.dart';
import 'map_property_marker_registry.dart';

class MapSearchMapCoordinator {
  MapSearchMapCoordinator({required this.propertyMarkerRegistry});

  static const double mapZoom = 14;

  final MapPropertyMarkerRegistry propertyMarkerRegistry;

  MapLibreMapController? controller;
  MapSearchState? _pendingMapState;
  Symbol? _locationSymbol;
  var styleLoaded = false;
  var suppressRegionSearch = false;
  var centeringSelection = false;
  double latestZoom = mapZoom;
  MapVisibleBounds? lastSearchBounds;

  bool get isReady => controller != null && styleLoaded;

  void setController(MapLibreMapController value) {
    controller = value;
  }

  void resetController() {
    controller = null;
    _locationSymbol = null;
  }

  void dispose() {
    MapLocationPinMarker.reset();
    MapPropertyMarkerRegistry.reset();
    resetController();
  }

  void markStyleLoaded() {
    styleLoaded = true;
    propertyMarkerRegistry.resetStyle();
  }

  Future<void> restorePropertyMarkersForStyle(MapSearchState state) async {
    final mapController = controller;
    if (mapController == null || !styleLoaded) {
      return;
    }

    try {
      await propertyMarkerRegistry.prepareForStyle(
        mapController,
        state.properties,
        selectedPropertyId: state.selectedPropertyId,
      );
    } catch (_) {}
  }

  void queueMapState(
    MapSearchState state, {
    required VoidCallback tryApplyMapState,
  }) {
    if (state.isResolvingLocation || state.isFilterMode) {
      return;
    }
    _pendingMapState = state;
    tryApplyMapState();
  }

  void tryApplyMapState({
    required bool mounted,
    required void Function({bool forceBounds}) scheduleRegionSearch,
  }) {
    final state = _pendingMapState;
    final mapController = controller;
    if (!mounted || state == null || mapController == null || !styleLoaded) {
      return;
    }
    _pendingMapState = null;
    unawaited(
      applyMapState(
        mapController,
        state,
        scheduleRegionSearch: scheduleRegionSearch,
      ),
    );
  }

  Future<void> applyMapState(
    MapLibreMapController mapController,
    MapSearchState state, {
    required void Function({bool forceBounds}) scheduleRegionSearch,
  }) async {
    final target = LatLng(state.latitude, state.longitude);
    try {
      await syncLocationMarker(mapController, target);
      await mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: mapZoom),
        ),
      );
      latestZoom = mapZoom;
      lastSearchBounds = null;
      scheduleRegionSearch(forceBounds: true);
    } catch (_) {}
  }

  Future<void> syncLocationMarker(
    MapLibreMapController mapController,
    LatLng target,
  ) async {
    _locationSymbol = await MapLocationPinMarker.sync(
      mapController,
      target,
      currentSymbol: _locationSymbol,
    );
  }

  Future<void> syncPropertyMarkers(MapSearchState state) async {
    final mapController = controller;
    if (mapController == null || !styleLoaded) {
      return;
    }
    if (state.properties.isEmpty) {
      await propertyMarkerRegistry.clear(mapController);
      return;
    }
    try {
      await propertyMarkerRegistry.sync(mapController, state.properties);
      await propertyMarkerRegistry.applySelection(
        mapController,
        state.selectedPropertyId,
      );
    } catch (_) {}
  }

  Future<void> clearPropertyMarkers() async {
    final mapController = controller;
    if (mapController == null || !styleLoaded) {
      return;
    }
    await propertyMarkerRegistry.clear(mapController);
  }

  Future<void> applyMarkerSelection(String? selectedPropertyId) async {
    final mapController = controller;

    if (mapController == null || !styleLoaded) {
      return;
    }

    try {
      await propertyMarkerRegistry.applySelection(
        mapController,
        selectedPropertyId,
      );
    } catch (_) {}
  }

  MapPropertyPin? pinFor(
    String? propertyId,
    List<MapPropertyPin> properties,
  ) {
    if (propertyId == null) {
      return null;
    }

    final fromRegistry = propertyMarkerRegistry.pinFor(propertyId);

    if (fromRegistry != null) {
      return fromRegistry;
    }

    for (final pin in properties) {
      if (pin.propertyId == propertyId) {
        return pin;
      }
    }

    return null;
  }

  Future<void> centerMapOnPin(MapPropertyPin pin, {required bool mounted}) async {
    final mapController = controller;

    if (mapController == null || !styleLoaded || !mounted) {
      return;
    }
    centeringSelection = true;
    suppressRegionSearch = true;

    try {
      await mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(pin.latitude, pin.longitude)),
        duration: MapSearchConstants.selectionCameraDuration,
      );
      final position = await mapController.queryCameraPosition();
      if (position != null) {
        latestZoom = position.zoom;
      }
    } catch (_) {
    } finally {
      centeringSelection = false;
      suppressRegionSearch = false;
    }
  }

  Future<void> fitCameraToPins(
    List<MapPropertyPin> pins, {
    required bool mounted,
  }) async {
    final mapController = controller;
    if (mapController == null || !styleLoaded || !mounted || pins.isEmpty) {
      return;
    }

    suppressRegionSearch = true;
    try {
      var minLat = pins.first.latitude;
      var maxLat = minLat;
      var minLng = pins.first.longitude;
      var maxLng = minLng;

      for (final pin in pins.skip(1)) {
        minLat = min(minLat, pin.latitude);
        maxLat = max(maxLat, pin.latitude);
        minLng = min(minLng, pin.longitude);
        maxLng = max(maxLng, pin.longitude);
      }

      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;
      final latSpan = (maxLat - minLat).abs();
      final lngSpan = (maxLng - minLng).abs();
      final span = max(latSpan, lngSpan);
      final zoom = span < 0.01
          ? 15.0
          : span < 0.05
          ? 13.5
          : span < 0.15
          ? 12.0
          : 11.0;

      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(centerLat, centerLng), zoom: zoom),
        ),
        duration: MapSearchConstants.selectionCameraDuration,
      );
      final position = await mapController.queryCameraPosition();
      if (position != null) {
        latestZoom = position.zoom;
      }
    } catch (_) {
    } finally {
      suppressRegionSearch = false;
    }
  }

  Future<bool> animateTo(
    LatLng target, {
    required double zoom,
    required bool mounted,
  }) async {
    final mapController = controller;
    if (mapController == null || !styleLoaded || !mounted) {
      return false;
    }

    suppressRegionSearch = true;
    try {
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
        duration: MapSearchConstants.selectionCameraDuration,
      );
      final position = await mapController.queryCameraPosition();
      latestZoom = position?.zoom ?? zoom;
      lastSearchBounds = null;
      return true;
    } catch (_) {
      return false;
    } finally {
      suppressRegionSearch = false;
    }
  }

  Future<void> runRegionSearchIfNeeded(
    MapSearchCubit cubit, {
    required bool forceBounds,
    required bool mounted,
  }) async {
    final mapController = controller;
    if (mapController == null || !styleLoaded || !mounted) {
      return;
    }
    if (cubit.state.isResolvingLocation || cubit.state.isFilterMode) {
      return;
    }
    if (latestZoom < MapSearchConstants.minZoomToSearch) {
      cubit.clearMapProperties();
      await clearPropertyMarkers();
      return;
    }

    try {
      final region = await mapController.getVisibleRegion();
      final bounds = MapVisibleBounds.fromLatLngBounds(region);
      if (!forceBounds && !bounds.shouldSearchComparedTo(lastSearchBounds)) {
        return;
      }
      lastSearchBounds = bounds;
      if (!mounted) {
        return;
      }

      await cubit.searchInBounds(bounds);
      if (!mounted) {
        return;
      }

      await syncPropertyMarkers(cubit.state);
    } catch (_) {}
  }

  Future<({double latitude, double longitude})> placeSearchBias(
    MapSearchState state,
  ) async {
    var biasLatitude = state.latitude;
    var biasLongitude = state.longitude;
    final mapController = controller;
    if (mapController != null && styleLoaded) {
      try {
        final position = await mapController.queryCameraPosition();
        final target = position?.target;
        if (target != null) {
          biasLatitude = target.latitude;
          biasLongitude = target.longitude;
        }
      } catch (_) {}
    }

    return (latitude: biasLatitude, longitude: biasLongitude);
  }
}
