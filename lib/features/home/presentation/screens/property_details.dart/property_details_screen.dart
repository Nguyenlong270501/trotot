import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/utils/property_helper.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../auth/blocs/auth_blocs/auth_cubit.dart';
import '../../../../auth/blocs/auth_blocs/auth_state.dart';
import '../../../../auth/data/models/user.dart' show UserModel;
import '../../../../profile/presentation/screens/landlord_register/section_card.dart';
import '../../../../reviews/presentation/property_reviews_section.dart';
import '../../../blocs/property_details_live/property_details_live_cubit.dart';
import '../../../blocs/property_details_live/property_details_live_state.dart';
import '../../../data/models/property_model.dart';
import '../../../data/models/room_model.dart';
import '../../widgets/property_card/room_mini_card.dart';
import 'widgets/landlord_info_card.dart';
import 'widgets/property_amenities_rules.dart';
import 'widgets/property_bottom_action_bar.dart';
import 'widgets/property_description_section.dart';
import 'widgets/property_details_app_bar.dart';
import 'widgets/property_header_carousel.dart';
import 'widgets/property_header_info.dart';
import 'widgets/property_map_section.dart';
import 'widgets/property_specs_prices.dart';
import 'widgets/room_preview_sheet.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({
    super.key,
    required this.property,
    required this.rooms,
  });

  final PropertyModel property;
  final List<RoomModel> rooms;

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewsSectionKey = GlobalKey();
  final ValueNotifier<bool> _showSolidAppBar = ValueNotifier(false);
  final ValueNotifier<bool> _reviewsMounted = ValueNotifier(false);

  static const double _hysteresis = 12;
  static const double _reviewsPrefetchPx = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
      if (!mounted) {
        return;
      }
      final state = context.read<PropertyDetailsLiveCubit>().state;
      if (state.reviews.isNotEmpty ||
          state.property.totalReviews > 0 ||
          state.currentUserReview != null) {
        _reviewsMounted.value = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showSolidAppBar.dispose();
    _reviewsMounted.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateSolidAppBar();
    _maybeMountReviews();
  }

  void _updateSolidAppBar() {
    if (!_scrollController.hasClients) {
      return;
    }
    final offset = _scrollController.offset;
    final threshold = PropertyHeaderCarousel.extent - kToolbarHeight;

    if (!_showSolidAppBar.value && offset >= threshold + _hysteresis) {
      _showSolidAppBar.value = true;
    } else if (_showSolidAppBar.value && offset <= threshold - _hysteresis) {
      _showSolidAppBar.value = false;
    }
  }

  void _maybeMountReviews() {
    if (_reviewsMounted.value || !_scrollController.hasClients) {
      return;
    }
    final reviewsContext = _reviewsSectionKey.currentContext;
    if (reviewsContext == null) {
      return;
    }
    final box = reviewsContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final scrollable = Scrollable.maybeOf(reviewsContext);
    if (scrollable == null) {
      return;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) {
      return;
    }
    final revealOffset = viewport.getOffsetToReveal(box, 0).offset;
    if (revealOffset <=
        scrollable.position.viewportDimension + _reviewsPrefetchPx) {
      _reviewsMounted.value = true;
    }
  }

  Future<bool> _confirmFavoriteAction(
    BuildContext context, {
    required bool isRemoving,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isRemoving ? 'Bỏ yêu thích?' : 'Lưu yêu thích?'),
          content: Text(
            isRemoving
                ? 'Bạn có chắc muốn bỏ bài đăng này khỏi danh sách yêu thích không?'
                : 'Bạn có muốn lưu bài đăng này vào danh sách yêu thích không?',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: Text(isRemoving ? 'Bỏ' : 'Lưu'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _onFavoriteTap(BuildContext context) async {
    final cubit = context.read<PropertyDetailsLiveCubit>();
    final isRemoving = cubit.state.isFavorited;
    final confirmed = await _confirmFavoriteAction(
      context,
      isRemoving: isRemoving,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    if (isRemoving) {
      await cubit.removeFavorite();
    } else {
      await cubit.addFavorite();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationCubit>().state;
    final currentUser = authState is AuthenticationSuccessState
        ? authState.user
        : null;
    final currentUserId = currentUser?.userId.trim() ?? '';
    final mapLocation = widget.property.location;

    return MultiBlocListener(
      listeners: [
        BlocListener<PropertyDetailsLiveCubit, PropertyDetailsLiveState>(
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage ||
              prev.successMessage != curr.successMessage,
          listener: (context, state) {
            final error = state.errorMessage;
            if (error != null && error.isNotEmpty) {
              Alerts.of(context).showError(error);
              context.read<PropertyDetailsLiveCubit>().clearFeedback();
              return;
            }
            final success = state.successMessage;
            if (success != null && success.isNotEmpty) {
              Alerts.of(context).showSuccess(success);
              context.read<PropertyDetailsLiveCubit>().clearFeedback();
            }
          },
        ),
        BlocListener<PropertyDetailsLiveCubit, PropertyDetailsLiveState>(
          listenWhen: (prev, curr) =>
              prev.reviews != curr.reviews ||
              prev.currentUserReview != curr.currentUserReview ||
              prev.property.totalReviews != curr.property.totalReviews,
          listener: (_, state) {
            final hasReviews = state.reviews.isNotEmpty ||
                state.property.totalReviews > 0 ||
                state.currentUserReview != null;
            if (hasReviews && !_reviewsMounted.value) {
              _reviewsMounted.value = true;
            }
          },
        ),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundPrimary,
        body: Stack(
          fit: StackFit.expand,
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                const SliverToBoxAdapter(
                  child: PropertyHeaderCarousel(),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  sliver: SliverToBoxAdapter(
                    child: _PropertyDetailsHeaderBody(
                      mapLocation: mapLocation,
                      reviewsSectionKey: _reviewsSectionKey,
                      reviewsMounted: _reviewsMounted,
                      currentUser: currentUser,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PropertyDetailsAppBar(
                showSolidAppBar: _showSolidAppBar,
                onFavoriteTap: () => _onFavoriteTap(context),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<PropertyDetailsLiveCubit,
            PropertyDetailsLiveState>(
          buildWhen: (previous, current) =>
              previous.isCheckingAppointment != current.isCheckingAppointment ||
              previous.latestAppointment != current.latestAppointment ||
              previous.rooms != current.rooms ||
              previous.property.landlordId != current.property.landlordId,
          builder: (context, liveState) {
            final liveRooms = liveState.rooms;
            return PropertyBottomActionBar(
              property: liveState.property,
              rooms: liveRooms,
              hasExistingAppointment: liveState.hasExistingAppointment,
              isCheckingAppointment: liveState.isCheckingAppointment,
              isOwnProperty: currentUserId.isNotEmpty &&
                  currentUserId == liveState.property.landlordId.trim(),
              initialAppointment: liveState.latestAppointment,
            );
          },
        ),
      ),
    );
  }
}

class _PropertyDetailsHeaderBody extends StatelessWidget {
  const _PropertyDetailsHeaderBody({
    required this.mapLocation,
    required this.reviewsSectionKey,
    required this.reviewsMounted,
    required this.currentUser,
  });

  final GeoPoint? mapLocation;
  final GlobalKey reviewsSectionKey;
  final ValueNotifier<bool> reviewsMounted;
  final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyDetailsLiveCubit, PropertyDetailsLiveState>(
      buildWhen: (previous, current) =>
          previous.property != current.property ||
          previous.rooms != current.rooms ||
          previous.activeRoomId != current.activeRoomId,
      builder: (context, liveState) {
        final liveRooms = liveState.rooms;
        final property = liveState.property;
        final mapAddress = PropertyHelper.propertyLocationSubtitle(property);

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: PropertyHeaderInfo(
                property: property,
                rooms: liveRooms,
              ),
            ),
            AppSizes.gapH16,
            if (liveRooms.isNotEmpty) ...[
              SectionCard(
                emoji: '🚪',
                title:
                    'Danh sách phòng trống (${liveRooms.length} phòng)',
                child: Column(
                  children: [
                    for (var i = 0; i < liveRooms.length; i++) ...[
                      if (i > 0) SizedBox(height: 10.h),
                      RoomMiniCard(
                        name: liveRooms[i].roomName,
                        priceLabel:
                            '${PropertyHelper.formatPrice(liveRooms[i].price)} đ/tháng',
                        onTap: () {
                          context
                              .read<PropertyDetailsLiveCubit>()
                              .selectRoom(liveRooms[i]);
                          showRoomPreviewSheet(context, liveRooms[i]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              AppSizes.gapH16,
            ],
            PropertySpecsPrices(
              room: liveRooms,
              property: property,
            ),
            AppSizes.gapH16,
            SectionCard(
              emoji: '✨',
              title: 'Tiện ích chung',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PropertyAmenitiesSection(
                    facilities: property.facilities,
                  ),
                  AppSizes.gapH16,
                  Row(
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '📋',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      AppSizes.gapW8,
                      Text(
                        'Nội quy',
                        style: AppTypography.bold16(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.gapH16,
                  PropertyRulesSection(property: property),
                ],
              ),
            ),
            AppSizes.gapH16,
            SectionCard(
              title: 'Mô tả chung ',
              emoji: '📝',
              child: PropertyDescriptionSection(
                description: property.description,
              ),
            ),
            if (mapLocation != null) ...[
              AppSizes.gapH16,
              SectionCard(
                title: 'Vị trí',
                emoji: '📍',
                child: PropertyMapSection(
                  location: LatLng(
                    mapLocation!.latitude,
                    mapLocation!.longitude,
                  ),
                  fullAddress: mapAddress,
                ),
              ),
            ],
            AppSizes.gapH16,
            SectionCard(
              title: 'Thông tin chủ nhà',
              child: LandlordInfoCard(
                landlordSummary: property.landlordSummary,
              ),
            ),
            AppSizes.gapH16,
            KeyedSubtree(
              key: reviewsSectionKey,
              child: _ReviewsSlot(
                reviewsMounted: reviewsMounted,
                currentUser: currentUser,
              ),
            ),
            AppSizes.gapH24,
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: AppColors.border.withValues(alpha: 0.5),
            ),
            AppSizes.gapH8,
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 18.sp,
                  color: AppColors.textPrimary,
                ),
                label: Text(
                  'Báo cáo bài đăng',
                  style: AppTypography.medium14(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            AppSizes.gapH16,
          ],
        );
      },
    );
  }
}

class _ReviewsSlot extends StatelessWidget {
  const _ReviewsSlot({
    required this.reviewsMounted,
    required this.currentUser,
  });

  final ValueNotifier<bool> reviewsMounted;
  final UserModel? currentUser;

  static bool _hasReviewContent(PropertyDetailsLiveState state) {
    return state.reviews.isNotEmpty ||
        state.property.totalReviews > 0 ||
        state.currentUserReview != null;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final user = currentUser!;

    return BlocBuilder<PropertyDetailsLiveCubit, PropertyDetailsLiveState>(
      buildWhen: (previous, current) =>
          previous.reviews != current.reviews ||
          previous.currentUserReview != current.currentUserReview ||
          previous.property.totalReviews != current.property.totalReviews ||
          previous.property.ratingAverage != current.property.ratingAverage,
      builder: (context, liveState) {
        final hasContent = _hasReviewContent(liveState);

        return ValueListenableBuilder<bool>(
          valueListenable: reviewsMounted,
          builder: (context, scrolledToSection, _) {
            final showFullSection = scrolledToSection || hasContent;

            if (!showFullSection) {
              return SectionCard(
                emoji: '⭐',
                title: 'Đánh giá',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'Chưa có đánh giá nào.',
                    style: AppTypography.medium14(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }

            return PropertyReviewsSection(
              property: liveState.property,
              currentUserId: user.userId,
              currentUserName: user.userName,
              reviews: liveState.reviews,
              currentUserReview: liveState.currentUserReview,
            );
          },
        );
      },
    );
  }
}
