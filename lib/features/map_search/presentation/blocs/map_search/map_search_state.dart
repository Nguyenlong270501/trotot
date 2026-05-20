import 'package:equatable/equatable.dart';

import '../../../../home/data/models/property_model.dart';
import '../../../data/models/map_location_result.dart';
import '../../../data/models/map_property_pin.dart';

class MapSearchState extends Equatable {
  const MapSearchState({
    required this.latitude,
    required this.longitude,
    required this.usedDeviceLocation,
    required this.isResolvingLocation,
    required this.properties,
    required this.isLoadingProperties,
    required this.selectedPropertyId,
    required this.selectedProperty,
    required this.isLoadingSelectedProperty,
    this.selectedPropertyError,
    required this.isFilterMode,
    required this.filteredResultCount,
    required this.filteredPinnedCount,
    this.filteredResultsSignature,
  });

  factory MapSearchState.initial() {
    return const MapSearchState(
      latitude: MapLocationResult.defaultLatitude,
      longitude: MapLocationResult.defaultLongitude,
      usedDeviceLocation: false,
      isResolvingLocation: true,
      properties: [],
      isLoadingProperties: false,
      selectedPropertyId: null,
      selectedProperty: null,
      isLoadingSelectedProperty: false,
      selectedPropertyError: null,
      isFilterMode: false,
      filteredResultCount: 0,
      filteredPinnedCount: 0,
      filteredResultsSignature: null,
    );
  }

  final double latitude;
  final double longitude;
  final bool usedDeviceLocation;
  final bool isResolvingLocation;
  final List<MapPropertyPin> properties;
  final bool isLoadingProperties;
  final String? selectedPropertyId;
  final PropertyModel? selectedProperty;
  final bool isLoadingSelectedProperty;
  final String? selectedPropertyError;
  final bool isFilterMode;
  final int filteredResultCount;
  final int filteredPinnedCount;
  final String? filteredResultsSignature;

  static const Object _unset = Object();

  MapSearchState copyWith({
    double? latitude,
    double? longitude,
    bool? usedDeviceLocation,
    bool? isResolvingLocation,
    List<MapPropertyPin>? properties,
    bool? isLoadingProperties,
    Object? selectedPropertyId = _unset,
    Object? selectedProperty = _unset,
    bool? isLoadingSelectedProperty,
    Object? selectedPropertyError = _unset,
    bool? isFilterMode,
    int? filteredResultCount,
    int? filteredPinnedCount,
    Object? filteredResultsSignature = _unset,
  }) {
    return MapSearchState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      usedDeviceLocation: usedDeviceLocation ?? this.usedDeviceLocation,
      isResolvingLocation: isResolvingLocation ?? this.isResolvingLocation,
      properties: properties ?? this.properties,
      isLoadingProperties: isLoadingProperties ?? this.isLoadingProperties,
      selectedPropertyId: selectedPropertyId == _unset
          ? this.selectedPropertyId
          : selectedPropertyId as String?,
      selectedProperty: selectedProperty == _unset
          ? this.selectedProperty
          : selectedProperty as PropertyModel?,
      isLoadingSelectedProperty:
          isLoadingSelectedProperty ?? this.isLoadingSelectedProperty,
      selectedPropertyError: selectedPropertyError == _unset
          ? this.selectedPropertyError
          : selectedPropertyError as String?,
      isFilterMode: isFilterMode ?? this.isFilterMode,
      filteredResultCount: filteredResultCount ?? this.filteredResultCount,
      filteredPinnedCount: filteredPinnedCount ?? this.filteredPinnedCount,
      filteredResultsSignature: filteredResultsSignature == _unset
          ? this.filteredResultsSignature
          : filteredResultsSignature as String?,
    );
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    usedDeviceLocation,
    isResolvingLocation,
    properties,
    isLoadingProperties,
    selectedPropertyId,
    selectedProperty,
    isLoadingSelectedProperty,
    selectedPropertyError,
    isFilterMode,
    filteredResultCount,
    filteredPinnedCount,
    filteredResultsSignature,
  ];
}
