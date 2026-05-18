import 'dart:async';
import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../core/route/app_routes.dart';
import '../../../home/data/models/property_model.dart';
import '../../data/models/map_property_pin.dart';
import '../../data/models/map_visible_bounds.dart';
import '../../map_search_constants.dart';
import '../blocs/map_search/map_search_cubit.dart';
import '../blocs/map_search/map_search_state.dart';
import '../widgets/map_loading_overlay.dart';
import '../widgets/map_location_pin_marker.dart';
import '../widgets/map_property_marker_registry.dart';
import '../widgets/map_search_view.dart';
import '../widgets/map_selection_card_overlay.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  static const double _mapZoom = 14;
  MapLibreMapController? _mapController;
  var _styleLoaded = false;
  MapSearchState? _pendingMapState;
  Symbol? _locationSymbol;
  var _consumeNextMapClick = false;
  var _suppressRegionSearch = false;
  double _latestZoom = _mapZoom;
  Timer? _regionSearchDebounce;
  MapVisibleBounds? _lastSearchBounds;
  final MapPropertyMarkerRegistry _propertyMarkerRegistry =
      MapPropertyMarkerRegistry();

  @override
  void initState() {
    super.initState();
    MapLibreMap.useHybridComposition = true;
  }

  @override
  void dispose() {
    _regionSearchDebounce?.cancel();
    MapLocationPinMarker.reset();
    MapPropertyMarkerRegistry.reset();
    _mapController = null;
    _locationSymbol = null;
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
    _tryApplyMapState();
  }

  void _onSymbolTapped(Symbol symbol) {
    final propertyId = _propertyMarkerRegistry.propertyIdFor(symbol);
    if (propertyId == null || !mounted) {
      return;
    }
    _consumeNextMapClick = true;
    context.read<MapSearchCubit>().selectProperty(propertyId);
  }

  void _onMapClick(Point<double> point, LatLng latLng) {
    if (_consumeNextMapClick) {
      _consumeNextMapClick = false;
      return;
    }
    context.read<MapSearchCubit>().clearSelection();
  }

  void _onStyleLoaded() {
    _styleLoaded = true;
    _tryApplyMapState();
    _scheduleRegionSearch(forceBounds: true);
  }

  void _onCameraMove(CameraPosition position) {
    _latestZoom = position.zoom;
  }

  void _scheduleRegionSearch({bool forceBounds = false}) {
    if (_suppressRegionSearch ||
        !_styleLoaded ||
        _mapController == null ||
        !mounted) {
      return;
    }
    _regionSearchDebounce?.cancel();
    _regionSearchDebounce = Timer(MapSearchConstants.regionSearchDebounce, () {
      if (!mounted) {
        return;
      }
      unawaited(_runRegionSearchIfNeeded(forceBounds: forceBounds));
    });
  }

  Future<void> _runRegionSearchIfNeeded({bool forceBounds = false}) async {
    final controller = _mapController;
    if (controller == null || !_styleLoaded || !mounted) {
      return;
    }
    final cubit = context.read<MapSearchCubit>();
    if (cubit.state.isResolvingLocation) {
      return;
    }
    if (_latestZoom < MapSearchConstants.minZoomToSearch) {
      cubit.clearMapProperties();
      await _propertyMarkerRegistry.clear(controller);
      return;
    }

    try {
      final region = await controller.getVisibleRegion();
      final bounds = MapVisibleBounds.fromLatLngBounds(region);
      if (!forceBounds && !bounds.shouldSearchComparedTo(_lastSearchBounds)) {
        return;
      }
      _lastSearchBounds = bounds;
      if (!mounted) {
        return;
      }

      await cubit.searchInBounds(bounds);
      if (!mounted) {
        return;
      }

      await _syncPropertyMarkers(cubit.state);
    } catch (_) {}
  }

  Future<void> _applyMarkerSelection(String? selectedPropertyId) async {
    final controller = _mapController;

    if (controller == null || !_styleLoaded) {
      return;
    }

    try {
      await _propertyMarkerRegistry.applySelection(
        controller,
        selectedPropertyId,
      );
    } catch (_) {}
  }

  MapPropertyPin? _pinFor(String? propertyId, List<MapPropertyPin> properties) {
    if (propertyId == null) {
      return null;
    }

    final fromRegistry = _propertyMarkerRegistry.pinFor(propertyId);

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

  Future<void> _centerMapOnPin(MapPropertyPin pin) async {
    final controller = _mapController;

    if (controller == null || !_styleLoaded || !mounted) {
      return;
    }
    _suppressRegionSearch = true;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(pin.latitude, pin.longitude),
            zoom: _latestZoom,
          ),
        ),
        duration: MapSearchConstants.selectionCameraDuration,
      );
    } catch (_) {
    } finally {
      _suppressRegionSearch = false;
    }
  }

  Future<void> _onSelectionChanged(MapSearchState state) async {
    final propertyId = state.selectedPropertyId;

    if (propertyId == null) {
      await _applyMarkerSelection(null);
      return;
    }

    await _applyMarkerSelection(propertyId);
    final pin = _pinFor(propertyId, state.properties);
    if (pin == null) {
      return;
    }
    await _centerMapOnPin(pin);
  }

  void _queueMapState(MapSearchState state) {
    if (state.isResolvingLocation) {
      return;
    }
    _pendingMapState = state;
    _tryApplyMapState();
  }

  void _tryApplyMapState() {
    final state = _pendingMapState;
    final controller = _mapController;
    if (!mounted || state == null || controller == null || !_styleLoaded) {
      return;
    }
    unawaited(_applyMapState(controller, state));
  }

  Future<void> _applyMapState(
    MapLibreMapController controller,
    MapSearchState state,
  ) async {
    final target = LatLng(state.latitude, state.longitude);
    try {
      await _syncLocationMarker(controller, target);
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: _mapZoom),
        ),
      );
      _latestZoom = _mapZoom;
      _lastSearchBounds = null;
      _scheduleRegionSearch(forceBounds: true);
    } catch (_) {}
  }

  Future<void> _syncLocationMarker(
    MapLibreMapController controller,
    LatLng target,
  ) async {
    _locationSymbol = await MapLocationPinMarker.sync(
      controller,
      target,
      currentSymbol: _locationSymbol,
    );
  }

  Future<void> _syncPropertyMarkers(MapSearchState state) async {
    final controller = _mapController;
    if (controller == null || !_styleLoaded) {
      return;
    }
    if (state.properties.isEmpty) {
      await _propertyMarkerRegistry.clear(controller);
      return;
    }
    try {
      await _propertyMarkerRegistry.sync(controller, state.properties);
      await _propertyMarkerRegistry.applySelection(
        controller,
        state.selectedPropertyId,
      );
    } catch (_) {}
  }

  void _openPropertyDetails(PropertyModel property) {
    context.pushNamed(
      RouteNames.propertyDetailsPage,
      extra: {'property': property, 'rooms': property.rooms ?? const []},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapSearchCubit, MapSearchState>(
          listenWhen: (previous, current) =>
              previous.isResolvingLocation != current.isResolvingLocation ||
              previous.latitude != current.latitude ||
              previous.longitude != current.longitude,

          listener: (context, state) {
            if (!state.isResolvingLocation) {
              _queueMapState(state);

              _scheduleRegionSearch(forceBounds: true);
            }
          },
        ),

        BlocListener<MapSearchCubit, MapSearchState>(
          listenWhen: (previous, current) =>
              previous.properties != current.properties,

          listener: (context, state) {
            unawaited(_syncPropertyMarkers(state));
          },
        ),

        BlocListener<MapSearchCubit, MapSearchState>(
          listenWhen: (previous, current) =>
              previous.selectedPropertyId != current.selectedPropertyId,

          listener: (context, state) {
            unawaited(_onSelectionChanged(state));
          },
        ),
      ],

      child: Scaffold(
        appBar: AppBar(title: const Text('Tìm trên bản đồ')),
        body: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            MapSearchView(
              initialZoom: _mapZoom,
              onMapCreated: _onMapCreated,
              onStyleLoaded: _onStyleLoaded,
              onCameraMove: _onCameraMove,
              onCameraIdle: _scheduleRegionSearch,
              onMapClick: _onMapClick,
            ),

            BlocBuilder<MapSearchCubit, MapSearchState>(
              buildWhen: (previous, current) =>
                  previous.isResolvingLocation != current.isResolvingLocation ||
                  previous.isLoadingProperties != current.isLoadingProperties ||
                  previous.selectedPropertyId != current.selectedPropertyId ||
                  previous.selectedProperty != current.selectedProperty ||
                  previous.isLoadingSelectedProperty !=
                      current.isLoadingSelectedProperty,
              builder: (context, state) {
                return Stack(
                  children: [
                    MapLoadingOverlay(
                      isResolvingLocation: state.isResolvingLocation,
                      isLoadingProperties: state.isLoadingProperties,
                    ),
                    MapSelectionCardOverlay(
                      state: state,
                      onOpenDetails: _openPropertyDetails,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
