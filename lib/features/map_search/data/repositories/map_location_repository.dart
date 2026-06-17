import '../datasources/map_location_remote_data_source.dart';
import '../models/map_location_result.dart';

class MapLocationRepository {
  MapLocationRepository({required MapLocationRemoteDataSource remote})
    : _remote = remote;

  final MapLocationRemoteDataSource _remote;

  Future<MapLocationResult> resolveMapCenter() => _remote.resolveMapCenter();
}
