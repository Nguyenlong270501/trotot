import 'dart:math' show Point;

import 'package:maplibre_gl/maplibre_gl.dart';

import 'map_property_marker_registry.dart';

class MapPropertyFeatureTapHandler {
  DateTime? _lastMarkerTapAt;

  void markMarkerTapped() {
    _lastMarkerTapAt = DateTime.now();
  }

  bool isWithinMarkerTapGracePeriod() {
    final tappedAt = _lastMarkerTapAt;
    if (tappedAt == null) {
      return false;
    }
    return DateTime.now().difference(tappedAt) <
        const Duration(milliseconds: 280);
  }

  Future<String?> propertyIdAt(
    MapLibreMapController controller,
    MapPropertyMarkerRegistry registry,
    Point<double> point, {
    String? fallbackPropertyId,
  }) async {
    try {
      final features = await controller.queryRenderedFeatures(
        point,
        [MapPropertyMarkerRegistry.layerId],
        null,
      );
      for (final feature in features) {
        final propertyId = _propertyIdFromRenderedFeature(feature);
        if (propertyId != null && registry.containsProperty(propertyId)) {
          markMarkerTapped();
          return propertyId;
        }
      }
    } catch (_) {}

    if (fallbackPropertyId != null &&
        registry.containsProperty(fallbackPropertyId)) {
      markMarkerTapped();
      return fallbackPropertyId;
    }

    return null;
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
}
