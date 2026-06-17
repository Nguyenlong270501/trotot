class MapLocationResult {
  const MapLocationResult({
    required this.latitude,
    required this.longitude,
    required this.fromDevice,
  });

  static const double defaultLatitude = 21.03705745059285;
  static const double defaultLongitude = 105.83465594008526;

  final double latitude;
  final double longitude;
  final bool fromDevice;

  factory MapLocationResult.defaultCenter() {
    return const MapLocationResult(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      fromDevice: false,
    );
  }
}
