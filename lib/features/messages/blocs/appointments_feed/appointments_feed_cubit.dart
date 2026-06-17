import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/messages_repository.dart';
import '../../presentation/utils/appointment_list_filters.dart';
import 'appointments_feed_state.dart';

class AppointmentsFeedCubit extends Cubit<AppointmentsFeedState> {
  AppointmentsFeedCubit(this._repository) : super(const AppointmentsFeedState());

  final MessagesRepository _repository;
  StreamSubscription? _subscription;

  void watch(String tenantId) {
    final normalizedTenantId = tenantId.trim();
    if (normalizedTenantId.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          allItems: const [],
          displayedCount: 0,
          isLoadingMore: false,
          clearError: true,
        ),
      );
      return;
    }
    emit(state.copyWith(isLoading: true, isLoadingMore: false, clearError: true));
    _subscription?.cancel();
    _subscription = _repository
        .watchAppointmentsByTenant(tenantId: normalizedTenantId)
        .listen(
          (items) {
            final tabItems = appointmentsForTab(items, state.selectedTab);
            final displayedCount = AppointmentsFeedState.clampDisplayedCount(
              displayedCount: state.displayedCount,
              filteredLength: tabItems.length,
            );
            emit(
              state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                allItems: items,
                displayedCount: displayedCount,
                clearError: true,
              ),
            );
          },
          onError: (error) => emit(
            state.copyWith(
              isLoading: false,
              isLoadingMore: false,
              errorMessage: error.toString(),
            ),
          ),
        );
  }

  void selectTab(AppointmentFeedTab tab) {
    if (tab == state.selectedTab) {
      return;
    }
    final tabItems = appointmentsForTab(state.allItems, tab);
    emit(
      state.copyWith(
        selectedTab: tab,
        displayedCount: min(
          AppointmentsFeedState.pageSize,
          tabItems.length,
        ),
        isLoadingMore: false,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (isClosed) {
      return;
    }
    final nextCount = min(
      state.displayedCount + AppointmentsFeedState.pageSize,
      state.itemsForSelectedTab.length,
    );
    emit(
      state.copyWith(
        displayedCount: nextCount,
        isLoadingMore: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
