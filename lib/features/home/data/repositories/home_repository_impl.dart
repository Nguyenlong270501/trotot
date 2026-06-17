import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

import '../datasources/firebase_home_remote_datasources/firebase_home_remote_data_source.dart';

import '../datasources/firebase_home_remote_datasources/home_remote_data_source.dart';

import '../models/property_model.dart';

import '../models/room_filter_draft.dart';
import 'home_repository.dart';

import 'property_filter_matcher.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Stream<List<PropertyModel>> watchSuggestedProperties({required String city}) {
    return _remoteDataSource.watchSuggestedProperties(
      city: city,
      limit: FirebaseHomeRemoteDataSource.suggestedPropertiesLimit,
    );
  }

  @override
  Stream<List<PropertyModel>> watchLatestPropertiesByType({
    required String city,
    required String propertyType,
  }) {
    return _remoteDataSource.watchLatestPropertiesByType(
      city: city,
      propertyType: propertyType,
      limit: FirebaseHomeRemoteDataSource.suggestedPropertiesLimit,
    );
  }

  static const int _filterResultCap = 120;
  static const int _filterMaxPoolPages = 24;

  @override
  Stream<List<PropertyModel>> watchFilterProperties(
    RoomFilterCriteria criteria,
  ) {
    return _remoteDataSource
        .watchSearchFilterProperties(
          criteria: criteria,
          limit: _filterResultCap,
        )
        .map(
          (pool) => PropertyFilterMatcher.applyCriteria(pool, criteria),
        );
  }

  @override
  Future<Either<Failure, List<PropertyModel>>> filterProperties(
    RoomFilterCriteria criteria,
  ) async {
    try {
      final merged = <PropertyModel>[];
      DocumentSnapshot<Map<String, dynamic>>? cursor;
      var reachedEnd = false;
      var pages = 0;

      while (merged.length < _filterResultCap &&
          pages < _filterMaxPoolPages &&
          !reachedEnd) {
        pages++;
        final page = await _remoteDataSource.fetchSearchFilterPoolPage(
          criteria: criteria,
          startAfter: cursor,
          limit: FirebaseHomeRemoteDataSource.searchFilterPoolPageSize,
        );
        final filtered = PropertyFilterMatcher.applyCriteria(
          page.properties,
          criteria,
        );
        merged.addAll(filtered);

        if (page.hasReachedMax || page.lastDocument == null) {
          reachedEnd = true;
        } else {
          cursor = page.lastDocument;
        }
      }

      if (merged.length > _filterResultCap) {
        return Right(merged.take(_filterResultCap).toList());
      }
      return Right(merged);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

}
