import 'package:cloud_firestore/cloud_firestore.dart';

import 'property_model.dart';

class SuggestedPropertiesPage {
  const SuggestedPropertiesPage({
    required this.properties,
    required this.hasReachedMax,
    this.lastDocument,
  });

  final List<PropertyModel> properties;

  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  final bool hasReachedMax;
}
