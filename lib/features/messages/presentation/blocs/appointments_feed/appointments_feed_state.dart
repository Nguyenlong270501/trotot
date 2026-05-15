import 'dart:math';

import 'package:equatable/equatable.dart';

import '../../../../appointment/data/models/appointment_model.dart';
import '../../utils/appointment_list_filters.dart';

export '../../utils/appointment_list_filters.dart' show AppointmentFeedTab;

final class AppointmentsFeedState extends Equatable {
  const AppointmentsFeedState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.allItems = const <AppointmentModel>[],
    this.selectedTab = AppointmentFeedTab.pending,
    this.displayedCount = pageSize,
    this.errorMessage,
  });

  static const int pageSize = 20;

  final bool isLoading;
  final bool isLoadingMore;
  final List<AppointmentModel> allItems;
  final AppointmentFeedTab selectedTab;
  final int displayedCount;
  final String? errorMessage;

  /// pending + rescheduled (tab Chờ xác nhận).
  List<AppointmentModel> get awaitingConfirmationItems =>
      filterAwaitingConfirmationAppointments(allItems);

  List<AppointmentModel> get pendingItems => awaitingConfirmationItems;

  List<AppointmentModel> get upcomingItems =>
      filterUpcomingAppointments(allItems);

  List<AppointmentModel> get historyItems => filterHistoryAppointments(allItems);

  List<AppointmentModel> get itemsForSelectedTab =>
      appointmentsForTab(allItems, selectedTab);

  List<AppointmentModel> get visibleItems =>
      itemsForSelectedTab.take(displayedCount).toList();

  int get awaitingConfirmationCount => awaitingConfirmationItems.length;

  int get pendingCount => awaitingConfirmationCount;

  int get upcomingCount => upcomingItems.length;

  int get historyCount => historyItems.length;

  bool get hasMore => displayedCount < itemsForSelectedTab.length;

  bool get showListFooter => hasMore || isLoadingMore;

  String get emptyMessage => switch (selectedTab) {
    AppointmentFeedTab.pending => 'Chưa có lịch chờ xác nhận',
    AppointmentFeedTab.upcoming => 'Chưa có lịch sắp tới',
    AppointmentFeedTab.history => 'Chưa có lịch sử',
  };

  AppointmentsFeedState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<AppointmentModel>? allItems,
    AppointmentFeedTab? selectedTab,
    int? displayedCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppointmentsFeedState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      allItems: allItems ?? this.allItems,
      selectedTab: selectedTab ?? this.selectedTab,
      displayedCount: displayedCount ?? this.displayedCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static int clampDisplayedCount({
    required int displayedCount,
    required int filteredLength,
  }) {
    if (filteredLength == 0) {
      return 0;
    }
    return min(max(displayedCount, pageSize), filteredLength);
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    allItems,
    selectedTab,
    displayedCount,
    errorMessage,
  ];
}
