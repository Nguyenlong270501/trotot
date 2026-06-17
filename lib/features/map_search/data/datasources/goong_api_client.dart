import '../../../../core/confic/app_evn.dart';

/// Goong REST API v2 — use for autocomplete/geocode (not property listings).
abstract final class GoongApiClient {
  static const String baseUrl = 'https://rsapi.goong.io/v2';

  static String get apiKey => AppEnv.goongApiKey;

  static Uri autocompleteUri({
    required String input,
    required double latitude,
    required double longitude,
    int limit = 10,
  }) {
    return Uri.parse('$baseUrl/place/autocomplete').replace(
      queryParameters: {
        'api_key': apiKey,
        'input': input,
        'location': '$latitude,$longitude',
        'limit': '$limit',
        'has_deprecated_administrative_unit': 'true',
      },
    );
  }

  static Uri detailUri({required String placeId}) {
    return Uri.parse('$baseUrl/place/detail').replace(
      queryParameters: {
        'api_key': apiKey,
        'place_id': placeId,
        'has_deprecated_administrative_unit': 'true',
      },
    );
  }
}
