import 'package:flutter_test/flutter_test.dart';
import 'package:trotot/features/appointment/blocs/appointment_create/appointment_create_cubit.dart';
import 'package:trotot/features/appointment/data/models/appointment_model.dart';

import '../../../../shared/appointment_fakes.dart';

void main() {
  group('AppointmentCreateCubit.cancelAccepted', () {
    late FakeAppointmentRepository repository;
    late AppointmentCreateCubit cubit;

    setUp(() {
      repository = FakeAppointmentRepository();
      cubit = AppointmentCreateCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('should cancel accepted appointment with tenant reason', () async {
      // Arrange
      final appointment = createAppointment();

      // Act
      await cubit.cancelAccepted(
        appointment: appointment,
        reason: '  Khong the den  ',
      );

      // Assert
      expect(
        repository.updatedAppointment?.status,
        AppointmentStatus.cancelled,
      );
      expect(repository.updatedAppointment?.cancelledBy, 'tenant');
      expect(
        repository.updatedAppointment?.tenantCancelReason,
        'Khong the den',
      );
    });

    test(
      'should reject empty cancellation reason without updating repository',
      () async {
        // Arrange
        final appointment = createAppointment();

        // Act
        await cubit.cancelAccepted(appointment: appointment, reason: ' ');

        // Assert
        expect(repository.updatedAppointment, isNull);
        expect(cubit.state.errorMessage, isNotEmpty);
      },
    );
  });

  group('AppointmentCreateCubit.updateAppointment', () {
    late FakeAppointmentRepository repository;
    late AppointmentCreateCubit cubit;

    setUp(() {
      repository = FakeAppointmentRepository();
      cubit = AppointmentCreateCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test(
      'should clear tenant cancellation metadata when resubmitting',
      () async {
        // Arrange
        final appointment = createAppointment(
          status: AppointmentStatus.pending,
          tenantCancelReason: 'Khong the den',
          cancelledBy: 'tenant',
        );

        // Act
        await cubit.updateAppointment(appointment: appointment);

        // Assert
        expect(repository.updatedAppointment?.tenantCancelReason, isNull);
        expect(repository.updatedAppointment?.cancelledBy, isNull);
        expect(cubit.state.existingAppointment?.tenantCancelReason, isNull);
        expect(cubit.state.existingAppointment?.cancelledBy, isNull);
      },
    );
  });
}
