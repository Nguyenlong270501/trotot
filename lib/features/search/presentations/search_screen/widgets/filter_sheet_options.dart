import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/services/local_location_service.dart';
import '../../../../../core/utils/location_display.dart';
import '../../../blocs/room_filter/room_filter_state.dart';

List<FilterSheetOption> buildWardSheetOptions(String? city) {
  final wards = LocalLocationService().wardsForCity(city);
  return wards
      .map(
        (w) => FilterSheetOption(value: w.codename, label: w.name),
      )
      .toList();
}

List<FilterSheetOption> buildPropertyTypeSheetOptions() {
  return PropertyConstants.propertyTypes
      .map(
        (t) => FilterSheetOption(
          value: PropertyConstants.normalizePropertyType(t),
          label: t,
        ),
      )
      .toList();
}

String labelForSheetValue({
  required Set<String> selected,
  required String value,
  required List<FilterSheetOption> options,
  String? city,
  required bool isWard,
}) {
  for (final option in options) {
    if (option.value == value) {
      return option.label;
    }
  }
  if (isWard) {
    return LocationDisplay.formatWard(city: city, ward: value);
  }
  return value;
}

String buildFilterSelectionSummary({
  required Set<String> selected,
  required List<FilterSheetOption> options,
  String? city,
  required bool isWard,
}) {
  if (selected.isEmpty) {
    return '';
  }

  final labels = selected
      .map(
        (v) => labelForSheetValue(
          selected: selected,
          value: v,
          options: options,
          city: city,
          isWard: isWard,
        ),
      )
      .toList()
    ..sort();

  return labels.join(', ');
}
