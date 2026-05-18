import '../../../home/data/models/property_model.dart';
import '../datasources/map_property_remote_data_source.dart';
import '../models/map_property_pin.dart';
import '../models/map_visible_bounds.dart';

class MapPropertyRepository {
  MapPropertyRepository({required MapPropertyRemoteDataSource remote})
    : _remote = remote;

  final MapPropertyRemoteDataSource _remote;

  Future<List<MapPropertyPin>> fetchApprovedInBounds(MapVisibleBounds bounds) =>
      _remote.fetchApprovedInBounds(bounds);

  Future<PropertyModel?> fetchPropertyForMapCard(String propertyId) =>
      _remote.fetchPropertyForMapCard(propertyId);
}
