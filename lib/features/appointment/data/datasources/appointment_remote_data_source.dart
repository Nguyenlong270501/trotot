import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentModel> createAppointment({
    required AppointmentModel appointment,
    required String landlordId,
    required String tenantId,
  });
  Future<void> updateAppointment({required AppointmentModel appointment});

  Future<bool> hasAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  });

  Future<AppointmentModel?> getLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  });

  Stream<AppointmentModel?> watchLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  });
}
