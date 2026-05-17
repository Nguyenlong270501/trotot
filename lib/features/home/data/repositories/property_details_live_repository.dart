import 'dart:async';

import '../../../appointment/data/models/appointment_model.dart';
import '../../../appointment/data/repositories/appointment_repository.dart';
import '../../../favorites/data/repositories/favorite_repository.dart';
import '../../../reviews/data/models/property_review_model.dart';
import '../../../reviews/data/repositories/reviews_repository.dart';
import '../datasources/firebase_home_remote_datasources/home_remote_data_source.dart';
import '../models/property_details_live_update.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';

/// Single outbound realtime stream for the property details screen.
class PropertyDetailsLiveRepository {
  PropertyDetailsLiveRepository({
    required HomeRemoteDataSource homeRemote,
    required FavoriteRepository favoriteRepository,
    required ReviewsRepository reviewsRepository,
    required AppointmentRepository appointmentRepository,
  }) : _homeRemote = homeRemote,
       _favoriteRepository = favoriteRepository,
       _reviewsRepository = reviewsRepository,
       _appointmentRepository = appointmentRepository;

  final HomeRemoteDataSource _homeRemote;
  final FavoriteRepository _favoriteRepository;
  final ReviewsRepository _reviewsRepository;
  final AppointmentRepository _appointmentRepository;

  static const int _reviewsLimit = 20;

  Stream<PropertyDetailsLiveUpdate> watch({
    required String propertyId,
    String? userId,
  }) {
    final controller = StreamController<PropertyDetailsLiveUpdate>();
    final trimmedUid = userId?.trim() ?? '';

    PropertyModel? property;
    List<RoomModel> rooms = const [];
    var propertyMissing = false;
    var isFavorited = false;
    var isCheckingAppointment = trimmedUid.isEmpty ? false : true;
    AppointmentModel? latestAppointment;
    List<PropertyReviewModel> reviews = const [];
    PropertyReviewModel? currentUserReview;

    void publish() {
      controller.add(
        PropertyDetailsLiveUpdate(
          property: property,
          rooms: rooms,
          propertyMissing: propertyMissing,
          isFavorited: isFavorited,
          isCheckingAppointment: isCheckingAppointment,
          latestAppointment: latestAppointment,
          reviews: reviews,
          currentUserReview: currentUserReview,
        ),
      );
    }

    final subscriptions = <StreamSubscription<dynamic>>[];
    var secondaryStarted = false;

    void startSecondarySubscriptions() {
      if (secondaryStarted || trimmedUid.isEmpty) {
        return;
      }
      secondaryStarted = true;

      subscriptions.add(
        _favoriteRepository
            .watchIsFavorited(uid: trimmedUid, propertyId: propertyId)
            .listen(
              (value) {
                isFavorited = value;
                publish();
              },
              onError: controller.addError,
            ),
      );

      subscriptions.add(
        _reviewsRepository
            .watchReviews(propertyId: propertyId, limit: _reviewsLimit)
            .listen(
              (value) {
                reviews = value;
                publish();
              },
              onError: controller.addError,
            ),
      );

      subscriptions.add(
        _reviewsRepository
            .watchCurrentUserReview(propertyId: propertyId, userId: trimmedUid)
            .listen(
              (value) {
                currentUserReview = value;
                publish();
              },
              onError: controller.addError,
            ),
      );

      subscriptions.add(
        _appointmentRepository
            .watchLatestAppointmentForProperty(
              tenantId: trimmedUid,
              propertyId: propertyId,
            )
            .listen(
              (value) {
                isCheckingAppointment = false;
                latestAppointment = value;
                publish();
              },
              onError: (_) {
                isCheckingAppointment = false;
                latestAppointment = null;
                publish();
              },
            ),
      );
    }

    subscriptions.add(
      _homeRemote.watchPropertyDetailsBundle(propertyId: propertyId).listen(
        (bundle) {
          propertyMissing = !bundle.exists;
          property = bundle.property;
          rooms = bundle.rooms;
          publish();
          startSecondarySubscriptions();
        },
        onError: controller.addError,
      ),
    );

    if (trimmedUid.isEmpty) {
      isCheckingAppointment = false;
    }

    controller.onCancel = () async {
      for (final sub in subscriptions) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }
}
