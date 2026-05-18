import 'package:maplibre_gl/maplibre_gl.dart';

import '../../data/models/map_property_pin.dart';
import 'map_price_label_bitmap.dart';

/// Diff-sync price-label markers; selection uses [MapLibreMapController.updateSymbol].
class MapPropertyMarkerRegistry {
  final Map<String, Symbol> _symbolsByPropertyId = {};
  final Map<String, MapPropertyPin> _pinsByPropertyId = {};
  final Set<String> _registeredImageIds = {};
  String? _selectedPropertyId;

  String? get selectedPropertyId => _selectedPropertyId;

  MapPropertyPin? pinFor(String propertyId) => _pinsByPropertyId[propertyId];

  String? propertyIdFor(Symbol symbol) {
    for (final entry in _symbolsByPropertyId.entries) {
      if (entry.value.id == symbol.id) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> sync(
    MapLibreMapController controller,
    List<MapPropertyPin> pins,
  ) async {
    final nextIds = pins.map((p) => p.propertyId).toSet();
    final currentIds = _symbolsByPropertyId.keys.toSet();

    for (final id in currentIds.difference(nextIds)) {
      await _removeMarker(controller, id);
    }

    for (final pin in pins) {
      _pinsByPropertyId[pin.propertyId] = pin;

      final existing = _symbolsByPropertyId[pin.propertyId];
      if (existing != null) {
        final isSelected = pin.propertyId == _selectedPropertyId;
        await _setSelected(controller, pin.propertyId, isSelected);
        continue;
      }

      final isSelected = pin.propertyId == _selectedPropertyId;
      await _ensureImageRegistered(controller, pin.priceLabel, isSelected);
      final imageId = MapPriceLabelBitmap.imageIdFor(
        pin.priceLabel,
        selected: isSelected,
      );

      final symbol = await controller.addSymbol(
        SymbolOptions(
          geometry: LatLng(pin.latitude, pin.longitude),
          iconImage: imageId,
          iconAnchor: 'bottom',
          iconSize: 0.34,
        ),
      );
      _symbolsByPropertyId[pin.propertyId] = symbol;
    }
  }

  Future<void> applySelection(
    MapLibreMapController controller,
    String? selectedId,
  ) async {
    if (_selectedPropertyId != null && _selectedPropertyId != selectedId) {
      await _setSelected(controller, _selectedPropertyId!, false);
    }
    if (selectedId != null) {
      await _setSelected(controller, selectedId, true);
    }
    _selectedPropertyId = selectedId;
  }

  Future<void> _setSelected(
    MapLibreMapController controller,
    String propertyId,
    bool selected,
  ) async {
    final symbol = _symbolsByPropertyId[propertyId];
    final pin = _pinsByPropertyId[propertyId];
    if (symbol == null || pin == null) {
      return;
    }

    await _ensureImageRegistered(controller, pin.priceLabel, selected);
    final imageId = MapPriceLabelBitmap.imageIdFor(
      pin.priceLabel,
      selected: selected,
    );
    await controller.updateSymbol(
      symbol,
      SymbolOptions(
        geometry: LatLng(pin.latitude, pin.longitude),
        iconImage: imageId,
        iconAnchor: 'bottom',
        iconSize: 0.34,
      ),
    );
  }

  Future<void> _ensureImageRegistered(
    MapLibreMapController controller,
    String label,
    bool selected,
  ) async {
    final imageId = MapPriceLabelBitmap.imageIdFor(label, selected: selected);
    if (_registeredImageIds.contains(imageId)) {
      return;
    }

    final bytes = await MapPriceLabelBitmap.build(label, selected: selected);
    await controller.addImage(imageId, bytes);
    _registeredImageIds.add(imageId);
  }

  Future<void> _removeMarker(
    MapLibreMapController controller,
    String propertyId,
  ) async {
    final symbol = _symbolsByPropertyId.remove(propertyId);
    _pinsByPropertyId.remove(propertyId);
    if (_selectedPropertyId == propertyId) {
      _selectedPropertyId = null;
    }
    if (symbol != null) {
      await controller.removeSymbol(symbol);
    }
  }

  Future<void> clear(MapLibreMapController controller) async {
    for (final id in _symbolsByPropertyId.keys.toList()) {
      await _removeMarker(controller, id);
    }
  }

  static void reset() {
    MapPriceLabelBitmap.clearCache();
  }
}
