import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../../../../core/utils/property_helper.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_model.dart';
import '../../map_search_constants.dart';
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

  /// Firestore does not support range queries on [GeoPoint] subfields reliably.
  /// MVP: fetch a pool of approved listings, then filter by visible bounds client-side.
  static const int _clientFilterPoolLimit = 200;

  @override
  Future<List<MapPropertyPin>> fetchApprovedInBounds(
    MapVisibleBounds bounds,
  ) async {
    final snapshot = await _firestore
        .collection('properties')
        .where('status', isEqualTo: 'approved')
        .limit(_clientFilterPoolLimit)
        .get();

    final pins = <MapPropertyPin>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final location = _readLocation(data['location']);
      if (location == null) {
        continue;
      }

      final lat = location.latitude;
      final lng = location.longitude;
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

      if (pins.length >= MapSearchConstants.mapPropertyQueryLimit) {
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

  static GeoPoint? _readLocation(dynamic value) {
    if (value is GeoPoint) {
      return value;
    }
    if (value is Map) {
      final lat = (value['latitude'] ?? value['_latitude']);
      final lng = (value['longitude'] ?? value['_longitude']);
      if (lat == null || lng == null) {
        return null;
      }
      return GeoPoint(
        (lat as num).toDouble(),
        (lng as num).toDouble(),
      );
    }
    return null;
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
}
