import '../../../appointment/data/models/appointment_model.dart';
import '../../../reviews/data/models/property_review_model.dart';
import 'property_model.dart';
import 'room_model.dart';

/// Merged realtime payload for the property details screen.
class PropertyDetailsLiveUpdate {
  const PropertyDetailsLiveUpdate({
    required this.property,
    required this.rooms,
    this.isFavorited = false,
    this.isFavoriteLoading = false,
    this.isCheckingAppointment = false,
    this.latestAppointment,
    this.reviews = const [],
    this.currentUserReview,
    this.propertyMissing = false,
  });

  final PropertyModel? property;
  final List<RoomModel> rooms;
  final bool isFavorited;
  final bool isFavoriteLoading;
  final bool isCheckingAppointment;
  final AppointmentModel? latestAppointment;
  final List<PropertyReviewModel> reviews;
  final PropertyReviewModel? currentUserReview;
  final bool propertyMissing;
}
