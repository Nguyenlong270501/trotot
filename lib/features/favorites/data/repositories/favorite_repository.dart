import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/favorite_property_model.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, int>> getFavoritesCount({required String uid});

  Future<Either<Failure, void>> saveFavorite({
    required String uid,
    required FavoritePropertyModel favorite,
  });

  Future<Either<Failure, void>> removeFavorite({
    required String uid,
    required String propertyId,
  });

  Stream<bool> watchIsFavorited({
    required String uid,
    required String propertyId,
  });

  Stream<List<FavoritePropertyModel>> watchFavorites({required String uid});
}