import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/services/local_location_service.dart';
import '../../models/property_details_bundle.dart';
import '../../models/property_model.dart';
import '../../models/room_filter_draft.dart';
import '../../models/room_model.dart';
import '../../models/suggested_properties_page.dart';
import 'home_remote_data_source.dart';

class FirebaseHomeRemoteDataSource implements HomeRemoteDataSource {
  FirebaseHomeRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  final Map<String, _CachedPropertyRooms> _roomsCacheByPropertyId = {};

  static const int suggestedPropertiesLimit = 10;
  static const int searchFilterPoolPageSize = 50;
  static const int searchFilterWatchLimit = 120;
  static const int firestoreInClauseLimit = 30;

  @override
  Stream<List<PropertyModel>> watchSearchFilterProperties({
    required RoomFilterCriteria criteria,
    int limit = searchFilterWatchLimit,
  }) {
    final query = _buildSearchFilterQuery(criteria);
    return query
        .limit(limit)
        .snapshots()
        .asyncMap(
          (snapshot) => Future.wait(
            snapshot.docs.map(
              (doc) => _documentToProperty(doc, criteria: criteria),
            ),
          ),
        );
  }

  @override
  Future<SuggestedPropertiesPage> fetchSearchFilterPoolPage({
    required RoomFilterCriteria criteria,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = searchFilterPoolPageSize,
  }) async {
    var query = _buildSearchFilterQuery(criteria);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    final docs = snapshot.docs;
    final properties = await Future.wait(
      docs.map((doc) => _documentToProperty(doc, criteria: criteria)),
    );
    final lastDoc = docs.isEmpty ? null : docs.last;
    final hasReachedMax = docs.length < limit;

    return SuggestedPropertiesPage(
      properties: properties.toList(),
      lastDocument: lastDoc,
      hasReachedMax: hasReachedMax,
    );
  }

  @override
  Stream<List<PropertyModel>> watchSuggestedProperties({
    required String city,
    int limit = suggestedPropertiesLimit,
  }) {
    var query = _firestore
        .collection('properties')
        .where('status', isEqualTo: 'approved');
    query = _applyCityFilter(query, city);
    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap(
          (snapshot) => Future.wait(snapshot.docs.map(_documentToProperty)),
        );
  }

  @override
  Stream<List<PropertyModel>> watchLatestPropertiesByType({
    required String city,
    required String propertyType,
    int limit = suggestedPropertiesLimit,
  }) {
    final normalizedType = PropertyConstants.normalizePropertyType(propertyType);
    var query = _firestore
        .collection('properties')
        .where('status', isEqualTo: 'approved');
    query = _applyCityFilter(query, city);
    return query
        .where('propertyTypes', arrayContains: normalizedType)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap(
          (snapshot) => Future.wait(snapshot.docs.map(_documentToProperty)),
        );
  }

