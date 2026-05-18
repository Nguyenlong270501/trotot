import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../appointment/data/models/appointment_model.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_model.dart';
import '../models/notification_model.dart';
import 'messages_remote_data_source.dart';

class FirebaseMessagesRemoteDataSource implements MessagesRemoteDataSource {
  FirebaseMessagesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _appointmentsRef =>
      _firestore.collection('appointments');

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  @override
  Stream<List<AppointmentModel>> watchAppointmentsByTenant({
    required String tenantId,
  }) {
    return _appointmentsRef
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('appointmentDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<NotificationModel>> watchNotifications({
    required String receiverId,
  }) {
    return _notificationsRef
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(NotificationModel.fromFirestore).toList(),
        );
  }

  @override
  Future<void> markNotificationRead({required String notificationId}) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  @override
  Future<Map<String, dynamic>?> getAppointmentNavigationData({
    required String propertyId,
    required String appointmentId,
  }) async {
    final propertyDoc = await _firestore.collection('properties').doc(propertyId).get();
    final propertyData = propertyDoc.data();
    if (propertyData == null) return null;

    final property = PropertyModel.fromMap({
      ...propertyData,
      'propertyId': propertyData['propertyId'] ?? propertyDoc.id,
    });

    final roomsSnapshot = await _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('rooms')
        .get();

    final allRooms = roomsSnapshot.docs.map((doc) {
      final data = doc.data();
      return RoomModel.fromMap({
        ...data,
        'roomId': data['roomId'] ?? doc.id,
        'propertyId': data['propertyId'] ?? property.propertyId,
        'landlordId': data['landlordId'] ?? property.landlordId,
      });
    }).toList();

    AppointmentModel? initialAppointment;
    if (appointmentId.isNotEmpty) {
      final appDoc = await _appointmentsRef.doc(appointmentId).get();
      if (appDoc.exists && appDoc.data() != null) {
        initialAppointment = AppointmentModel.fromMap(appDoc.data()!);
      }
    }

    return {
      'property': property,
      'rooms': allRooms,
      if (initialAppointment != null) 'initialAppointment': initialAppointment,
    };
  }
}
