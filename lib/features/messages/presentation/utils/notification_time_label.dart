String formatNotificationTimeLabel(DateTime createdAt) {
  if (createdAt.millisecondsSinceEpoch == 0) {
    return '—';
  }

  final diff = DateTime.now().difference(createdAt);
  if (diff.inMinutes < 1) {
    return 'Vừa xong';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes} phút trước';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours} giờ trước';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} ngày trước';
  }

  final day = createdAt.day.toString().padLeft(2, '0');
  final month = createdAt.month.toString().padLeft(2, '0');
  return '$day/$month/${createdAt.year}';
}
