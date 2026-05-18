import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/confic/app_evn.dart';
import '../../data/models/map_location_result.dart';

class MapSearchView extends StatelessWidget {
  const MapSearchView({
    super.key,
    required this.initialZoom,
    required this.onMapCreated,
    required this.onStyleLoaded,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onMapClick,
  });

  final double initialZoom;
  final ValueChanged<MapLibreMapController> onMapCreated;
  final VoidCallback onStyleLoaded;
  final ValueChanged<CameraPosition> onCameraMove;
  final VoidCallback onCameraIdle;
  final void Function(Point<double> point, LatLng latLng) onMapClick;

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString:
          'https://tiles.goong.io/assets/goong_map_web.json?api_key=${AppEnv.goongMaptilesKey}',
      initialCameraPosition: CameraPosition(
        target: LatLng(
          MapLocationResult.defaultLatitude,
          MapLocationResult.defaultLongitude,
        ),
        zoom: initialZoom,
      ),
      myLocationEnabled: true,
      myLocationTrackingMode: MyLocationTrackingMode.none,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      onMapCreated: onMapCreated,
      onStyleLoadedCallback: onStyleLoaded,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      onMapClick: onMapClick,
    );
  }
}