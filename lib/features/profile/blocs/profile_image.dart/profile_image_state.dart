import 'package:equatable/equatable.dart';

enum ProfileImageStatus { idle, picking, saving, error }

class ProfileImageState extends Equatable {
  const ProfileImageState({
    this.status = ProfileImageStatus.idle,
    this.initialAvatarUrl = '',
    this.avatarUrl = '',
    this.localPreviewPath,
    this.errorMessage,
  });

  final ProfileImageStatus status;
  final String initialAvatarUrl;
  final String avatarUrl;
  final String? localPreviewPath;
  final String? errorMessage;

  bool get hasPendingImage => (localPreviewPath ?? '').trim().isNotEmpty;

  String get committedAvatarUrl {
    if (avatarUrl.trim().isNotEmpty) {
      return avatarUrl.trim();
    }
    return initialAvatarUrl.trim();
  }

  ProfileImageState copyWith({
    ProfileImageStatus? status,
    String? initialAvatarUrl,
    String? avatarUrl,
    String? localPreviewPath,
    String? errorMessage,
    bool clearLocalPreviewPath = false,
    bool clearError = false,
  }) {
    return ProfileImageState(
      status: status ?? this.status,
      initialAvatarUrl: initialAvatarUrl ?? this.initialAvatarUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localPreviewPath: clearLocalPreviewPath
          ? null
          : (localPreviewPath ?? this.localPreviewPath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    initialAvatarUrl,
    avatarUrl,
    localPreviewPath,
    errorMessage,
  ];
}
