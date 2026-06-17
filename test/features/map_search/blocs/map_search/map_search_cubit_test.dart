import 'package:flutter_test/flutter_test.dart';
import 'package:trotot/features/map_search/blocs/map_search/map_search_cubit.dart';
import 'package:trotot/features/map_search/data/repositories/map_location_repository.dart';
import 'package:trotot/features/map_search/data/repositories/map_property_repository.dart';

import '../../../../shared/map_search_fakes.dart';

void main() {
  group('MapSearchCubit filter marker focus', () {
    late MapSearchCubit cubit;

    setUp(() {
      cubit = MapSearchCubit(
        locationRepository: MapLocationRepository(
          remote: FakeMapLocationRemoteDataSource(),
        ),
        propertyRepository: MapPropertyRepository(
          remote: FakeMapPropertyRemoteDataSource(),
        ),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('should focus first rendered marker when applying filter results', () {
      // Arrange
      final first = createMapProperty(
        propertyId: 'first',
        latitude: 21,
        longitude: 105,
      );
      final second = createMapProperty(
        propertyId: 'second',
        latitude: 21.1,
        longitude: 105.1,
      );

      // Act
      cubit.applyFilterResults([first, second]);

      // Assert
      expect(cubit.state.focusedFilterPropertyId, first.propertyId);
    });

    test('should wrap focus without selecting property when moving previous', () {
      // Arrange
      final first = createMapProperty(
        propertyId: 'first',
        latitude: 21,
        longitude: 105,
      );
      final second = createMapProperty(
        propertyId: 'second',
        latitude: 21.1,
        longitude: 105.1,
      );
      cubit.applyFilterResults([first, second]);

      // Act
      cubit.moveFilterFocus(-1);

      // Assert
      expect(cubit.state.focusedFilterPropertyId, second.propertyId);
      expect(cubit.state.selectedPropertyId, isNull);
    });

    test('should preserve focused marker when realtime results retain it', () {
      // Arrange
      final first = createMapProperty(
        propertyId: 'first',
        latitude: 21,
        longitude: 105,
      );
      final second = createMapProperty(
        propertyId: 'second',
        latitude: 21.1,
        longitude: 105.1,
      );
      final third = createMapProperty(
        propertyId: 'third',
        latitude: 21.2,
        longitude: 105.2,
      );
      cubit.applyFilterResults([first, second]);
      cubit.moveFilterFocus(1);

      // Act
      cubit.applyFilterResults([third, second]);

      // Assert
      expect(cubit.state.focusedFilterPropertyId, second.propertyId);
    });

    test('should focus first marker when realtime results remove focused marker', () {
      // Arrange
      final first = createMapProperty(
        propertyId: 'first',
        latitude: 21,
        longitude: 105,
      );
      final second = createMapProperty(
        propertyId: 'second',
        latitude: 21.1,
        longitude: 105.1,
      );
      final third = createMapProperty(
        propertyId: 'third',
        latitude: 21.2,
        longitude: 105.2,
      );
      cubit.applyFilterResults([first, second]);
      cubit.moveFilterFocus(1);

      // Act
      cubit.applyFilterResults([third]);

      // Assert
      expect(cubit.state.focusedFilterPropertyId, third.propertyId);
    });

    test('should preserve filter focus after selecting and closing marker card', () async {
      // Arrange
      final first = createMapProperty(
        propertyId: 'first',
        latitude: 21,
        longitude: 105,
      );
      cubit.applyFilterResults([first]);

      // Act
      await cubit.selectProperty(first.propertyId);
      cubit.clearSelection();

      // Assert
      expect(cubit.state.focusedFilterPropertyId, first.propertyId);
    });
  });
}
