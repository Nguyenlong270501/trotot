import 'package:maplibre_gl/maplibre_gl.dart';

import '../../map_search_constants.dart';

/// Geographic rectangle for Firestore bounds queries (no map controller dependency).
class MapVisibleBounds {
  const MapVisibleBounds({
    required this.southwestLat,
    required this.southwestLng,
    required this.northeastLat,
    required this.northeastLng,
  });

  final double southwestLat;
  final double southwestLng;
  final double northeastLat;
  final double northeastLng;

  factory MapVisibleBounds.fromLatLngBounds(LatLngBounds bounds) {
    return MapVisibleBounds(
      southwestLat: bounds.southwest.latitude,
      southwestLng: bounds.southwest.longitude,
      northeastLat: bounds.northeast.latitude,
      northeastLng: bounds.northeast.longitude,
    );
  }

  bool containsPoint(double latitude, double longitude) {
    final latInRange = latitude >= southwestLat && latitude <= northeastLat;

    final bool lngInRange;
    if (southwestLng <= northeastLng) {
      lngInRange = longitude >= southwestLng && longitude <= northeastLng;
    } else {
      lngInRange = longitude >= southwestLng || longitude <= northeastLng;
    }

    return latInRange && lngInRange;
  }

  /// Returns true when bounds moved enough to warrant a new Firestore query.
  bool shouldSearchComparedTo(MapVisibleBounds? last) {
    if (last == null) {
      return true;
    }

    final latMoved =
        (southwestLat - last.southwestLat).abs() >
            MapSearchConstants.minBoundsLatDelta ||
        (northeastLat - last.northeastLat).abs() >
            MapSearchConstants.minBoundsLatDelta;

    final lngMoved =
        (southwestLng - last.southwestLng).abs() >
            MapSearchConstants.minBoundsLngDelta ||
        (northeastLng - last.northeastLng).abs() >
            MapSearchConstants.minBoundsLngDelta;

    return latMoved || lngMoved;
  }
}
