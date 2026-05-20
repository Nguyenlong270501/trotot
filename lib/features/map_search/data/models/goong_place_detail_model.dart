import 'package:equatable/equatable.dart';

class GoongPlaceDetailModel extends Equatable {
  const GoongPlaceDetailModel({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  factory GoongPlaceDetailModel.fromMap(Map<String, dynamic> map) {
    final result = map['result'];
    final resultMap = result is Map
        ? Map<String, dynamic>.from(result)
        : Map<String, dynamic>.from(map);
    final geometry = resultMap['geometry'];
    final geometryMap = geometry is Map
        ? Map<String, dynamic>.from(geometry)
        : const <String, dynamic>{};
    final location = geometryMap['location'];
    final locationMap = location is Map
        ? Map<String, dynamic>.from(location)
        : const <String, dynamic>{};
    final lat = _readDouble(locationMap['lat']);
    final lng = _readDouble(locationMap['lng']);

    if (lat == null || lng == null) {
      throw const FormatException('Goong place detail missing coordinates');
    }

    final address = resultMap['formatted_address']?.toString().trim() ?? '';
    final name = resultMap['name']?.toString().trim() ?? '';

    return GoongPlaceDetailModel(
      placeId: resultMap['place_id']?.toString().trim() ?? '',
      name: name.isNotEmpty ? name : address,
      address: address,
      latitude: lat,
      longitude: lng,
    );
  }

  String get displayTitle => name.isNotEmpty ? name : address;

  static double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  @override
  List<Object?> get props => [placeId, name, address, latitude, longitude];
}