  @override
  Stream<PropertyDetailsBundle> watchPropertyDetailsBundle({
    required String propertyId,
  }) {
    final controller = StreamController<PropertyDetailsBundle>();
    PropertyModel? latestProperty;
    List<RoomModel>? latestRooms;
    var propertyReady = false;
    var roomsReady = false;

    void publish() {
      if (!propertyReady || !roomsReady) {
        return;
      }
      if (latestProperty == null) {
        controller.add(const PropertyDetailsBundle.missing());
        return;
      }
      final rooms = List<RoomModel>.from(latestRooms ?? const []);
      rooms.sort((a, b) => compareNatural(a.roomName, b.roomName));
      controller.add(
        PropertyDetailsBundle(property: latestProperty, rooms: rooms),
      );
    }

    final propertySub = _firestore
        .collection('properties')
        .doc(propertyId)
        .snapshots()
        .listen(
          (snapshot) {
            propertyReady = true;
            if (!snapshot.exists) {
              latestProperty = null;
              publish();
              return;
            }
            final raw = snapshot.data();
            if (raw == null) {
              return;
            }
            final map = Map<String, dynamic>.from(raw);
            map['propertyId'] = snapshot.id;
            latestProperty = PropertyModel.fromMap(map);
            publish();
          },
          onError: controller.addError,
        );

    final roomsSub = _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('rooms')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            roomsReady = true;
            final landlordId = latestProperty?.landlordId ?? '';
            latestRooms = snapshot.docs.map((doc) {
              final map = Map<String, dynamic>.from(doc.data());
              map['roomId'] = doc.id;
              map['propertyId'] = propertyId;
              map['landlordId'] = landlordId;
              return RoomModel.fromMap(map);
            }).toList();
            publish();
          },
          onError: controller.addError,
        );

    controller.onCancel = () async {
      await propertySub.cancel();
      await roomsSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<bool> hasApprovedPropertyForType({
    required String city,
    required String propertyType,
  }) async {
    final normalizedType = PropertyConstants.normalizePropertyType(propertyType);
    var query = _firestore
        .collection('properties')
        .where('status', isEqualTo: 'approved');
    query = _applyCityFilter(query, city);
    final snapshot = await query
        .where('propertyTypes', arrayContains: normalizedType)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Bước 1: lọc property trên Firestore theo minRoomPrice/maxRoomPrice (overlap union bracket).
  Query<Map<String, dynamic>> _applyPropertyPriceBounds(
    Query<Map<String, dynamic>> query,
    RoomFilterCriteria criteria,
  ) {
    final bounds = PropertyConstants.priceBracketSearchUnion(
      criteria.selectedPriceBracketIndexes,
    );
    if (bounds == null) {
      return query;
    }
    return query
        .where('minRoomPrice', isLessThanOrEqualTo: bounds.maxInclusive)
        .where('maxRoomPrice', isGreaterThanOrEqualTo: bounds.minInclusive);
  }

  ({int minInclusive, int maxInclusive})? _roomPriceBoundsForCriteria(
    RoomFilterCriteria criteria,
  ) {
    return PropertyConstants.priceBracketSearchUnion(
      criteria.selectedPriceBracketIndexes,
    );
  }

  Query<Map<String, dynamic>> _buildSearchFilterQuery(
    RoomFilterCriteria criteria,
  ) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('properties')
        .where('status', isEqualTo: 'approved');

    final city = criteria.city?.trim();
    if (city != null && city.isNotEmpty) {
      query = _applyCityFilter(query, city);
    }

    final wardList = LocalLocationService()
        .wardCodenamesForQuery(
          city: criteria.city,
          wards: criteria.selectedWards,
        )
        .take(firestoreInClauseLimit)
        .toList();
    if (wardList.isNotEmpty) {
      query = query.where('ward', whereIn: wardList);
    }

    final typeList = criteria.selectedPropertyTypes
        .map(PropertyConstants.normalizePropertyType)
        .where((e) => e.isNotEmpty)
        .take(firestoreInClauseLimit)
        .toList();
    if (typeList.length == 1) {
      query = query.where('propertyTypes', arrayContains: typeList.first);
    } else if (typeList.length > 1) {
      query = query.where('propertyTypes', arrayContainsAny: typeList);
    }

    query = _applyPropertyPriceBounds(query, criteria);

    return query.orderBy('createdAt', descending: true);
  }

  Query<Map<String, dynamic>> _applyCityFilter(
    Query<Map<String, dynamic>> query,
    String city,
  ) {
    final cityValues = PropertyConstants.firestoreCityAliases(city)
        .take(firestoreInClauseLimit)
        .toList();
    if (cityValues.isEmpty) {
      return query;
    }
    if (cityValues.length == 1) {
      return query.where('city', isEqualTo: cityValues.first);
    }
    return query.where('city', whereIn: cityValues);
  }

  Future<PropertyModel> _documentToProperty(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    RoomFilterCriteria? criteria,
  }) async {
    final raw = doc.data();
    final data = raw != null
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    data['propertyId'] = doc.id;
    final updatedAt = _readUpdatedAt(data['updatedAt']);

    List<RoomModel> rooms;
    if (criteria == null) {
      final cached = _roomsCacheByPropertyId[doc.id];
      if (cached != null && cached.updatedAt == updatedAt) {
        rooms = cached.rooms;
      } else {
        rooms = await _fetchAvailableRooms(
          doc: doc,
          propertyId: doc.id,
          landlordId: data['landlordId']?.toString() ?? '',
        );
        _roomsCacheByPropertyId[doc.id] = _CachedPropertyRooms(
          updatedAt: updatedAt,
          rooms: rooms,
        );
      }
    } else {
      final roomBounds = _roomPriceBoundsForCriteria(criteria);
      rooms = await _fetchAvailableRooms(
        doc: doc,
        propertyId: doc.id,
        landlordId: data['landlordId']?.toString() ?? '',
        minPrice: roomBounds?.minInclusive,
        maxPrice: roomBounds?.maxInclusive,
      );
    }

    return PropertyModel.fromMap(data).copyWith(rooms: rooms);
  }

  static DateTime _readUpdatedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<List<RoomModel>> _fetchAvailableRooms({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required String propertyId,
    required String landlordId,
    int? minPrice,
    int? maxPrice,
  }) async {
    var roomsQuery = doc.reference
        .collection('rooms')
        .where('isAvailable', isEqualTo: true);
    if (minPrice != null && maxPrice != null) {
      roomsQuery = roomsQuery
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice);
    }
    final roomsSnapshot = await roomsQuery.get();

    final rooms = roomsSnapshot.docs.map((roomDoc) {
      final roomData = Map<String, dynamic>.from(roomDoc.data());
      roomData['roomId'] = roomDoc.id;
      roomData['propertyId'] = propertyId;
      roomData['landlordId'] = landlordId;
      return RoomModel.fromMap(roomData);
    }).toList();

    rooms.sort((a, b) => compareNatural(a.roomName, b.roomName));
    return rooms;
  }
}

class _CachedPropertyRooms {
  const _CachedPropertyRooms({
    required this.updatedAt,
    required this.rooms,
  });

  final DateTime updatedAt;
  final List<RoomModel> rooms;
}
