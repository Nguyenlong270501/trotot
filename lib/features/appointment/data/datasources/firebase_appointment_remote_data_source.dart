import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';
import 'appointment_remote_data_source.dart';

class FirebaseAppointmentRemoteDataSource
    implements AppointmentRemoteDataSource {
  FirebaseAppointmentRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _appointmentsRef =>
      _firestore.collection('appointments');

  @override
  Future<AppointmentModel> createAppointment({
    required AppointmentModel appointment,
    required String landlordId,
    required String tenantId,
  }) async {
    if (landlordId == tenantId) {
      throw Exception('Bạn không thể tự đặt lịch xem phòng của chính mình!');
    }
    final docRef = _appointmentsRef.doc();
    final model = appointment.copyWith(appointmentId: docRef.id);
    await docRef.set(model.toMap());
    return model;
  }

  @override
  Future<void> updateAppointment({
    required AppointmentModel appointment,
  }) async {
    final updateData = <String, dynamic>{
      'appointmentDate': Timestamp.fromDate(appointment.appointmentDate),
      'purpose': appointment.purpose,
      'note': appointment.note,
      'status': appointment.status,
      'tenantPhone': appointment.tenantPhone,
    };
    if (appointment.landlordCancelReason != null) {
      updateData['landlordCancelReason'] = appointment.landlordCancelReason;
    }
    updateData['tenantCancelReason'] =
        appointment.tenantCancelReason ?? FieldValue.delete();
    updateData['cancelledBy'] = appointment.cancelledBy ?? FieldValue.delete();
    if (appointment.acceptedBy != null) {
      updateData['acceptedBy'] = appointment.acceptedBy;
    }
    await _appointmentsRef.doc(appointment.appointmentId).update(updateData);
  }

  @override
  Future<bool> hasAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) async {
    final snapshot = await _appointmentsRef
        .where('tenantId', isEqualTo: tenantId)
        .where('propertyId', isEqualTo: propertyId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<AppointmentModel?> getLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) async {
    final snapshot = await _appointmentsRef
        .where('tenantId', isEqualTo: tenantId)
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }
    return AppointmentModel.fromMap(snapshot.docs.first.data());
  }

  @override
  Stream<AppointmentModel?> watchLatestAppointmentForProperty({
    required String tenantId,
    required String propertyId,
  }) {
    return _appointmentsRef
        .where('tenantId', isEqualTo: tenantId)
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          return AppointmentModel.fromMap(snapshot.docs.first.data());
        });
  }
}
