import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/property_helper.dart';
import '../../../home/data/models/property_model.dart';
import '../../data/models/favorite_property_model.dart';
import '../../data/repositories/favorite_repository.dart';
import 'favorites_feed_state.dart';

class FavoritesFeedCubit extends Cubit<FavoritesFeedState> {
  FavoritesFeedCubit(this._repository, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const FavoritesFeedState());

  final FavoriteRepository _repository;
  final FirebaseFirestore _firestore;
  StreamSubscription<List<FavoritePropertyModel>>? _favoritesSub;
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
  _propertySubs = {};
  final Map<String, PropertyModel> _liveProperties = {};
  List<FavoritePropertyModel> _allItems = const [];

  bool _resetDisplayedCountOnNextFavoritesEmit = false;

  Future<void> watch(String uid) async {
    await _favoritesSub?.cancel();
    final trimmedUid = uid.trim();
    if (trimmedUid.isEmpty) {
      await _cancelPropertySubscriptions();
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          allFavorites: const [],
          filteredFavorites: const [],
          displayedCount: 0,
          searchQuery: '',
          errorMessage: 'Vui lòng đăng nhập',
        ),
      );
      return;
    }

    _resetDisplayedCountOnNextFavoritesEmit = true;
    emit(state.copyWith(isLoading: true, isLoadingMore: false, clearError: true));
    _favoritesSub = _repository
        .watchFavorites(uid: trimmedUid)
        .listen(
          (items) {
            _allItems = _sortFavorites(items);
            _syncPropertySubscriptions(
              _allItems.map((item) => item.propertyId).toSet(),
            );

            final allFavorites = _composeDisplayItems();
            final filteredFavorites = _applyFilter(
              items: allFavorites,
              rawQuery: state.searchQuery,
            );
            final resetPage = _resetDisplayedCountOnNextFavoritesEmit;
            if (_resetDisplayedCountOnNextFavoritesEmit) {
              _resetDisplayedCountOnNextFavoritesEmit = false;
            }
            final displayedCount = FavoritesFeedState.clampDisplayedCount(
              displayedCount: state.displayedCount,
              filteredLength: filteredFavorites.length,
              resetToFirstPage: resetPage,
            );
            emit(
              state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                allFavorites: allFavorites,
                filteredFavorites: filteredFavorites,
                displayedCount: displayedCount,
                clearError: true,
              ),
            );
          },
          onError: (error) {
            emit(
              state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  void updateSearchQuery(String query) {
    final normalizedQuery = query.trim();
    final allFavorites = _composeDisplayItems();
    final filteredFavorites = _applyFilter(
      items: allFavorites,
      rawQuery: normalizedQuery,
    );
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        allFavorites: allFavorites,
        filteredFavorites: filteredFavorites,
        displayedCount: min(
          FavoritesFeedState.pageSize,
          filteredFavorites.length,
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
      state.displayedCount + FavoritesFeedState.pageSize,
      state.filteredFavorites.length,
    );
    emit(
      state.copyWith(
        displayedCount: nextCount,
        isLoadingMore: false,
      ),
    );
  }

  void _syncPropertySubscriptions(Set<String> targetIds) {
    final removedIds = _propertySubs.keys
        .where((id) => !targetIds.contains(id))
        .toList();
    for (final id in removedIds) {
      _propertySubs.remove(id)?.cancel();
      _liveProperties.remove(id);
    }

    for (final id in targetIds) {
      final normalizedId = id.trim();
      if (normalizedId.isEmpty || _propertySubs.containsKey(normalizedId)) {
        continue;
      }
      _propertySubs[normalizedId] = _firestore
          .collection('properties')
          .doc(normalizedId)
          .snapshots()
          .listen((snapshot) {
            if (!snapshot.exists || snapshot.data() == null) {
              _liveProperties.remove(normalizedId);
            } else {
              final map = Map<String, dynamic>.from(snapshot.data()!);
              map['propertyId'] = normalizedId;
              _liveProperties[normalizedId] = PropertyModel.fromMap(map);
            }
            _emitLiveMappedState();
          });
    }
  }

  List<FavoritePropertyModel> _sortFavorites(
    Iterable<FavoritePropertyModel> items,
  ) {
    return List<FavoritePropertyModel>.from(items)..sort((a, b) {
      final aDate = a.favoritedAt ?? a.createdAt;
      final bDate = b.favoritedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
  }

  List<FavoritePropertyModel> _composeDisplayItems() {
    return _allItems.map((item) {
      final property = _liveProperties[item.propertyId];
      if (property == null) {
        return item;
      }
      final previewFromProperty = List<String>.from(
        property.imageUrls ?? const [],
      );
      return FavoritePropertyModel(
        propertyId: item.propertyId,
        title: property.title,
        address: PropertyHelper.propertyLocationSubtitle(property),
        createdAt: property.createdAt,
        previewImageUrls: item.previewImageUrls.isNotEmpty
            ? item.previewImageUrls
            : previewFromProperty,
        favoritedAt: item.favoritedAt,
        previewRoomId: item.previewRoomId,
      );
    }).toList();
  }

  void _emitLiveMappedState() {
    final allFavorites = _composeDisplayItems();
    final filteredFavorites = _applyFilter(
      items: allFavorites,
      rawQuery: state.searchQuery,
    );
    final displayedCount = FavoritesFeedState.clampDisplayedCount(
      displayedCount: state.displayedCount,
      filteredLength: filteredFavorites.length,
    );
    emit(
      state.copyWith(
        isLoading: false,
        allFavorites: allFavorites,
        filteredFavorites: filteredFavorites,
        displayedCount: displayedCount,
        clearError: true,
      ),
    );
  }

  Future<void> _cancelPropertySubscriptions() async {
    for (final sub in _propertySubs.values) {
      await sub.cancel();
    }
    _propertySubs.clear();
    _liveProperties.clear();
  }

  List<FavoritePropertyModel> _applyFilter({
    required List<FavoritePropertyModel> items,
    required String rawQuery,
  }) {
    final normalizedQuery = _normalize(rawQuery);
    if (normalizedQuery.isEmpty) {
      return List<FavoritePropertyModel>.from(items);
    }
    return items.where((item) {
      final title = _normalize(item.title);
      final address = _normalize(item.address);
      return title.contains(normalizedQuery) ||
          address.contains(normalizedQuery);
    }).toList();
  }

  String _normalize(String value) {
    return removeDiacritics(value).toLowerCase().trim();
  }

  @override
  Future<void> close() async {
    await _favoritesSub?.cancel();
    await _cancelPropertySubscriptions();
    return super.close();
  }
}
