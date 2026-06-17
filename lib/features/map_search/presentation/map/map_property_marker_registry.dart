import 'package:maplibre_gl/maplibre_gl.dart';

import '../../data/models/map_property_pin.dart';
import 'map_price_label_bitmap.dart';

class MapPropertyMarkerRegistry {
  static const String sourceId = 'map-property-source';
  static const String layerId = 'map-property-symbol-layer';

  final Map<String, MapPropertyPin> _pinsByPropertyId = {};
  final Set<String> _registeredImageIds = {};
  String? _selectedPropertyId;
  var _isLayerReady = false;

  String? get selectedPropertyId => _selectedPropertyId;

  MapPropertyPin? pinFor(String propertyId) => _pinsByPropertyId[propertyId];

  bool containsProperty(String propertyId) =>
      _pinsByPropertyId.containsKey(propertyId);

  void resetStyle() {
    _isLayerReady = false;
    _registeredImageIds.clear();
  }

  Future<void> prepareForStyle(
    MapLibreMapController controller,
    List<MapPropertyPin> pins, {
    String? selectedPropertyId,
  }) async {
    _replacePins(pins);
    _selectedPropertyId = selectedPropertyId;
    await _ensureImagesRegistered(controller, pins);
    await _ensureLayer(controller);
    await _setSourceData(controller);
  }

  Future<void> sync(
    MapLibreMapController controller,
    List<MapPropertyPin> pins,
  ) async {
    _replacePins(pins);
    if (_selectedPropertyId != null &&
        !_pinsByPropertyId.containsKey(_selectedPropertyId)) {
      _selectedPropertyId = null;
    }
    await _ensureImagesRegistered(controller, pins);
    await _ensureLayer(controller);
    await _setSourceData(controller);
  }

  Future<void> applySelection(
    MapLibreMapController controller,
    String? selectedId,
  ) async {
    _selectedPropertyId = selectedId;
    if (selectedId != null && !_pinsByPropertyId.containsKey(selectedId)) {
      _selectedPropertyId = null;
    }
    await _ensureImagesRegistered(controller, _pinsByPropertyId.values);
    await _ensureLayer(controller);
    await _setSourceData(controller);
  }

  Future<void> clear(MapLibreMapController controller) async {
    _pinsByPropertyId.clear();
    _selectedPropertyId = null;
    await _ensureLayer(controller);
    await _setSourceData(controller);
  }

  void _replacePins(List<MapPropertyPin> pins) {
    _pinsByPropertyId
      ..clear()
      ..addEntries(pins.map((pin) => MapEntry(pin.propertyId, pin)));
  }

  Future<void> _ensureLayer(MapLibreMapController controller) async {
    if (_isLayerReady) {
      return;
    }

    final sourceIds = await controller.getSourceIds();
    if (!sourceIds.contains(sourceId)) {
      await controller.addGeoJsonSource(
        sourceId,
        _emptyFeatureCollection(),
        promoteId: 'propertyId',
      );
    }

    final layerIds = await controller.getLayerIds();
    if (!layerIds.contains(layerId)) {
      await controller.addLayer(
        sourceId,
        layerId,
        const SymbolLayerProperties(
          iconImage: ['get', 'iconImage'],
          iconAnchor: 'bottom',
          iconSize: 0.34,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          textAllowOverlap: true,
          textIgnorePlacement: true,
        ),
        enableInteraction: true,
      );
    }

    _isLayerReady = true;
  }

  Future<void> _setSourceData(MapLibreMapController controller) {
    return controller.setGeoJsonSource(sourceId, _featureCollection());
  }

  Future<void> _ensureImagesRegistered(
    MapLibreMapController controller,
    Iterable<MapPropertyPin> pins,
  ) async {
    for (final pin in pins) {
      await _ensureImageRegistered(controller, pin.priceLabel, selected: false);
      await _ensureImageRegistered(controller, pin.priceLabel, selected: true);
    }
  }

  Future<void> _ensureImageRegistered(
    MapLibreMapController controller,
    String label, {
    required bool selected,
  }) async {
    final imageId = MapPriceLabelBitmap.imageIdFor(label, selected: selected);
    if (_registeredImageIds.contains(imageId)) {
      return;
    }

    final bytes = await MapPriceLabelBitmap.build(label, selected: selected);
    await controller.addImage(imageId, bytes);
    _registeredImageIds.add(imageId);
  }

  Map<String, dynamic> _featureCollection() {
    return {
      'type': 'FeatureCollection',
      'features': _pinsByPropertyId.values.map(_featureForPin).toList(),
    };
  }

  Map<String, dynamic> _featureForPin(MapPropertyPin pin) {
    final isSelected = pin.propertyId == _selectedPropertyId;
    return {
      'type': 'Feature',
      'id': pin.propertyId,
      'properties': {
        'propertyId': pin.propertyId,
        'iconImage': MapPriceLabelBitmap.imageIdFor(
          pin.priceLabel,
          selected: isSelected,
        ),
        'priceLabel': pin.priceLabel,
      },
      'geometry': {
        'type': 'Point',
        'coordinates': [pin.longitude, pin.latitude],
      },
    };
  }

  Map<String, dynamic> _emptyFeatureCollection() {
    return {'type': 'FeatureCollection', 'features': <Object>[]};
  }

  static void reset() {
    MapPriceLabelBitmap.clearCache();
  }
}
