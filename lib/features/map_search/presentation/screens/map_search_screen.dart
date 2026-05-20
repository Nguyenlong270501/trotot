import 'dart:async';
import 'dart:math' show Point, max, min;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../home/data/models/property_model.dart';
import '../../../search/blocs/room_filter/room_filter_cubit.dart';
import '../../../search/blocs/room_filter/room_filter_state.dart';
import '../../data/models/goong_place_detail_model.dart';
import '../../data/models/map_property_pin.dart';
import '../../data/models/map_visible_bounds.dart';
import '../../../../core/constants/map_search_constants.dart';
import '../blocs/map_place_search/map_place_search_cubit.dart';
import '../blocs/map_search/map_search_cubit.dart';
import '../blocs/map_search/map_search_state.dart';
import '../map/map_location_pin_marker.dart';
import '../map/map_property_marker_registry.dart';
import '../widgets/map_filter_bottom_sheet.dart';
import '../widgets/map_filter_result_bar.dart';
import '../widgets/map_loading_overlay.dart';
import '../widgets/map_search_map_controls.dart';
import '../widgets/map_search_top_bar.dart';
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
  DateTime? _lastMarkerTapAt;
  var _suppressRegionSearch = false;
  var _centeringSelection = false;
  double _latestZoom = _mapZoom;
  Timer? _regionSearchDebounce;
  MapVisibleBounds? _lastSearchBounds;
  var _fitFilterPinsOnNextSync = false;
  var _didInitializeMapSearch = false;
  MapSearchCubit? _mapSearchCubit;
  final ValueNotifier<bool> _isFilterSheetOpenNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<bool> _isPlaceSearchFocusedNotifier = ValueNotifier<bool>(
    false,
  );
  final MapSearchTopBarController _placeSearchTopBarController =
      MapSearchTopBarController();
  final MapPropertyMarkerRegistry _propertyMarkerRegistry =
      MapPropertyMarkerRegistry();

  @override
  void initState() {
    super.initState();
    MapLibreMap.useHybridComposition = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInitializeMapSearch) {
        return;
      }
      _didInitializeMapSearch = true;
      final cubit = context.read<MapSearchCubit>();
      _mapSearchCubit = cubit;
      _queueCurrentMapState();
      unawaited(cubit.initialize());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapSearchCubit = context.read<MapSearchCubit>();
    _queueCurrentMapState();
  }

  @override
  void dispose() {
    _regionSearchDebounce?.cancel();
    MapLocationPinMarker.reset();
    MapPropertyMarkerRegistry.reset();
    _isFilterSheetOpenNotifier.dispose();
    _isPlaceSearchFocusedNotifier.dispose();
    _mapController = null;
    _locationSymbol = null;
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onFeatureTapped.add(_onFeatureTapped);
    _tryApplyMapState();
  }

  void _onFeatureTapped(
    Point<double> point,
    LatLng latLng,
    String id,
    String layerId,
    Annotation? annotation,
  ) {
    if (layerId != MapPropertyMarkerRegistry.layerId || !mounted) {
      return;
    }
    _lastMarkerTapAt = DateTime.now();
    unawaited(_selectPropertyFeatureAt(point, fallbackPropertyId: id));
  }

  bool _isWithinMarkerTapGracePeriod() {
    final tappedAt = _lastMarkerTapAt;
    if (tappedAt == null) {
      return false;
    }
    return DateTime.now().difference(tappedAt) <
        const Duration(milliseconds: 280);
  }

  void _dismissSelection() {
    final cubit = context.read<MapSearchCubit>();
    if (cubit.state.selectedPropertyId == null) {
      return;
    }
    cubit.clearSelection();
  }

  Future<bool> _selectPropertyFeatureAt(
    Point<double> point, {
    String? fallbackPropertyId,
  }) async {
    final controller = _mapController;
    if (controller == null || !_styleLoaded || !mounted) {
      return false;
    }

    try {
      final features = await controller.queryRenderedFeatures(
        point,
        [MapPropertyMarkerRegistry.layerId],
        null,
      );
      for (final feature in features) {
        final propertyId = _propertyIdFromRenderedFeature(feature);
        if (propertyId != null &&
            _propertyMarkerRegistry.containsProperty(propertyId)) {
          _lastMarkerTapAt = DateTime.now();
          if (!mounted) {
            return true;
          }
          context.read<MapSearchCubit>().selectProperty(propertyId);
          return true;
        }
      }
    } catch (_) {}

    if (fallbackPropertyId != null &&
        _propertyMarkerRegistry.containsProperty(fallbackPropertyId)) {
      _lastMarkerTapAt = DateTime.now();
      context.read<MapSearchCubit>().selectProperty(fallbackPropertyId);
      return true;
    }

    return false;
  }

  String? _propertyIdFromRenderedFeature(Object? feature) {
    if (feature is! Map) {
      return null;
    }

    final directPropertyId = _stringValue(feature['propertyId']);
    if (directPropertyId != null) {
      return directPropertyId;
    }

    final properties = feature['properties'];
    final fromProperties = _propertyIdFromMap(properties);
    if (fromProperties != null) {
      return fromProperties;
    }

    final attributes = feature['attributes'];
    return _propertyIdFromMap(attributes);
  }

  String? _propertyIdFromMap(Object? value) {
    if (value is! Map) {
      return null;
    }
    return _stringValue(value['propertyId']);
  }

  String? _stringValue(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  void _onMapClick(Point<double> point, LatLng latLng) {
    unawaited(_handleMapClick(point));
  }

  Future<void> _handleMapClick(Point<double> point) async {
    if (_isWithinMarkerTapGracePeriod()) {
      return;
    }
    if (await _selectPropertyFeatureAt(point)) {
      return;
    }
    _placeSearchTopBarController.unfocus();
    _dismissSelection();
  }

  void _onStyleLoaded() {
    _styleLoaded = true;
    _propertyMarkerRegistry.resetStyle();
    unawaited(_restorePropertyMarkersForStyle());
    _tryApplyMapState();
    _scheduleRegionSearch(forceBounds: true);
  }

  Future<void> _restorePropertyMarkersForStyle() async {
    final controller = _mapController;
    final cubit = _mapSearchCubit;
    if (controller == null || cubit == null || !_styleLoaded) {
      return;
    }

    try {
      await _propertyMarkerRegistry.prepareForStyle(
        controller,
        cubit.state.properties,
        selectedPropertyId: cubit.state.selectedPropertyId,
      );
    } catch (_) {}
  }

  void _onCameraMove(CameraPosition position) {
    if (!_centeringSelection) {
      _latestZoom = position.zoom;
      context.read<MapPlaceSearchCubit>().updateBias(
        latitude: position.target.latitude,
        longitude: position.target.longitude,
      );
    }
  }

  void _onCameraIdle() {
    _scheduleRegionSearch();
  }

  void _scheduleRegionSearch({bool forceBounds = false}) {
    if (_suppressRegionSearch ||
        !_styleLoaded ||
        _mapController == null ||
        !mounted ||
        context.read<MapSearchCubit>().state.isFilterMode) {
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
    if (cubit.state.isResolvingLocation || cubit.state.isFilterMode) {
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
    _centeringSelection = true;
    _suppressRegionSearch = true;

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(pin.latitude, pin.longitude)),
        duration: MapSearchConstants.selectionCameraDuration,
      );
      final position = await controller.queryCameraPosition();
      if (position != null) {
        _latestZoom = position.zoom;
      }
    } catch (_) {
    } finally {
      _centeringSelection = false;
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
    if (state.isResolvingLocation || state.isFilterMode) {
      return;
    }
    _pendingMapState = state;
    _tryApplyMapState();
  }

  void _queueCurrentMapState() {
    final cubit = _mapSearchCubit;
    if (cubit == null ||
        cubit.state.isResolvingLocation ||
        cubit.state.isFilterMode) {
      return;
    }
    _queueMapState(cubit.state);
  }

  void _tryApplyMapState() {
    final state = _pendingMapState;
    final controller = _mapController;
    if (!mounted || state == null || controller == null || !_styleLoaded) {
      return;
    }
    _pendingMapState = null;
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

  void _onMyLocationTap() {
    context.read<MapSearchCubit>().initialize();
  }

  Future<void> _fitCameraToPins(List<MapPropertyPin> pins) async {
    final controller = _mapController;
    if (controller == null || !_styleLoaded || !mounted || pins.isEmpty) {
      return;
    }

    _suppressRegionSearch = true;
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

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(centerLat, centerLng), zoom: zoom),
        ),
        duration: MapSearchConstants.selectionCameraDuration,
      );
      final position = await controller.queryCameraPosition();
      if (position != null) {
        _latestZoom = position.zoom;
      }
    } catch (_) {
    } finally {
      _suppressRegionSearch = false;
    }
  }

  void _onMapFilterAppliedFromSheet(List<PropertyModel> results) {
    if (!mounted) {
      return;
    }

    final mapCubit = _mapSearchCubit;
    if (mapCubit == null) {
      return;
    }

    mapCubit.applyFilterResults(results);
    _fitFilterPinsOnNextSync = false;
    unawaited(_syncAndFitFilterResults());

    if (results.isEmpty) {
      Alerts.of(context).showError('Không tìm thấy phòng phù hợp với bộ lọc');
    }
  }

  Future<void> _syncAndFitFilterResults() async {
    final mapCubit = _mapSearchCubit;
    if (mapCubit == null || !mapCubit.state.isFilterMode) {
      return;
    }

    await _syncPropertyMarkers(mapCubit.state);
    if (mapCubit.state.properties.isNotEmpty) {
      await _fitCameraToPins(mapCubit.state.properties);
    }
  }

  void _onMapFilterRealtimeUpdate(List<PropertyModel> results) {
    if (!mounted) {
      return;
    }

    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return;
    }

    final mapCubit = _mapSearchCubit;
    if (mapCubit == null || !mapCubit.state.isFilterMode) {
      return;
    }

    mapCubit.applyFilterResults(results);
    unawaited(_syncPropertyMarkers(mapCubit.state));
  }

  Future<void> _openMapFilterSheet() async {
    if (_isFilterSheetOpenNotifier.value) {
      return;
    }
    _isFilterSheetOpenNotifier.value = true;
    try {
      await showMapFilterBottomSheet(
        context,
        onFilterApplied: _onMapFilterAppliedFromSheet,
      );
    } finally {
      if (mounted) {
        _isFilterSheetOpenNotifier.value = false;
      }
    }
  }

  Future<void> _refreshPlaceSearchBias() async {
    final mapCubit = _mapSearchCubit;
    if (mapCubit == null) {
      return;
    }

    var biasLatitude = mapCubit.state.latitude;
    var biasLongitude = mapCubit.state.longitude;
    final controller = _mapController;
    if (controller != null && _styleLoaded) {
      try {
        final position = await controller.queryCameraPosition();
        final target = position?.target;
        if (target != null) {
          biasLatitude = target.latitude;
          biasLongitude = target.longitude;
        }
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    context.read<MapPlaceSearchCubit>().updateBias(
      latitude: biasLatitude,
      longitude: biasLongitude,
    );
  }

  Future<void> _moveToPlace(GoongPlaceDetailModel place) async {
    final controller = _mapController;
    final mapCubit = _mapSearchCubit;
    if (controller == null || !_styleLoaded || mapCubit == null || !mounted) {
      return;
    }

    if (mapCubit.state.isFilterMode) {
      await context.read<RoomFilterCubit>().stopFilterWatch();
      if (!mounted) return;
      mapCubit.exitFilterMode();
      await _propertyMarkerRegistry.clear(controller);
    } else {
      mapCubit.clearSelection();
    }

    _suppressRegionSearch = true;
    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(place.latitude, place.longitude),
            zoom: _mapZoom,
          ),
        ),
        duration: MapSearchConstants.selectionCameraDuration,
      );
      final position = await controller.queryCameraPosition();
      if (position != null) {
        _latestZoom = position.zoom;
      } else {
        _latestZoom = _mapZoom;
      }
      _lastSearchBounds = null;
    } catch (_) {
      if (mounted) {
        Alerts.of(context).showError('Không thể di chuyển tới địa điểm này');
      }
    } finally {
      _suppressRegionSearch = false;
    }

    _scheduleRegionSearch(forceBounds: true);
  }

  Future<void> _clearMapFilter() async {
    await context.read<RoomFilterCubit>().stopFilterWatch();
    context.read<MapSearchCubit>().exitFilterMode();
    final controller = _mapController;
    if (controller != null && _styleLoaded) {
      await _propertyMarkerRegistry.clear(controller);
    }
    _lastSearchBounds = null;
    _scheduleRegionSearch(forceBounds: true);
  }

  void _onPlaceSearchFocusChanged(bool hasFocus) {
    _isPlaceSearchFocusedNotifier.value = hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop || !mounted) {
          return;
        }
        _mapSearchCubit?.exitFilterMode();
        context.read<RoomFilterCubit>().resetDraftToInitial();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<RoomFilterCubit, RoomFilterState>(
            listenWhen: (previous, current) {
              if (current.applyTarget != FilterApplyTarget.map ||
                  !current.isWatchingFilterResults) {
                return false;
              }
              return current.applyResults != null &&
                  current.applyResults != previous.applyResults &&
                  !current.isApplying;
            },
            listener: (context, state) {
              final results = state.applyResults;
              if (results == null) {
                return;
              }
              _onMapFilterRealtimeUpdate(results);
              context.read<RoomFilterCubit>().clearApplyOutcome(
                keepTarget: true,
              );
            },
          ),
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

            listener: (context, state) async {
              await _syncPropertyMarkers(state);
              if (_fitFilterPinsOnNextSync && state.isFilterMode) {
                _fitFilterPinsOnNextSync = false;
                if (state.properties.isNotEmpty) {
                  await _fitCameraToPins(state.properties);
                }
              }
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
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Tìm trên bản đồ'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_outlined),
                tooltip: 'Bộ lọc',
                onPressed: () => unawaited(_openMapFilterSheet()),
              ),
            ],
          ),
          body: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              MapSearchView(
                initialZoom: _mapZoom,
                onMapCreated: _onMapCreated,
                onStyleLoaded: _onStyleLoaded,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
                onMapClick: _onMapClick,
              ),

              BlocBuilder<MapSearchCubit, MapSearchState>(
                buildWhen: (previous, current) =>
                    previous.isResolvingLocation !=
                        current.isResolvingLocation ||
                    previous.isLoadingProperties !=
                        current.isLoadingProperties ||
                    previous.selectedPropertyId != current.selectedPropertyId ||
                    previous.selectedProperty != current.selectedProperty ||
                    previous.isLoadingSelectedProperty !=
                        current.isLoadingSelectedProperty ||
                    previous.selectedPropertyError !=
                        current.selectedPropertyError ||
                    previous.isFilterMode != current.isFilterMode ||
                    previous.filteredResultCount !=
                        current.filteredResultCount ||
                    previous.filteredPinnedCount != current.filteredPinnedCount,
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
                        onOpenDetails: _openPropertyDetails,
                      ),
                      if (state.isFilterMode &&
                          state.selectedPropertyId == null)
                        Positioned(
                          left: 16.w,
                          right: 16.w,
                          bottom: 24.h,
                          child: SafeArea(
                            top: false,
                            child: MapFilterResultBar(
                              count: state.filteredResultCount,
                              pinnedCount: state.filteredPinnedCount,
                              onClear: () => unawaited(_clearMapFilter()),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _isFilterSheetOpenNotifier,
                builder: (context, isFilterSheetOpen, child) {
                  if (isFilterSheetOpen) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    left: 16.w,
                    right: 16.w,
                    top: 12.h,
                    child: MapSearchTopBar(
                      controller: _placeSearchTopBarController,
                      onFocus: () => unawaited(_refreshPlaceSearchBias()),
                      onFocusChanged: _onPlaceSearchFocusChanged,
                      onPlaceSelected: _moveToPlace,
                    ),
                  );
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _isPlaceSearchFocusedNotifier,
                builder: (context, isFocused, child) {
                  if (isFocused) {
                    return const SizedBox.shrink();
                  }
                  return MapSearchMapControls(
                    top: 72,
                    onMyLocationTap: _onMyLocationTap,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
