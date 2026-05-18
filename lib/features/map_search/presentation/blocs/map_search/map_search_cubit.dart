import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/map_visible_bounds.dart';
import '../../../data/repositories/map_location_repository.dart';
import '../../../data/repositories/map_property_repository.dart';
import 'map_search_state.dart';

class MapSearchCubit extends Cubit<MapSearchState> {
  MapSearchCubit({
    required MapLocationRepository locationRepository,
    required MapPropertyRepository propertyRepository,
  }) : _locationRepository = locationRepository,
       _propertyRepository = propertyRepository,
       super(MapSearchState.initial());

  final MapLocationRepository _locationRepository;
  final MapPropertyRepository _propertyRepository;

  int _searchGeneration = 0;
  int _selectionGeneration = 0;

  Future<void> initialize() async {
    try {
      final result = await _locationRepository.resolveMapCenter();
      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          latitude: result.latitude,
          longitude: result.longitude,
          usedDeviceLocation: result.fromDevice,
          isResolvingLocation: false,
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(isResolvingLocation: false));
    }
  }

  Future<void> searchInBounds(MapVisibleBounds bounds) async {
    if (state.isResolvingLocation) {
      return;
    }

    final generation = ++_searchGeneration;
    emit(state.copyWith(isLoadingProperties: true));

    try {
      final pins = await _propertyRepository.fetchApprovedInBounds(bounds);
      if (isClosed || generation != _searchGeneration) {
        return;
      }

      emit(
        state.copyWith(
          properties: pins,
          isLoadingProperties: false,
        ),
      );
    } catch (_) {
      if (isClosed || generation != _searchGeneration) {
        return;
      }
      emit(state.copyWith(isLoadingProperties: false));
    }
  }

  Future<void> selectProperty(String propertyId) async {
    if (propertyId.isEmpty) {
      return;
    }

    if (propertyId == state.selectedPropertyId &&
        state.selectedProperty != null &&
        !state.isLoadingSelectedProperty) {
      return;
    }

    final generation = ++_selectionGeneration;

    emit(
      state.copyWith(
        selectedPropertyId: propertyId,
        selectedProperty: null,
        isLoadingSelectedProperty: true,
      ),
    );

    try {
      final property = await _propertyRepository.fetchPropertyForMapCard(
        propertyId,
      );
      if (isClosed || generation != _selectionGeneration) {
        return;
      }

      emit(
        state.copyWith(
          selectedProperty: property,
          isLoadingSelectedProperty: false,
        ),
      );
    } catch (_) {
      if (isClosed || generation != _selectionGeneration) {
        return;
      }
      emit(
        state.copyWith(
          selectedProperty: null,
          isLoadingSelectedProperty: false,
        ),
      );
    }
  }

  void clearSelection() {
    _selectionGeneration++;
    emit(
      state.copyWith(
        selectedPropertyId: null,
        selectedProperty: null,
        isLoadingSelectedProperty: false,
      ),
    );
  }

  void clearMapProperties() {
    _searchGeneration++;
    _selectionGeneration++;
    emit(
      state.copyWith(
        properties: [],
        isLoadingProperties: false,
        selectedPropertyId: null,
        selectedProperty: null,
        isLoadingSelectedProperty: false,
      ),
    );
  }
}
