import 'package:flutter_test/flutter_test.dart';
import 'package:trotot/features/map_search/blocs/map_search/filter_marker_focus.dart';
import 'package:trotot/features/map_search/data/models/map_property_pin.dart';

void main() {
  group('FilterMarkerFocus', () {
    const first = MapPropertyPin(
      propertyId: 'first',
      latitude: 21,
      longitude: 105,
      priceLabel: '3 Tr',
    );
    const second = MapPropertyPin(
      propertyId: 'second',
      latitude: 21.1,
      longitude: 105.1,
      priceLabel: '4 Tr',
    );
    const third = MapPropertyPin(
      propertyId: 'third',
      latitude: 21.2,
      longitude: 105.2,
      priceLabel: '5 Tr',
    );

    test('should focus first marker when current marker is unavailable', () {
      // Arrange
      const pins = [first, second];

      // Act
      final focusedId = FilterMarkerFocus.reconcile(pins, 'missing');

      // Assert
      expect(focusedId, first.propertyId);
    });

    test('should preserve focused marker when realtime results still contain it', () {
      // Arrange
      const pins = [third, second];

      // Act
      final focusedId = FilterMarkerFocus.reconcile(pins, second.propertyId);

      // Assert
      expect(focusedId, second.propertyId);
    });

    test('should clear focus when marker list is empty', () {
      // Arrange
      const pins = <MapPropertyPin>[];

      // Act
      final focusedId = FilterMarkerFocus.reconcile(pins, first.propertyId);

      // Assert
      expect(focusedId, isNull);
    });

    test('should wrap to first marker when moving next from last marker', () {
      // Arrange
      const pins = [first, second, third];

      // Act
      final focusedId = FilterMarkerFocus.move(pins, third.propertyId, 1);

      // Assert
      expect(focusedId, first.propertyId);
    });

    test('should wrap to last marker when moving previous from first marker', () {
      // Arrange
      const pins = [first, second, third];

      // Act
      final focusedId = FilterMarkerFocus.move(pins, first.propertyId, -1);

      // Assert
      expect(focusedId, third.propertyId);
    });

    test('should report one-based index for the focused marker', () {
      // Arrange
      const pins = [first, second, third];

      // Act
      final index = FilterMarkerFocus.oneBasedIndexOf(pins, second.propertyId);

      // Assert
      expect(index, 2);
    });
  });
}
