import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../auth/data/models/user.dart';
import 'landlord_profile_remote_data_source.dart';

class FirebaseLandlordProfileRemoteDataSource
    implements LandlordProfileRemoteDataSource {
  FirebaseLandlordProfileRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<UserModel?> fetchProfileForLandlord(String landlordId) async {
    final id = landlordId.trim();
    if (id.isEmpty) return null;

    final userDoc = await _firestore.collection('users').doc(id).get();
    if (!userDoc.exists || userDoc.data() == null) return null;

    final data = Map<String, dynamic>.from(userDoc.data()!);
    data['userId'] = data['userId'] ?? userDoc.id;
    return UserModel.fromMap(data);
  }
}
