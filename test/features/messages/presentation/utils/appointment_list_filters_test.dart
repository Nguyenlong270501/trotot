import 'package:flutter_test/flutter_test.dart';
import 'package:trotot/features/appointment/data/models/appointment_model.dart';
import 'package:trotot/features/messages/presentation/utils/appointment_list_filters.dart';

void main() {
  group('filterHistoryAppointments', () {
    final now = DateTime(2026, 6, 2, 12);

    test('should include accepted appointment when appointment is expired', () {
      // Arrange
      final expired = _appointment(
        id: 'expired',
        status: AppointmentStatus.accepted,
        appointmentDate: now.subtract(const Duration(minutes: 1)),
      );

      // Act
      final history = filterHistoryAppointments([expired], now: now);

      // Assert
      expect(history, [expired]);
    });

    test('should exclude accepted appointment when appointment is upcoming', () {
      // Arrange
      final upcoming = _appointment(
        id: 'upcoming',
        status: AppointmentStatus.accepted,
        appointmentDate: now.add(const Duration(minutes: 1)),
      );

      // Act
      final history = filterHistoryAppointments([upcoming], now: now);

      // Assert
      expect(history, isEmpty);
    });

    test('should exclude accepted appointment when appointment starts now', () {
      // Arrange
      final startsNow = _appointment(
        id: 'starts-now',
        status: AppointmentStatus.accepted,
        appointmentDate: now,
      );

      // Act
      final history = appointmentsForTab(
        [startsNow],
        AppointmentFeedTab.history,
        now: now,
      );

      // Assert
      expect(history, isEmpty);
    });
  });
}

AppointmentModel _appointment({
  required String id,
  required String status,
  required DateTime appointmentDate,
}) {
  return AppointmentModel(
    appointmentId: id,
    propertyId: 'property',
    tenantId: 'tenant',
    landlordId: 'landlord',
    appointmentDate: appointmentDate,
    purpose: 'Xem lan dau',
    note: '',
    status: status,
    propertyTitle: 'Phong tro',
    propertyAddress: 'Ha Noi',
    tenantName: 'Tenant',
    tenantPhone: '0900000000',
  );
}
