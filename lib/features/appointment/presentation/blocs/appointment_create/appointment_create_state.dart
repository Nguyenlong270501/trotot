import 'package:equatable/equatable.dart';

import '../../../data/models/appointment_model.dart';

final class AppointmentCreateState extends Equatable {
  const AppointmentCreateState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.existingAppointment,
    this.lastOperationWasUpdate = false,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final AppointmentModel? existingAppointment;
  final bool lastOperationWasUpdate;

  bool get isUpdateMode =>
      (existingAppointment?.appointmentId ?? '').trim().isNotEmpty;

  AppointmentCreateState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    AppointmentModel? existingAppointment,
    bool? lastOperationWasUpdate,
    bool clearExistingAppointment = false,
    bool clearError = false,
  }) {
    return AppointmentCreateState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      existingAppointment: clearExistingAppointment
          ? null
          : (existingAppointment ?? this.existingAppointment),
      lastOperationWasUpdate:
          lastOperationWasUpdate ?? this.lastOperationWasUpdate,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSuccess,
    errorMessage,
    existingAppointment,
    lastOperationWasUpdate,
  ];
}