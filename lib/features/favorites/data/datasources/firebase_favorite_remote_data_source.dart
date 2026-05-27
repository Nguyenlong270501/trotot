import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favorite_property_model.dart';
import 'favorite_remote_data_source.dart';

class FirebaseFavoriteRemoteDataSource implements FavoriteRemoteDataSource {
  FirebaseFavoriteRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _favoritesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  @override
  Future<int> getFavoritesCount({required String uid}) async {
    final snapshot = await _favoritesRef(uid).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> saveFavorite({
    required String uid,
    required FavoritePropertyModel favorite,
  }) async {
    await _favoritesRef(uid).doc(favorite.propertyId).set(favorite.toMap());
  }

  @override
  Future<void> removeFavorite({
    required String uid,
    required String propertyId,
  }) async {
    await _favoritesRef(uid).doc(propertyId).delete();
  }

  @override
  Stream<bool> watchIsFavorited({
    required String uid,
    required String propertyId,
  }) {
    return _favoritesRef(
      uid,
    ).doc(propertyId).snapshots().map((doc) => doc.exists);
  }

  static const int maxFavoritesInStream = 50;

  @override
  Stream<List<FavoritePropertyModel>> watchFavorites({required String uid}) {
    return _favoritesRef(uid)
        .where('status', isEqualTo: 'approved')
        .orderBy('favoritedAt', descending: true)
        .limit(maxFavoritesInStream)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FavoritePropertyModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
