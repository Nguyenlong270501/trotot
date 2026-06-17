import 'package:dio/dio.dart';

import '../models/goong_autocomplete_prediction_model.dart';
import '../models/goong_place_detail_model.dart';
import 'goong_api_client.dart';

abstract class GoongPlaceRemoteDataSource {
  Future<List<GoongAutocompletePredictionModel>> autocomplete({
    required String input,
    required double latitude,
    required double longitude,
  });

  Future<GoongPlaceDetailModel> detail({required String placeId});
}

class DioGoongPlaceRemoteDataSource implements GoongPlaceRemoteDataSource {
  DioGoongPlaceRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<List<GoongAutocompletePredictionModel>> autocomplete({
    required String input,
    required double latitude,
    required double longitude,
  }) async {
    final uri = GoongApiClient.autocompleteUri(
      input: input,
      latitude: latitude,
      longitude: longitude,
    );
    final response = await _dio.getUri(uri);
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Invalid Goong autocomplete response');
    }

    final predictions = data['predictions'];
    if (predictions is! List) {
      return const [];
    }

    return predictions
        .whereType<Map>()
        .map((item) {
          return GoongAutocompletePredictionModel.fromMap(
            Map<String, dynamic>.from(item),
          );
        })
        .where((prediction) => prediction.isValid)
        .toList();
  }

  @override
  Future<GoongPlaceDetailModel> detail({required String placeId}) async {
    final response = await _dio.getUri(
      GoongApiClient.detailUri(placeId: placeId),
    );
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Invalid Goong detail response');
    }

    return GoongPlaceDetailModel.fromMap(Map<String, dynamic>.from(data));
  }
}
