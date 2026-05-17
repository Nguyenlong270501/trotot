import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/appointment_model.dart';
import '../../../data/repositories/appointment_repository.dart';
import 'appointment_create_state.dart';

class AppointmentCreateCubit extends Cubit<AppointmentCreateState> {
  AppointmentCreateCubit(this._repository)
    : super(const AppointmentCreateState());

  final AppointmentRepository _repository;

  Future<void> createAppointment({
    required String propertyId,
    required String tenantId,
    required String landlordId,
    required DateTime appointmentDate,
    required String purpose,
    required String note,
    required String propertyTitle,
    required String propertyAddress,
    required String tenantName,
    required String tenantPhone,
  }) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, clearError: true));

    final appointment = AppointmentModel(
      appointmentId: '',
      propertyId: propertyId.trim(),
      tenantId: tenantId.trim(),
      landlordId: landlordId.trim(),
      appointmentDate: appointmentDate,
      purpose: purpose.trim(),
      note: note.trim(),
      status: AppointmentStatus.pending,
      createdAt: null,
      propertyTitle: propertyTitle.trim(),
      propertyAddress: propertyAddress.trim(),
      tenantName: tenantName.trim(),
      tenantPhone: tenantPhone.trim(),
    );

    final result = await _repository.createAppointment(
      appointment: appointment,
      tenantId: tenantId,
      landlordId: landlordId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: failure.errorMessage?.toString(),
        ),
      ),
      (created) => emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          existingAppointment: created,
          lastOperationWasUpdate: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> updateAppointment({
    required AppointmentModel appointment,
  }) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, clearError: true));
    final result = await _repository.updateAppointment(
      appointment: appointment,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: failure.errorMessage?.toString(),
        ),
      ),
      (_) => emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          existingAppointment: appointment,
          lastOperationWasUpdate: true,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> acceptRescheduled({required AppointmentModel appointment}) async {
    await updateAppointment(
      appointment: appointment.copyWith(
        status: AppointmentStatus.accepted,
        acceptedBy: 'tenant',
      ),
    );
  }

  Future<void> rejectRescheduled({
    required AppointmentModel appointment,
    required String reason,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Vui lòng nhập lý do từ chối.',
        ),
      );
      return;
    }
    if (trimmedReason.length > 200) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Lý do từ chối tối đa 200 ký tự.',
        ),
      );
      return;
    }
    await updateAppointment(
      appointment: appointment.copyWith(
        status: AppointmentStatus.rejected,
        tenantCancelReason: trimmedReason,
        cancelledBy: 'tenant',
      ),
    );
  }

  void setExistingAppointment(AppointmentModel? appointment) {
    if (appointment == null ||
        appointment.appointmentId.trim().isEmpty) {
      emit(state.copyWith(clearExistingAppointment: true));
      return;
    }
    emit(state.copyWith(existingAppointment: appointment));
  }

  void clearFeedback() {
    emit(state.copyWith(isSuccess: false, clearError: true));
  }
}
