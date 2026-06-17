import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/map_location_result.dart';

abstract class MapLocationRemoteDataSource {
  Future<MapLocationResult> resolveMapCenter();
}

class GeolocatorMapLocationRemoteDataSource
    implements MapLocationRemoteDataSource {
  const GeolocatorMapLocationRemoteDataSource();

  static const Duration _locationTimeout = Duration(seconds: 10);

  @override
  Future<MapLocationResult> resolveMapCenter() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return MapLocationResult.defaultCenter();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return MapLocationResult.defaultCenter();
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return MapLocationResult(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          fromDevice: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: _locationTimeout,
        ),
      ).timeout(_locationTimeout);

      return MapLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        fromDevice: true,
      );
    } on TimeoutException {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return MapLocationResult(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          fromDevice: true,
        );
      }
      return MapLocationResult.defaultCenter();
    } catch (_) {
      return MapLocationResult.defaultCenter();
    }
  }
}
