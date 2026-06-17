import '../../data/models/map_property_pin.dart';

abstract final class FilterMarkerFocus {
  static String? reconcile(
    List<MapPropertyPin> pins,
    String? focusedPropertyId,
  ) {
    if (pins.isEmpty) {
      return null;
    }

    if (pins.any((pin) => pin.propertyId == focusedPropertyId)) {
      return focusedPropertyId;
    }

    return pins.first.propertyId;
  }

  static String? move(
    List<MapPropertyPin> pins,
    String? focusedPropertyId,
    int offset,
  ) {
    if (pins.isEmpty) {
      return null;
    }

    final currentIndex = pins.indexWhere(
      (pin) => pin.propertyId == focusedPropertyId,
    );
    final startIndex = currentIndex < 0 ? 0 : currentIndex;
    final nextIndex = (startIndex + offset) % pins.length;
    return pins[nextIndex].propertyId;
  }

  static int oneBasedIndexOf(
    List<MapPropertyPin> pins,
    String? focusedPropertyId,
  ) {
    final index = pins.indexWhere(
      (pin) => pin.propertyId == focusedPropertyId,
    );
    return index < 0 ? 0 : index + 1;
  }
}
