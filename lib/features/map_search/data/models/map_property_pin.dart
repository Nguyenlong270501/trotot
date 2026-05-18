import 'package:equatable/equatable.dart';

class MapPropertyPin extends Equatable {
  const MapPropertyPin({
    required this.propertyId,
    required this.latitude,
    required this.longitude,
    required this.priceLabel,
  });

  final String propertyId;
  final double latitude;
  final double longitude;

  /// Compact price text for the map marker (e.g. `5.5Tr`, `4 - 6 Tr`).
  final String priceLabel;

  @override
  List<Object?> get props => [propertyId, latitude, longitude, priceLabel];
}
