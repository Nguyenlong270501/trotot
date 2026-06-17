import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../datasources/appointment_remote_data_source.dart';
import '../models/appointment_model.dart';
import 'appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._remoteDataSource);

  final AppointmentRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AppointmentModel>> createAppointment({
    required AppointmentModel appointment,
    required String landlordId,
    required String tenantId,
  }) async {
    try {
      final created = await _remoteDataSource.createAppointment(
        appointment: appointment,
        tenantId: tenantId,
        landlordId: landlordId,
      );
      return Right(created);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAppointment({
    required AppointmentModel appointment,
  }) async {
    try {
      await _remoteDataSource.updateAppointment(appointment: appointment);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) async {
    try {
      final exists = await _remoteDataSource.hasAppointmentForProperty(
        tenantId: tenantId,
        propertyId: propertyId,
      );
      return Right(exists);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentModel?>> getLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) async {
    try {
      final appointment = await _remoteDataSource
          .getLatestAppointmentForProperty(
            tenantId: tenantId,
            propertyId: propertyId,
          );
      return Right(appointment);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(errorMessage: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Stream<AppointmentModel?> watchLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) {
    return _remoteDataSource.watchLatestAppointmentForProperty(
      tenantId: tenantId,
      propertyId: propertyId,
    );
  }
}
