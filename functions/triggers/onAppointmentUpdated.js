const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const {buildAppointmentNotification, NOTIFY_STATUSES} =
  require('../notifications/appointmentMessages');
const {notifyUser} = require('../notifications/notifyUser');

module.exports = onDocumentUpdated(
  {
    document: 'appointments/{appointmentId}',
    region: 'asia-southeast1',
  },
  async (event) => {
    const appointmentId = event.params.appointmentId;
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;

    if (!beforeSnap?.exists || !afterSnap?.exists) {
      return;
    }

    const before = beforeSnap.data() || {};
    const after = afterSnap.data() || {};
    const beforeStatus = (before.status || '').toString().trim();
    const afterStatus = (after.status || '').toString().trim();

    if (beforeStatus === afterStatus) {
      return;
    }
    if (afterStatus === 'pending' || !NOTIFY_STATUSES.has(afterStatus)) {
      return;
    }

    const tenantId = (after.tenantId || '').toString().trim();
    if (!tenantId) {
      logger.warn('onAppointmentUpdated: missing tenantId', {appointmentId});
      return;
    }

    const payload = buildAppointmentNotification(after, appointmentId);
    if (!payload) {
      return;
    }

    const notificationId = await notifyUser({
      receiverId: tenantId,
      title: payload.title,
      content: payload.content,
      type: 'appointment',
      relatedType: 'appointment',
      relatedId: appointmentId,
      pushData: payload.pushData,
    });

    if (notificationId) {
      logger.info('onAppointmentUpdated: notification sent', {
        appointmentId,
        tenantId,
        status: afterStatus,
        notificationId,
      });
    }
  },
);
