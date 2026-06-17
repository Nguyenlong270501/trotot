import 'package:flutter_test/flutter_test.dart';
import 'package:trotot/features/map_search/data/models/map_visible_bounds.dart';

void main() {
  group('MapVisibleBounds.shouldSearchComparedTo', () {
    test('should search when panning meaningfully at a high zoom level', () {
      // Arrange
      const previous = MapVisibleBounds(
        southwestLat: 10,
        southwestLng: 106,
        northeastLat: 10.001,
        northeastLng: 106.001,
      );
      const current = MapVisibleBounds(
        southwestLat: 10.0003,
        southwestLng: 106.0003,
        northeastLat: 10.0013,
        northeastLng: 106.0013,
      );

      // Act
      final shouldSearch = current.shouldSearchComparedTo(previous);

      // Assert
      expect(shouldSearch, isTrue);
    });

    test('should skip search when panning slightly at a normal zoom level', () {
      // Arrange
      const previous = MapVisibleBounds(
        southwestLat: 10,
        southwestLng: 106,
        northeastLat: 10.02,
        northeastLng: 106.02,
      );
      const current = MapVisibleBounds(
        southwestLat: 10.001,
        southwestLng: 106.001,
        northeastLat: 10.021,
        northeastLng: 106.021,
      );

      // Act
      final shouldSearch = current.shouldSearchComparedTo(previous);

      // Assert
      expect(shouldSearch, isFalse);
    });
  });
}
