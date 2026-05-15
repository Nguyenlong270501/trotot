import '../../../appointment/data/models/appointment_model.dart';
import '../datasources/messages_remote_data_source.dart';
import '../models/notification_model.dart';
import 'messages_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._remoteDataSource);

  final MessagesRemoteDataSource _remoteDataSource;

  @override
  Stream<List<AppointmentModel>> watchAppointmentsByTenant({
    required String tenantId,
  }) {
    return _remoteDataSource.watchAppointmentsByTenant(tenantId: tenantId);
  }

  @override
  Stream<List<NotificationModel>> watchNotifications({
    required String receiverId,
  }) {
    return _remoteDataSource.watchNotifications(receiverId: receiverId);
  }

  @override
  Future<void> markNotificationRead({required String notificationId}) {
    return _remoteDataSource.markNotificationRead(
      notificationId: notificationId,
    );
  }
}