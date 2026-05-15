import 'package:equatable/equatable.dart';

import '../../../../core/constants/property_constants.dart';
import '../../../../core/services/local_location_service.dart';

class RoomFilterCriteria extends Equatable {
  const RoomFilterCriteria({
    this.city,
    this.selectedWards = const {},
    this.selectedPropertyTypes = const {},
    this.selectedPriceBracketIndexes = const {},
    this.selectedAmenityLabels = const {},
  });

  final String? city;
  final Set<String> selectedWards;
  final Set<String> selectedPropertyTypes;
  final Set<int> selectedPriceBracketIndexes;
  final Set<String> selectedAmenityLabels;

  @override
  List<Object?> get props => [
    city,
    selectedWards,
    selectedPropertyTypes,
    selectedPriceBracketIndexes,
    selectedAmenityLabels,
  ];
}

class RoomFilterDraft extends Equatable {
  static const defaultCity = 'Hà Nội';

  const RoomFilterDraft({
    this.city = defaultCity,
    this.selectedWards = const {},
    this.selectedPropertyTypes = const {},
    this.selectedPriceBracketIndexes = const {},
    this.selectedAmenityLabels = const {},
  });

  final String? city;
  final Set<String> selectedWards;
  final Set<String> selectedPropertyTypes;
  final Set<int> selectedPriceBracketIndexes;
  final Set<String> selectedAmenityLabels;

  String? get ward =>
      selectedWards.isEmpty ? null : selectedWards.first;

  String? get propertyType => selectedPropertyTypes.isEmpty
      ? null
      : selectedPropertyTypes.first;

  static const initial = RoomFilterDraft();

  bool get isPristine =>
      ((city?.trim().isEmpty ?? true) || city?.trim() == defaultCity) &&
      selectedWards.isEmpty &&
      selectedPropertyTypes.isEmpty &&
      selectedPriceBracketIndexes.isEmpty &&
      selectedAmenityLabels.isEmpty;

  RoomFilterDraft copyWith({
    String? city,
    Set<String>? selectedWards,
    Set<int>? selectedPriceBracketIndexes,
    Set<String>? selectedPropertyTypes,
    Set<String>? selectedAmenityLabels,
    bool clearCity = false,
    bool clearWards = false,
    bool clearPropertyTypes = false,
  }) {
    return RoomFilterDraft(
      city: clearCity ? defaultCity : (city ?? this.city),
      selectedWards: clearWards
          ? const {}
          : (selectedWards ?? this.selectedWards),
      selectedPropertyTypes: clearPropertyTypes
          ? const {}
          : (selectedPropertyTypes ?? this.selectedPropertyTypes),
      selectedPriceBracketIndexes:
          selectedPriceBracketIndexes ?? this.selectedPriceBracketIndexes,
      selectedAmenityLabels:
          selectedAmenityLabels ?? this.selectedAmenityLabels,
    );
  }

  RoomFilterCriteria toCriteria() {
    final wards = LocalLocationService().wardCodenamesForQuery(
      city: city,
      wards: selectedWards,
    );
    final types = selectedPropertyTypes
        .map(PropertyConstants.normalizePropertyType)
        .where((e) => e.isNotEmpty)
        .toSet();
    return RoomFilterCriteria(
      city: city?.trim().isEmpty == true ? null : city?.trim(),
      selectedWards: Set<String>.from(wards),
      selectedPropertyTypes: Set<String>.from(types),
      selectedPriceBracketIndexes: Set<int>.from(selectedPriceBracketIndexes),
      selectedAmenityLabels: Set<String>.from(
        selectedAmenityLabels.map((e) => e.trim()).where((e) => e.isNotEmpty),
      ),
    );
  }

  @override
  List<Object?> get props => [
    city,
    selectedWards,
    selectedPropertyTypes,
    selectedPriceBracketIndexes,
    selectedAmenityLabels,
  ];
}
