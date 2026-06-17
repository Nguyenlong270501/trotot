import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/appointment_model.dart';
import 'appointment_form_state.dart';

class AppointmentFormCubit extends Cubit<AppointmentFormState> {
  AppointmentFormCubit()
    : super(
        AppointmentFormState(
          selectedDate: DateTime.now(),
          selectedTime: TimeOfDay.now(),
        ),
      );

  void setSelectedDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void setSelectedTime(TimeOfDay time) {
    emit(state.copyWith(selectedTime: time));
  }

  void setSelectedPurpose(int index) {
    emit(state.copyWith(selectedPurpose: index));
  }

  void setTenantPhone(String phone) {
    emit(state.copyWith(tenantPhone: phone.trim()));
  }

  void setNote(String value) {
    emit(state.copyWith(note: value));
  }

  void hydrateFromAppointment(
    AppointmentModel appointment, {
    required List<String> purposeLabels,
  }) {
    final purposeIndex = purposeLabels.indexOf(appointment.purpose);
    emit(
      AppointmentFormState(
        selectedDate: appointment.appointmentDate,
        selectedTime: TimeOfDay(
          hour: appointment.appointmentDate.hour,
          minute: appointment.appointmentDate.minute,
        ),
        selectedPurpose: purposeIndex >= 0 ? purposeIndex : 0,
        tenantPhone: appointment.tenantPhone,
        note: appointment.note,
        editBaseline: appointment,
        confirmed: false,
      ),
    );
  }

  void syncBaselineFromAppointment(AppointmentModel appointment) {
    emit(
      state.copyWith(
        editBaseline: appointment,
        note: appointment.note,
        tenantPhone: appointment.tenantPhone,
        confirmed: false,
      ),
    );
  }

  void showConfirmedSuccess() {
    emit(state.copyWith(confirmed: true));
  }

  void hideConfirmedSuccess() {
    emit(state.copyWith(confirmed: false));
  }
}