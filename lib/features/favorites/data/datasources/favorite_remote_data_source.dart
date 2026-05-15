import '../models/favorite_property_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<int> getFavoritesCount({required String uid});

  Future<void> saveFavorite({
    required String uid,
    required FavoritePropertyModel favorite,
  });

  Future<void> removeFavorite({
    required String uid,
    required String propertyId,
  });

  Stream<bool> watchIsFavorited({
    required String uid,
    required String propertyId,
  });

  Stream<List<FavoritePropertyModel>> watchFavorites({required String uid});
}