import 'dart:math';

import 'package:equatable/equatable.dart';

import '../../data/models/favorite_property_model.dart';

final class FavoritesFeedState extends Equatable {
  const FavoritesFeedState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.allFavorites = const <FavoritePropertyModel>[],
    this.filteredFavorites = const <FavoritePropertyModel>[],
    this.displayedCount = pageSize,
    this.searchQuery = '',
    this.errorMessage,
  });

  static const int pageSize = 20;

  final bool isLoading;
  final bool isLoadingMore;
  final List<FavoritePropertyModel> allFavorites;
  final List<FavoritePropertyModel> filteredFavorites;
  final int displayedCount;
  final String searchQuery;
  final String? errorMessage;

  List<FavoritePropertyModel> get items => allFavorites;

  List<FavoritePropertyModel> get visibleItems =>
      filteredFavorites.take(displayedCount).toList();

  /// Alias for [visibleItems] (backward compatibility).
  List<FavoritePropertyModel> get filteredItems => visibleItems;

  bool get hasMore => displayedCount < filteredFavorites.length;

  bool get showListFooter => hasMore || isLoadingMore;

  FavoritesFeedState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<FavoritePropertyModel>? allFavorites,
    List<FavoritePropertyModel>? filteredFavorites,
    int? displayedCount,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesFeedState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      allFavorites: allFavorites ?? this.allFavorites,
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      displayedCount: displayedCount ?? this.displayedCount,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static int clampDisplayedCount({
    required int displayedCount,
    required int filteredLength,
    bool resetToFirstPage = false,
  }) {
    if (filteredLength == 0) {
      return 0;
    }
    if (resetToFirstPage) {
      return min(pageSize, filteredLength);
    }
    return min(max(displayedCount, pageSize), filteredLength);
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    allFavorites,
    filteredFavorites,
    displayedCount,
    searchQuery,
    errorMessage,
  ];
}
