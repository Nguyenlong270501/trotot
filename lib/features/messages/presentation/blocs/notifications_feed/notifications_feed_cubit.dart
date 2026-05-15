import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/messages_repository.dart';
import 'notifications_feed_state.dart';

class NotificationsFeedCubit extends Cubit<NotificationsFeedState> {
  NotificationsFeedCubit(this._repository)
    : super(const NotificationsFeedState());

  final MessagesRepository _repository;
  StreamSubscription? _subscription;

  void watch(String receiverId) {
    final normalizedReceiverId = receiverId.trim();
    if (normalizedReceiverId.isEmpty) {
      emit(state.copyWith(isLoading: false, items: const [], clearError: true));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription?.cancel();
    _subscription = _repository
        .watchNotifications(receiverId: normalizedReceiverId)
        .listen(
          (items) => emit(
            state.copyWith(isLoading: false, items: items, clearError: true),
          ),
          onError: (error) => emit(
            state.copyWith(
              isLoading: false,
              errorMessage: error.toString(),
            ),
          ),
        );
  }

  Future<void> markRead(String notificationId) async {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) {
      return;
    }
    await _repository.markNotificationRead(notificationId: trimmedId);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
