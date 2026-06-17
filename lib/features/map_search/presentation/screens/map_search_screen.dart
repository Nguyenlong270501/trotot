import 'dart:async';
import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../core/route/app_routes.dart';
import '../../../home/data/models/property_model.dart';
import '../../../search/blocs/room_filter/room_filter_cubit.dart';
import '../../data/models/goong_place_detail_model.dart';
import '../../../../core/constants/map_search_constants.dart';
import '../../blocs/map_place_search/map_place_search_cubit.dart';
import '../../blocs/map_search/map_search_cubit.dart';
import '../../blocs/map_search/map_search_state.dart';
import '../flows/map_filter_flow_controller.dart';
import '../flows/map_place_search_flow_controller.dart';
import '../map/map_property_feature_tap_handler.dart';
import '../map/map_property_marker_registry.dart';
import '../map/map_search_map_coordinator.dart';
import '../widgets/map_search_listeners.dart';
import '../widgets/map_search_overlays.dart';
import '../widgets/map_search_top_bar.dart';
import '../widgets/map_search_view.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  Timer? _regionSearchDebounce;
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
  late final MapSearchMapCoordinator _mapCoordinator = MapSearchMapCoordinator(
    propertyMarkerRegistry: _propertyMarkerRegistry,
  );
  final MapPropertyFeatureTapHandler _propertyFeatureTapHandler =
      MapPropertyFeatureTapHandler();
  late final MapFilterFlowController _filterFlow = MapFilterFlowController(
    isSheetOpenNotifier: _isFilterSheetOpenNotifier,
    mapCoordinator: _mapCoordinator,
    mapCubit: () => _mapSearchCubit,
    mounted: () => mounted,
    scheduleRegionSearch: _scheduleRegionSearch,
  );
  late final MapPlaceSearchFlowController _placeSearchFlow =
      MapPlaceSearchFlowController(
        mapCoordinator: _mapCoordinator,
        mapCubit: () => _mapSearchCubit,
        mounted: () => mounted,
        scheduleRegionSearch: _scheduleRegionSearch,
      );

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
    _mapCoordinator.dispose();
    _isFilterSheetOpenNotifier.dispose();
    _isPlaceSearchFocusedNotifier.dispose();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapCoordinator.setController(controller);
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
    _propertyFeatureTapHandler.markMarkerTapped();
    unawaited(_selectPropertyFeatureAt(point, fallbackPropertyId: id));
  }

  bool _isWithinMarkerTapGracePeriod() {
    return _propertyFeatureTapHandler.isWithinMarkerTapGracePeriod();
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
    final controller = _mapCoordinator.controller;
    if (controller == null || !_mapCoordinator.styleLoaded || !mounted) {
      return false;
    }

    final propertyId = await _propertyFeatureTapHandler.propertyIdAt(
      controller,
      _propertyMarkerRegistry,
      point,
      fallbackPropertyId: fallbackPropertyId,
    );
    if (propertyId != null && mounted) {
      context.read<MapSearchCubit>().selectProperty(propertyId);
      return true;
    }

    return false;
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
    _mapCoordinator.markStyleLoaded();
    unawaited(_restorePropertyMarkersForStyle());
    _tryApplyMapState();
    _scheduleRegionSearch(forceBounds: true);
  }

  Future<void> _restorePropertyMarkersForStyle() async {
    final cubit = _mapSearchCubit;
    if (cubit == null) {
      return;
    }
    await _mapCoordinator.restorePropertyMarkersForStyle(cubit.state);
  }

  void _onCameraMove(CameraPosition position) {
    if (!_mapCoordinator.centeringSelection) {
      _mapCoordinator.latestZoom = position.zoom;
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
    if (_mapCoordinator.suppressRegionSearch ||
        !_mapCoordinator.styleLoaded ||
        _mapCoordinator.controller == null ||
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
    await _mapCoordinator.runRegionSearchIfNeeded(
      context.read<MapSearchCubit>(),
      forceBounds: forceBounds,
      mounted: mounted,
    );
  }

  Future<void> _applyMarkerSelection(String? selectedPropertyId) async {
    await _mapCoordinator.applyMarkerSelection(selectedPropertyId);
  }

  Future<void> _onSelectionChanged(MapSearchState state) async {
    final propertyId = state.selectedPropertyId;

    if (propertyId == null) {
      await _applyMarkerSelection(null);
      return;
    }

    await _applyMarkerSelection(propertyId);
    final pin = _mapCoordinator.pinFor(propertyId, state.properties);
    if (pin == null) {
      return;
    }
    await _mapCoordinator.centerMapOnPin(pin, mounted: mounted);
  }

  void _queueMapState(MapSearchState state) {
    _mapCoordinator.queueMapState(state, tryApplyMapState: _tryApplyMapState);
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
    _mapCoordinator.tryApplyMapState(
      mounted: mounted,
      scheduleRegionSearch: _scheduleRegionSearch,
    );
  }

  Future<void> _syncPropertyMarkers(MapSearchState state) async {
    await _mapCoordinator.syncPropertyMarkers(state);
  }

  void _openPropertyDetails(PropertyModel property) {
    context.pushNamed(
      RouteNames.propertyDetailsPage,
      extra: {'property': property, 'rooms': property.rooms ?? const []},
    );
  }

  void _onMyLocationTap() {
    _dismissSelection();
    unawaited(context.read<MapSearchCubit>().initialize());
  }

  void _onMapFilterRealtimeUpdate(List<PropertyModel> results) {
    _filterFlow.applyRealtimeUpdate(context, results);
  }

  Future<void> _moveFilterFocus(int offset) async {
    final cubit = context.read<MapSearchCubit>();
    cubit.moveFilterFocus(offset);
    final pin = _mapCoordinator.pinFor(
      cubit.state.focusedFilterPropertyId,
      cubit.state.properties,
    );
    if (pin == null) {
      return;
    }
    await _mapCoordinator.centerMapOnPin(pin, mounted: mounted);
  }

  Future<void> _openMapFilterSheet() async {
    await _filterFlow.openSheet(context);
  }

  Future<void> _refreshPlaceSearchBias() async {
    await _placeSearchFlow.refreshBias(context);
  }

  Future<void> _moveToPlace(GoongPlaceDetailModel place) async {
    await _placeSearchFlow.moveToPlace(context, place);
  }

  Future<void> _clearMapFilter() async {
    await _filterFlow.clear(context);
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
      child: MapSearchListeners(
        onFilterRealtimeUpdate: _onMapFilterRealtimeUpdate,
        onLocationResolved: (state) {
          _queueMapState(state);
          _scheduleRegionSearch(forceBounds: true);
        },
        onPropertiesChanged: _syncPropertyMarkers,
        onSelectionChanged: _onSelectionChanged,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Tìm kiếm trên bản đồ'),
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
                initialZoom: MapSearchMapCoordinator.mapZoom,
                onMapCreated: _onMapCreated,
                onStyleLoaded: _onStyleLoaded,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
                onMapClick: _onMapClick,
              ),
              MapSearchOverlays(
                isFilterSheetOpenListenable: _isFilterSheetOpenNotifier,
                isPlaceSearchFocusedListenable: _isPlaceSearchFocusedNotifier,
                topBarController: _placeSearchTopBarController,
                onOpenDetails: _openPropertyDetails,
                onClearFilter: _clearMapFilter,
                onRefreshPlaceSearchBias: _refreshPlaceSearchBias,
                onPlaceSearchFocusChanged: _onPlaceSearchFocusChanged,
                onPlaceSelected: _moveToPlace,
                onMyLocationTap: _onMyLocationTap,
                onPreviousFilterMarker: () => _moveFilterFocus(-1),
                onNextFilterMarker: () => _moveFilterFocus(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
