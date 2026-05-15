import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, AppointmentModel>> createAppointment({
    required AppointmentModel appointment,
    required String landlordId,
    required String tenantId,
  });
  Future<Either<Failure, void>> updateAppointment({
    required AppointmentModel appointment,
  });

  Future<Either<Failure, bool>> hasAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  });

  Future<Either<Failure, AppointmentModel?>> getLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  });

  Stream<AppointmentModel?> watchLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  });
}
