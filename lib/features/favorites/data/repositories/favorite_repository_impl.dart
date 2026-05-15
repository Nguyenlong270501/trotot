import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../datasources/favorite_remote_data_source.dart';
import '../models/favorite_property_model.dart';
import 'favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl(this._remoteDataSource);

  final FavoriteRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, int>> getFavoritesCount({required String uid}) async {
    try {
      final count = await _remoteDataSource.getFavoritesCount(uid: uid);
      return Right(count);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveFavorite({
    required String uid,
    required FavoritePropertyModel favorite,
  }) async {
    try {
      await _remoteDataSource.saveFavorite(uid: uid, favorite: favorite);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite({
    required String uid,
    required String propertyId,
  }) async {
    try {
      await _remoteDataSource.removeFavorite(uid: uid, propertyId: propertyId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Stream<bool> watchIsFavorited({
    required String uid,
    required String propertyId,
  }) {
    return _remoteDataSource.watchIsFavorited(uid: uid, propertyId: propertyId);
  }

  @override
  Stream<List<FavoritePropertyModel>> watchFavorites({required String uid}) {
    return _remoteDataSource.watchFavorites(uid: uid);
  }
}