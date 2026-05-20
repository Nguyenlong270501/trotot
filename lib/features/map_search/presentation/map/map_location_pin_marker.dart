import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Registers and places the red map pin asset on a [MapLibreMapController].
class MapLocationPinMarker {
  MapLocationPinMarker._();

  static const String assetPath = 'assets/images/map_location_pin.png';
  static const String imageId = 'map-location-pin';

  static var _imageRegistered = false;

  static Future<Symbol> sync(
    MapLibreMapController controller,
    LatLng target, {
    Symbol? currentSymbol,
  }) async {
    if (!_imageRegistered) {
      final bytes = await rootBundle.load(assetPath);
      await controller.addImage(imageId, bytes.buffer.asUint8List());
      _imageRegistered = true;
    }

    if (currentSymbol != null) {
      await controller.removeSymbol(currentSymbol);
    }

    return controller.addSymbol(
      SymbolOptions(
        geometry: target,
        iconImage: imageId,
        iconSize: 0.3,
        iconAnchor: 'bottom',
      ),
    );
  }

  /// Call when the map controller is disposed so the next map can re-register.
  static void reset() {
    _imageRegistered = false;
  }
}
