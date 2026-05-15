import 'package:flutter/material.dart';
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
import 'widgets/property_header_image.dart';
import 'widgets/property_header_info.dart';
import 'widgets/property_map_section.dart';
import 'widgets/property_specs_prices.dart';
import 'widgets/room_preview_sheet.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({
    super.key,
    required this.property,
    required this.rooms,
  });

  final PropertyModel property;
  final List<RoomModel> rooms;

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

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationCubit>().state;
    final currentUser = authState is AuthenticationSuccessState
        ? authState.user
        : null;
    final topPadding = MediaQuery.viewPaddingOf(context).top;
    final currentUserId = currentUser?.userId.trim() ?? '';
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
      ],
      child: BlocBuilder<PropertyDetailsLiveCubit, PropertyDetailsLiveState>(
        buildWhen: (previous, current) {
          return previous.property != current.property ||
              previous.rooms != current.rooms ||
              previous.activeRoomId != current.activeRoomId ||
              previous.isFavorited != current.isFavorited ||
              previous.isFavoriteLoading != current.isFavoriteLoading ||
              previous.isCheckingAppointment != current.isCheckingAppointment ||
              previous.latestAppointment != current.latestAppointment ||
              previous.reviews != current.reviews ||
              previous.currentUserReview != current.currentUserReview;
        },
        builder: (context, liveState) {
          final liveRooms = liveState.rooms;
          final activeRoom = liveState.activeRoom;
          final headerImages =
              activeRoom?.imageUrls ??
              (liveRooms.isNotEmpty ? liveRooms.first.imageUrls : const <String>[]);

          return Scaffold(
            backgroundColor: AppColors.backgroundPrimary,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PropertyHeaderImage(
                    imageUrls: headerImages,
                    topPadding: topPadding,
                    isFavorited: liveState.isFavorited,
                    isFavoriteLoading: liveState.isFavoriteLoading,
                    onFavoriteTap: () async {
                      final cubit = context.read<PropertyDetailsLiveCubit>();
                      final isRemoving = liveState.isFavorited;
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
                    },
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Column(
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
                            property: liveState.property,
                            rooms: liveRooms,
                          ),
                        ),

                        AppSizes.gapH16,

                        if (liveRooms.isNotEmpty)
                          SectionCard(
                            emoji: '🚪',
                            title: 'Danh sách phòng trống (${liveRooms.length} phòng)',
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 350.h),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const ClampingScrollPhysics(),
                                itemCount: liveRooms.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 10.h),
                                itemBuilder: (context, index) {
                                  final room = liveRooms[index];
                                  return RoomMiniCard(
                                    name: room.roomName,
                                    priceLabel:
                                        '${PropertyHelper.formatPrice(room.price)} đ/tháng',
                                    onTap: () {
                                      context.read<PropertyDetailsLiveCubit>().selectRoom(room);
                                      showRoomPreviewSheet(context, room);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                        AppSizes.gapH16,

                        PropertySpecsPrices(
                          room: liveRooms,
                          property: liveState.property,
                        ),

                        AppSizes.gapH16,

                        SectionCard(
                          emoji: '✨',
                          title: 'Tiện ích chung',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PropertyAmenitiesSection(
                                facilities: liveState.property.facilities,
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
                              PropertyRulesSection(property: liveState.property),
                            ],
                          ),
                        ),
                        AppSizes.gapH16,

                        SectionCard(
                          title: 'Mô tả chung ',
                          emoji: '📝',
                          child: PropertyDescriptionSection(
                            description: liveState.property.description,
                          ),
                        ),

                        AppSizes.gapH16,
                        SectionCard(
                          title: 'Vị trí',
                          emoji: '📍',
                          child: PropertyMapSection(
                            location: LatLng(
                              liveState.property.location!.latitude,
                              liveState.property.location!.longitude,
                            ),
                            fullAddress: PropertyHelper.propertyLocationSubtitle(
                              liveState.property,
                            ),
                          ),
                        ),

                        AppSizes.gapH16,

                        SectionCard(
                          title: 'Thông tin chủ nhà',
                          child: LandlordInfoCard(
                            landlordSummary: liveState.property.landlordSummary,
                          ),
                        ),

                        AppSizes.gapH16,

                        if (currentUser != null)
                          PropertyReviewsSection(
                            property: liveState.property,
                            currentUserId: currentUser.userId,
                            currentUserName: currentUser.userName,
                            reviews: liveState.reviews,
                            currentUserReview: liveState.currentUserReview,
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
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: PropertyBottomActionBar(
              property: liveState.property,
              rooms: liveRooms,
              hasExistingAppointment: liveState.hasExistingAppointment,
              isCheckingAppointment: liveState.isCheckingAppointment,
              isOwnProperty: currentUserId.isNotEmpty &&
                  currentUserId == liveState.property.landlordId.trim(),
              initialAppointment: liveState.latestAppointment,
            ),
          );
        },
      ),
    );
  }
}
