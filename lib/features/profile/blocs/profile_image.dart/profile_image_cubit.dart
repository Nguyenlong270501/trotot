import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/profile_image_repository.dart';
import 'profile_image_state.dart';

class ProfileImageCubit extends Cubit<ProfileImageState> {
  ProfileImageCubit(this._repository, {String initialAvatarUrl = ''})
    : super(
        ProfileImageState(
          initialAvatarUrl: initialAvatarUrl.trim(),
          avatarUrl: initialAvatarUrl.trim(),
        ),
      );

  final ProfileImageRepository _repository;

  Future<void> pickAvatar() async {
    try {
      emit(
        state.copyWith(
          status: ProfileImageStatus.picking,
          clearError: true,
        ),
      );
      final picked = await _repository.pickImageFromGallery();
      if (picked == null) {
        emit(state.copyWith(status: ProfileImageStatus.idle));
        return;
      }

      final cachedPath = await _repository.cachePickedAvatar(picked);
      emit(
        state.copyWith(
          status: ProfileImageStatus.idle,
          localPreviewPath: cachedPath,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileImageStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> uploadPendingAvatar() async {
    if (!state.hasPendingImage) {
      return true;
    }

    try {
      emit(
        state.copyWith(
          status: ProfileImageStatus.saving,
          clearError: true,
        ),
      );
      final newAvatarUrl = await _repository.uploadAvatarFromLocalPath(
        state.localPreviewPath!,
        previousAvatarUrl: state.committedAvatarUrl,
      );
      emit(
        state.copyWith(
          status: ProfileImageStatus.idle,
          avatarUrl: newAvatarUrl,
          clearLocalPreviewPath: true,
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileImageStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  void clearError() {
    emit(state.copyWith(status: ProfileImageStatus.idle, clearError: true));
  }
}
