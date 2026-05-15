import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../data/models/appointment_model.dart';

final class AppointmentFormState extends Equatable {
  const AppointmentFormState({
    required this.selectedDate,
    required this.selectedTime,
    this.selectedPurpose = 0,
    this.confirmed = false,
    this.tenantPhone = '',
    this.note = '',
    this.editBaseline,
  });

  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int selectedPurpose;
  final bool confirmed;
  final String tenantPhone;
  final String note;
  final AppointmentModel? editBaseline;

  bool get isEditMode => (editBaseline?.appointmentId ?? '').trim().isNotEmpty;

  AppointmentFormState copyWith({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    int? selectedPurpose,
    bool? confirmed,
    String? tenantPhone,
    String? note,
    AppointmentModel? editBaseline,
    bool clearEditBaseline = false,
  }) {
    return AppointmentFormState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedPurpose: selectedPurpose ?? this.selectedPurpose,
      confirmed: confirmed ?? this.confirmed,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      note: note ?? this.note,
      editBaseline: clearEditBaseline
          ? null
          : (editBaseline ?? this.editBaseline),
    );
  }

  String get dayName {
    const days = <String>[
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
    ];
    return days[selectedDate.weekday % 7];
  }

  String get formattedTime =>
      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.hour < 12 ? 'sáng' : 'chiều'}';

  DateTime get appointmentDateTime {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  bool hasUnsavedChanges(List<String> purposeLabels) {
    final baseline = editBaseline;
    if (baseline == null) {
      return true;
    }
    final purpose = purposeLabels[selectedPurpose.clamp(0, purposeLabels.length - 1)];
    return appointmentDateTime.year != baseline.appointmentDate.year ||
        appointmentDateTime.month != baseline.appointmentDate.month ||
        appointmentDateTime.day != baseline.appointmentDate.day ||
        appointmentDateTime.hour != baseline.appointmentDate.hour ||
        appointmentDateTime.minute != baseline.appointmentDate.minute ||
        purpose.trim() != baseline.purpose.trim() ||
        note.trim() != baseline.note.trim() ||
        tenantPhone.trim() != baseline.tenantPhone.trim();
  }

  @override
  List<Object?> get props => [
    selectedDate,
    selectedTime.hour,
    selectedTime.minute,
    selectedPurpose,
    confirmed,
    tenantPhone,
    note,
    editBaseline,
  ];
}
