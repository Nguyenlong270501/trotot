import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/data/models/favorite_property_model.dart';
import '../../../favorites/data/repositories/favorite_repository.dart';
import '../../data/models/property_details_live_update.dart';
import '../../data/models/property_model.dart';
import '../../data/models/room_model.dart';
import '../../data/repositories/property_details_live_repository.dart';
import 'property_details_live_state.dart';

class PropertyDetailsLiveCubit extends Cubit<PropertyDetailsLiveState> {
  PropertyDetailsLiveCubit({
    required PropertyDetailsLiveRepository liveRepository,
    required FavoriteRepository favoriteRepository,
    required String? currentUserId,
    required PropertyModel initialProperty,
    required List<RoomModel> initialRooms,
    String? initialActiveRoomId,
  }) : _liveRepository = liveRepository,
       _favoriteRepository = favoriteRepository,
       _currentUserId = currentUserId?.trim(),
       super(
         PropertyDetailsLiveState.initial(
           property: initialProperty,
           rooms: initialRooms,
           initialActiveRoomId: initialActiveRoomId,
         ),
       );

  final PropertyDetailsLiveRepository _liveRepository;
  final FavoriteRepository _favoriteRepository;
  final String? _currentUserId;

  StreamSubscription<PropertyDetailsLiveUpdate>? _liveSub;

  static const int _maxFavorites = 50;

  void start() {
    _liveSub?.cancel();
    _liveSub = _liveRepository
        .watch(
          propertyId: state.property.propertyId,
          userId: _currentUserId,
        )
        .listen(
          _onLiveUpdate,
          onError: (_) {
            emit(
              state.copyWith(
                errorMessage: 'Không thể đồng bộ realtime bài đăng.',
                clearSuccess: true,
              ),
            );
          },
        );
  }

  void _onLiveUpdate(PropertyDetailsLiveUpdate update) {
    if (isClosed) {
      return;
    }
    if (update.propertyMissing) {
      emit(
        state.copyWith(
          errorMessage: 'Bài đăng không còn tồn tại.',
          clearSuccess: true,
        ),
      );
      return;
    }
    final property = update.property;
    if (property == null) {
      return;
    }

    final rooms = List<RoomModel>.from(update.rooms)
      ..sort((a, b) => compareNatural(a.roomName, b.roomName));

    final currentActive = state.activeRoomId;
    final hasCurrent = rooms.any((room) => room.roomId == currentActive);
    final nextActive = hasCurrent
        ? currentActive
        : (rooms.isNotEmpty ? rooms.first.roomId : '');

    emit(
      state.copyWith(
        property: property,
        rooms: rooms,
        activeRoomId: nextActive,
        isFavorited: update.isFavorited,
        isCheckingAppointment: update.isCheckingAppointment,
        latestAppointment: update.latestAppointment,
        reviews: update.reviews,
        currentUserReview: update.currentUserReview,
        clearError: true,
      ),
    );
  }

  void selectRoom(RoomModel room) {
    emit(
      state.copyWith(
        activeRoomId: room.roomId,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> addFavorite() async {
    final uid = _currentUserId;
    if (uid == null || uid.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Vui lòng đăng nhập để lưu yêu thích',
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isFavoriteLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final countResult = await _favoriteRepository.getFavoritesCount(uid: uid);
    final blocked = countResult.fold((failure) {
      emit(
        state.copyWith(
          isFavoriteLoading: false,
          errorMessage: failure.errorMessage?.toString(),
          clearSuccess: true,
        ),
      );
      return true;
    }, (favoritesCount) {
      if (favoritesCount >= _maxFavorites) {
        emit(
          state.copyWith(
            isFavoriteLoading: false,
            errorMessage:
                'Bạn chỉ có thể lưu tối đa $_maxFavorites bài yêu thích',
            clearSuccess: true,
          ),
        );
        return true;
      }
      return false;
    });
    if (blocked) {
      return;
    }

    final favorite = FavoritePropertyModel.fromProperty(
      state.property,
      previewRoom: state.activeRoom,
    );
    final result = await _favoriteRepository.saveFavorite(
      uid: uid,
      favorite: favorite,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isFavoriteLoading: false,
          errorMessage: failure.errorMessage?.toString(),
          clearSuccess: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isFavoriteLoading: false,
          successMessage: 'Đã lưu vào yêu thích',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> removeFavorite() async {
    final uid = _currentUserId;
    if (uid == null || uid.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Vui lòng đăng nhập để sử dụng',
          clearSuccess: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isFavoriteLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    final result = await _favoriteRepository.removeFavorite(
      uid: uid,
      propertyId: state.property.propertyId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isFavoriteLoading: false,
          errorMessage: failure.errorMessage?.toString(),
          clearSuccess: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isFavoriteLoading: false,
          successMessage: 'Đã bỏ khỏi yêu thích',
          clearError: true,
        ),
      ),
    );
  }

  void clearFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  @override
  Future<void> close() async {
    await _liveSub?.cancel();
    return super.close();
  }
}
