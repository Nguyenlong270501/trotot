import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../../../../core/utils/property_helper.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_model.dart';
import '../../../../core/constants/map_search_constants.dart';
import '../models/map_property_pin.dart';
import '../models/map_visible_bounds.dart';

abstract class MapPropertyRemoteDataSource {
  Future<List<MapPropertyPin>> fetchApprovedInBounds(MapVisibleBounds bounds);

  Future<PropertyModel?> fetchPropertyForMapCard(String propertyId);
}

class FirebaseMapPropertyRemoteDataSource
    implements MapPropertyRemoteDataSource {
  FirebaseMapPropertyRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<MapPropertyPin>> fetchApprovedInBounds(
    MapVisibleBounds bounds,
  ) async {
    final snapshot = await _firestore
        .collection('properties')
        .where('status', isEqualTo: 'approved')
        .where('latitude', isGreaterThanOrEqualTo: bounds.southwestLat)
        .where('latitude', isLessThanOrEqualTo: bounds.northeastLat)
        .orderBy('latitude')
        .limit(MapSearchConstants.mapPropertyFetchLimit)
        .get();

    final pins = <MapPropertyPin>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final lat = _readDouble(data['latitude']);
      final lng = _readDouble(data['longitude']);
      if (lat == null || lng == null) {
        continue;
      }

      if (!bounds.containsPoint(lat, lng)) {
        continue;
      }

      pins.add(
        MapPropertyPin(
          propertyId: doc.id,
          latitude: lat,
          longitude: lng,
          priceLabel: PropertyHelper.mapMarkerPriceLabel(
            minRoomPrice: _readInt(data['minRoomPrice']),
            maxRoomPrice: _readInt(data['maxRoomPrice']),
          ),
        ),
      );

      if (pins.length >= MapSearchConstants.mapPropertyRenderLimit) {
        break;
      }
    }

    return pins;
  }

  @override
  Future<PropertyModel?> fetchPropertyForMapCard(String propertyId) async {
    final doc = await _firestore.collection('properties').doc(propertyId).get();
    if (!doc.exists) {
      return null;
    }

    final raw = doc.data();
    if (raw == null) {
      return null;
    }

    final data = Map<String, dynamic>.from(raw);
    data['propertyId'] = doc.id;

    final roomsSnapshot = await doc.reference
        .collection('rooms')
        .where('isAvailable', isEqualTo: true)
        .get();

    final rooms = roomsSnapshot.docs.map((roomDoc) {
      final roomData = Map<String, dynamic>.from(roomDoc.data());
      roomData['roomId'] = roomDoc.id;
      roomData['propertyId'] = data['propertyId'];
      roomData['landlordId'] = data['landlordId'];
      return RoomModel.fromMap(roomData);
    }).toList();

    rooms.sort((a, b) => compareNatural(a.roomName, b.roomName));

    return PropertyModel.fromMap(data).copyWith(rooms: rooms);
  }

  static int? _readInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static double? _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
