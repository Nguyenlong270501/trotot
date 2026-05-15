import '../../../appointment/data/models/appointment_model.dart';

/// Tab "Chờ xác nhận": gộp pending + rescheduled trong một danh sách.
const Set<String> awaitingConfirmationStatuses = {
  AppointmentStatus.pending,
  AppointmentStatus.rescheduled,
};

String normalizeAppointmentStatus(String status) => status.trim().toLowerCase();

bool isAwaitingConfirmationStatus(String status) =>
    awaitingConfirmationStatuses.contains(normalizeAppointmentStatus(status));

List<AppointmentModel> filterAwaitingConfirmationAppointments(
  List<AppointmentModel> items,
) {
  final filtered = items.where((item) => isAwaitingConfirmationStatus(item.status)).toList();
  filtered.sort((a, b) {
    final aRescheduled =
        normalizeAppointmentStatus(a.status) == AppointmentStatus.rescheduled;
    final bRescheduled =
        normalizeAppointmentStatus(b.status) == AppointmentStatus.rescheduled;
    if (aRescheduled != bRescheduled) {
      return aRescheduled ? -1 : 1;
    }
    return a.appointmentDate.compareTo(b.appointmentDate);
  });
  return filtered;
}

List<AppointmentModel> filterUpcomingAppointments(
  List<AppointmentModel> items, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final filtered = items
      .where(
        (item) =>
            normalizeAppointmentStatus(item.status) ==
                AppointmentStatus.accepted &&
            !item.appointmentDate.isBefore(reference),
      )
      .toList();
  filtered.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  return filtered;
}

List<AppointmentModel> filterHistoryAppointments(List<AppointmentModel> items) {
  const historyStatuses = {
    AppointmentStatus.cancelled,
    AppointmentStatus.success,
    AppointmentStatus.rejected,
  };
  final filtered = items
      .where(
        (item) => historyStatuses.contains(normalizeAppointmentStatus(item.status)),
      )
      .toList();
  filtered.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  return filtered;
}

List<AppointmentModel> appointmentsForTab(
  List<AppointmentModel> items,
  AppointmentFeedTab tab, {
  DateTime? now,
}) {
  return switch (tab) {
    AppointmentFeedTab.pending => filterAwaitingConfirmationAppointments(items),
    AppointmentFeedTab.upcoming => filterUpcomingAppointments(items, now: now),
    AppointmentFeedTab.history => filterHistoryAppointments(items),
  };
}

enum AppointmentFeedTab { pending, upcoming, history }
