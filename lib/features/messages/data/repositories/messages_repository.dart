import '../../../appointment/data/models/appointment_model.dart';
import '../models/notification_model.dart';

abstract class MessagesRepository {
  Stream<List<AppointmentModel>> watchAppointmentsByTenant({
    required String tenantId,
  });

  Stream<List<NotificationModel>> watchNotifications({
    required String receiverId,
  });

  Future<void> markNotificationRead({required String notificationId});
}