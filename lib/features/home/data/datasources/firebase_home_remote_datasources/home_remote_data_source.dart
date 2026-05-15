import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/property_details_bundle.dart';
import '../../models/property_model.dart';
import '../../models/room_filter_draft.dart';
import '../../models/suggested_properties_page.dart';

abstract class HomeRemoteDataSource {
  Future<SuggestedPropertiesPage> fetchSearchFilterPoolPage({
    required RoomFilterCriteria criteria,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit,
  });

  Stream<List<PropertyModel>> watchSearchFilterProperties({
    required RoomFilterCriteria criteria,
    int limit,
  });

  Stream<List<PropertyModel>> watchSuggestedProperties({
    required String city,
    int limit,
  });

  Stream<List<PropertyModel>> watchLatestPropertiesByType({
    required String city,
    required String propertyType,
    int limit,
  });

  Stream<PropertyDetailsBundle> watchPropertyDetailsBundle({
    required String propertyId,
  });

  Future<bool> hasApprovedPropertyForType({
    required String city,
    required String propertyType,
  });
}
