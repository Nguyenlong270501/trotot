import 'package:equatable/equatable.dart';
import '../../../appointment/data/models/appointment_model.dart';
import '../../../reviews/data/models/property_review_model.dart';
import '../../data/models/property_model.dart';
import '../../data/models/room_model.dart';

class PropertyDetailsLiveState extends Equatable {
  const PropertyDetailsLiveState({
    required this.property,
    required this.rooms,
    required this.activeRoomId,
    required this.isFavorited,
    required this.isFavoriteLoading,
    required this.isCheckingAppointment,
    required this.latestAppointment,
    required this.reviews,
    required this.currentUserReview,
    this.errorMessage,
    this.successMessage,
  });

  factory PropertyDetailsLiveState.initial({
    required PropertyModel property,
    required List<RoomModel> rooms,
    String? initialActiveRoomId,
  }) {
    final preferredId = initialActiveRoomId?.trim() ?? '';
    final activeRoomId = preferredId.isNotEmpty &&
            rooms.any((room) => room.roomId == preferredId)
        ? preferredId
        : (rooms.isNotEmpty ? rooms.first.roomId : '');
    return PropertyDetailsLiveState(
      property: property,
      rooms: rooms,
      activeRoomId: activeRoomId,
      isFavorited: false,
      isFavoriteLoading: false,
      isCheckingAppointment: true,
      latestAppointment: null,
      reviews: const [],
      currentUserReview: null,
    );
  }

  final PropertyModel property;
  final List<RoomModel> rooms;
  final String activeRoomId;
  final bool isFavorited;
  final bool isFavoriteLoading;
  final bool isCheckingAppointment;
  final AppointmentModel? latestAppointment;
  final List<PropertyReviewModel> reviews;
  final PropertyReviewModel? currentUserReview;
  final String? errorMessage;
  final String? successMessage;

  RoomModel? get activeRoom {
    for (final room in rooms) {
      if (room.roomId == activeRoomId) {
        return room;
      }
    }
    return rooms.isNotEmpty ? rooms.first : null;
  }

  bool get hasExistingAppointment => latestAppointment != null;

  PropertyDetailsLiveState copyWith({
    PropertyModel? property,
    List<RoomModel>? rooms,
    String? activeRoomId,
    bool? isFavorited,
    bool? isFavoriteLoading,
    bool? isCheckingAppointment,
    AppointmentModel? latestAppointment,
    bool clearLatestAppointment = false,
    List<PropertyReviewModel>? reviews,
    PropertyReviewModel? currentUserReview,
    bool clearCurrentUserReview = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return PropertyDetailsLiveState(
      property: property ?? this.property,
      rooms: rooms ?? this.rooms,
      activeRoomId: activeRoomId ?? this.activeRoomId,
      isFavorited: isFavorited ?? this.isFavorited,
      isFavoriteLoading: isFavoriteLoading ?? this.isFavoriteLoading,
      isCheckingAppointment:
          isCheckingAppointment ?? this.isCheckingAppointment,
      latestAppointment: clearLatestAppointment
          ? null
          : (latestAppointment ?? this.latestAppointment),
      reviews: reviews ?? this.reviews,
      currentUserReview: clearCurrentUserReview
          ? null
          : (currentUserReview ?? this.currentUserReview),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    property,
    rooms,
    activeRoomId,
    isFavorited,
    isFavoriteLoading,
    isCheckingAppointment,
    latestAppointment,
    reviews,
    currentUserReview,
    errorMessage,
    successMessage,
  ];
}
