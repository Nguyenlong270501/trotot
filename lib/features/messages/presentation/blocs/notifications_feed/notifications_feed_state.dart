import 'package:equatable/equatable.dart';

import '../../../data/models/notification_model.dart';

final class NotificationsFeedState extends Equatable {
  const NotificationsFeedState({
    this.isLoading = false,
    this.items = const <NotificationModel>[],
    this.errorMessage,
  });

  final bool isLoading;
  final List<NotificationModel> items;
  final String? errorMessage;

  NotificationsFeedState copyWith({
    bool? isLoading,
    List<NotificationModel>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsFeedState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, items, errorMessage];
}
