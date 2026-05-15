import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../auth/data/models/user.dart';
import '../datasources/landlord_profile_remote_datasources/landlord_profile_remote_data_source.dart';
import 'landlord_profile_repository.dart';

class LandlordProfileRepositoryImpl implements LandlordProfileRepository {
  LandlordProfileRepositoryImpl(this._remoteDataSource);

  final LandlordProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UserModel>> getLandlordProfile(String landlordId) async {
    try {
      final user = await _remoteDataSource.fetchProfileForLandlord(landlordId);
      if (user == null) {
        return Left(
          ServerFailure(errorMessage: 'Không tìm thấy thông tin chủ nhà'),
        );
      }
      return Right(user);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }
}
