const NOTIFY_STATUSES = new Set([
  'accepted',
  'rejected',
  'cancelled',
  'rescheduled',
  'success',
]);

/**
 * @param {FirebaseFirestore.Timestamp | Date | string | undefined} value
 * @returns {Date | null}
 */
function toDate(value) {
  if (!value) {
    return null;
  }
  if (typeof value.toDate === 'function') {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  if (typeof value === 'string') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

/**
 * @param {FirebaseFirestore.Timestamp | Date | string | undefined} value
 * @returns {string}
 */
function formatAppointmentDateTime(value) {
  const date = toDate(value);
  if (!date) {
    return '';
  }
  return date.toLocaleString('vi-VN', {
    timeZone: 'Asia/Ho_Chi_Minh',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });
}

/**
 * @param {Record<string, unknown>} data
 * @param {string} appointmentId
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildAppointmentNotification(data, appointmentId) {
  const status = (data.status || '').toString().trim();
  if (!NOTIFY_STATUSES.has(status)) {
    return null;
  }

  const propertyTitle = (data.propertyTitle || 'Bài đăng').toString().trim();
  const propertyId = (data.propertyId || '').toString().trim();
  const dateLabel = formatAppointmentDateTime(data.appointmentDate);
  const cancelReason = (data.cancelReason || '').toString().trim();

  let title = 'Cập nhật lịch hẹn';
  let content = propertyTitle;

  switch (status) {
  case 'accepted':
    title = 'Đã xác nhận lịch hẹn';
    content = dateLabel ?
      `${propertyTitle} — ${dateLabel}` :
      propertyTitle;
    break;
  case 'rejected':
    title = 'Lịch hẹn bị từ chối';
    content = cancelReason ?
      `${propertyTitle}. Lý do: ${cancelReason}` :
      propertyTitle;
    break;
  case 'cancelled':
    title = 'Lịch hẹn đã hủy';
    content = cancelReason ?
      `${propertyTitle}. Lý do: ${cancelReason}` :
      propertyTitle;
    break;
  case 'rescheduled':
    title = 'Lịch đã được đổi';
    content = dateLabel ?
      `${propertyTitle} — ${dateLabel}` :
      propertyTitle;
    break;
  case 'success':
    title = 'Lịch hẹn hoàn thành';
    content = dateLabel ?
      `${propertyTitle} — ${dateLabel}` :
      propertyTitle;
    break;
  default:
    break;
  }

  return {
    title,
    content,
    pushData: {
      type: 'appointment',
      relatedType: 'appointment',
      relatedId: appointmentId.toString(),
      appointmentId: appointmentId.toString(),
      status,
      propertyId,
    },
  };
}

/**
 * Thông báo cho chủ trọ khi người thuê vừa tạo lịch hẹn (status pending).
 *
 * @param {Record<string, unknown>} data
 * @param {string} appointmentId
 * @returns {{ title: string, content: string, pushData: Record<string, string> } | null}
 */
function buildLandlordNewAppointmentNotification(data, appointmentId) {
  const status = (data.status || '').toString().trim();
  if (status !== 'pending') {
    return null;
  }

  const propertyTitle = (data.propertyTitle || 'Bài đăng').toString().trim();
  const propertyId = (data.propertyId || '').toString().trim();
  const tenantName = (data.tenantName || 'Người thuê').toString().trim();
  const purpose = (data.purpose || '').toString().trim();
  const dateLabel = formatAppointmentDateTime(data.appointmentDate);

  let content = tenantName;
  if (propertyTitle) {
    content += ` — ${propertyTitle}`;
  }
  if (dateLabel) {
    content += ` (${dateLabel})`;
  }
  if (purpose) {
    content += `. Mục đích: ${purpose}`;
  }

  return {
    title: 'Lịch hẹn xem phòng mới',
    content,
    pushData: {
      type: 'appointment',
      relatedType: 'appointment',
      relatedId: appointmentId.toString(),
      audience: 'landlord',
      appointmentId: appointmentId.toString(),
      status,
      propertyId,
    },
  };
}

module.exports = {
  buildAppointmentNotification,
  buildLandlordNewAppointmentNotification,
  NOTIFY_STATUSES,
};
