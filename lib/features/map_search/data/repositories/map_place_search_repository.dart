import '../datasources/goong_place_remote_data_source.dart';
import '../models/goong_autocomplete_prediction_model.dart';
import '../models/goong_place_detail_model.dart';

class MapPlaceSearchRepository {
  MapPlaceSearchRepository({required GoongPlaceRemoteDataSource remote})
    : _remote = remote;

  final GoongPlaceRemoteDataSource _remote;

  Future<List<GoongAutocompletePredictionModel>> autocomplete({
    required String input,
    required double latitude,
    required double longitude,
  }) {
    return _remote.autocomplete(
      input: input,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<GoongPlaceDetailModel> detail({required String placeId}) {
    return _remote.detail(placeId: placeId);
  }
}
