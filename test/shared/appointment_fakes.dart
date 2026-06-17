import 'package:dartz/dartz.dart';
import 'package:trotot/core/errors/failure.dart';
import 'package:trotot/features/appointment/data/models/appointment_model.dart';
import 'package:trotot/features/appointment/data/repositories/appointment_repository.dart';

class FakeAppointmentRepository implements AppointmentRepository {
  AppointmentModel? updatedAppointment;

  @override
  Future<Either<Failure, AppointmentModel>> createAppointment({
    required AppointmentModel appointment,
    required String landlordId,
    required String tenantId,
  }) async {
    return Right(appointment);
  }

  @override
  Future<Either<Failure, AppointmentModel?>> getLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> hasAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, void>> updateAppointment({
    required AppointmentModel appointment,
  }) async {
    updatedAppointment = appointment;
    return const Right(null);
  }

  @override
  Stream<AppointmentModel?> watchLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) {
    return const Stream.empty();
  }
}

AppointmentModel createAppointment({
  String status = AppointmentStatus.accepted,
  String? tenantCancelReason,
  String? cancelledBy,
}) {
  return AppointmentModel(
    appointmentId: 'appointment',
    propertyId: 'property',
    tenantId: 'tenant',
    landlordId: 'landlord',
    appointmentDate: DateTime(2026, 6, 2, 12),
    purpose: 'Xem lan dau',
    note: '',
    status: status,
    propertyTitle: 'Phong tro',
    propertyAddress: 'Ha Noi',
    tenantName: 'Tenant',
    tenantPhone: '0900000000',
    tenantCancelReason: tenantCancelReason,
    cancelledBy: cancelledBy,
  );
}
