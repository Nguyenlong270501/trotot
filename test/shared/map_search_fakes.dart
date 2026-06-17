import 'package:trotot/features/home/data/models/property_model.dart';
import 'package:trotot/features/map_search/data/datasources/map_location_remote_data_source.dart';
import 'package:trotot/features/map_search/data/datasources/map_property_remote_data_source.dart';
import 'package:trotot/features/map_search/data/models/map_location_result.dart';
import 'package:trotot/features/map_search/data/models/map_property_pin.dart';
import 'package:trotot/features/map_search/data/models/map_visible_bounds.dart';

class FakeMapLocationRemoteDataSource implements MapLocationRemoteDataSource {
  @override
  Future<MapLocationResult> resolveMapCenter() async {
    return MapLocationResult.defaultCenter();
  }
}

class FakeMapPropertyRemoteDataSource implements MapPropertyRemoteDataSource {
  @override
  Future<List<MapPropertyPin>> fetchApprovedInBounds(
    MapVisibleBounds bounds,
  ) async {
    return const [];
  }

  @override
  Future<PropertyModel?> fetchPropertyForMapCard(String propertyId) async {
    return null;
  }
}

PropertyModel createMapProperty({
  required String propertyId,
  required double latitude,
  required double longitude,
}) {
  return PropertyModel.fromMap({
    'propertyId': propertyId,
    'latitude': latitude,
    'longitude': longitude,
    'createdAt': DateTime(2026),
    'updatedAt': DateTime(2026),
  });
}
