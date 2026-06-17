import 'package:cloud_firestore/cloud_firestore.dart';

final class AppointmentStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String rescheduled = 'rescheduled';
  static const String success = 'success';
  static const String cancelled = 'cancelled';

  static const Set<String> values = <String>{
    pending,
    accepted,
    rejected,
    rescheduled,
    success,
    cancelled,
  };
}

class AppointmentModel {
  const AppointmentModel({
    required this.appointmentId,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.appointmentDate,
    required this.purpose,
    required this.note,
    required this.status,
    this.createdAt,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.tenantName,
    required this.tenantPhone,
    this.landlordCancelReason,
    this.tenantCancelReason,
    this.cancelledBy,
    this.acceptedBy,
  });

  final String appointmentId;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final DateTime appointmentDate;
  final String purpose;
  final String note;
  final String status;
  final DateTime? createdAt;
  final String propertyTitle;
  final String propertyAddress;
  final String tenantName;
  final String tenantPhone;
  final String? landlordCancelReason;
  final String? tenantCancelReason;
  final String? cancelledBy;
  final String? acceptedBy;

  AppointmentModel copyWith({
    String? appointmentId,
    String? propertyId,
    String? tenantId,
    String? landlordId,
    DateTime? appointmentDate,
    String? purpose,
    String? note,
    String? status,
    DateTime? createdAt,
    String? propertyTitle,
    String? propertyAddress,
    String? tenantName,
    String? tenantPhone,
    String? landlordCancelReason,
    String? tenantCancelReason,
    String? cancelledBy,
    String? acceptedBy,
    bool clearTenantCancelReason = false,
    bool clearCancelledBy = false,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      purpose: purpose ?? this.purpose,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      landlordCancelReason: landlordCancelReason ?? this.landlordCancelReason,
      tenantCancelReason: clearTenantCancelReason
          ? null
          : tenantCancelReason ?? this.tenantCancelReason,
      cancelledBy: clearCancelledBy ? null : cancelledBy ?? this.cancelledBy,
      acceptedBy: acceptedBy ?? this.acceptedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'propertyId': propertyId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'purpose': purpose,
      'note': note,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'propertyTitle': propertyTitle,
      'propertyAddress': propertyAddress,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      if (landlordCancelReason != null)
        'landlordCancelReason': landlordCancelReason,
      if (tenantCancelReason != null) 'tenantCancelReason': tenantCancelReason,
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      if (acceptedBy != null) 'acceptedBy': acceptedBy,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    final rawStatus = (map['status'] ?? AppointmentStatus.pending).toString();
    final normalizedStatus = AppointmentStatus.values.contains(rawStatus)
        ? rawStatus
        : AppointmentStatus.pending;

    return AppointmentModel(
      appointmentId: (map['appointmentId'] ?? '').toString(),
      propertyId: (map['propertyId'] ?? '').toString(),
      tenantId: (map['tenantId'] ?? '').toString(),
      landlordId: (map['landlordId'] ?? '').toString(),
      appointmentDate: _parseDateTime(map['appointmentDate']),
      purpose: (map['purpose'] ?? '').toString(),
      note: (map['note'] ?? '').toString(),
      status: normalizedStatus,
      createdAt: _parseNullableDateTime(map['createdAt']),
      propertyTitle: (map['propertyTitle'] ?? '').toString(),
      propertyAddress: (map['propertyAddress'] ?? '').toString(),
      tenantName: (map['tenantName'] ?? '').toString(),
      tenantPhone: (map['tenantPhone'] ?? '').toString(),
      landlordCancelReason: _parseOptionalString(map['landlordCancelReason']),
      tenantCancelReason: _parseOptionalString(map['tenantCancelReason']),
      cancelledBy: _parseOptionalString(map['cancelledBy']),
      acceptedBy: _parseOptionalString(map['acceptedBy']),
    );
  }

  static String? _parseOptionalString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
