import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../auth/blocs/auth_blocs/auth_cubit.dart';
import '../../../auth/blocs/auth_blocs/auth_state.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_model.dart';
import '../../data/models/favorite_property_model.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../blocs/favorites_feed/favorites_feed_cubit.dart';
import '../../blocs/favorites_feed/favorites_feed_state.dart';
import '../widgets/favorite_card.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSheet,
                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                ),
                child: Text(
                  'Bài đăng yêu thích',
                  style: AppTypography.bold22(color: AppColors.accent),
                ),
              ),
            ),
          ),
          body: _buildBody(context, authState),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AuthenticationState authState) {
    if (authState is! AuthenticationSuccessState) {
      final message = switch (authState) {
        AuthenticationErrorState(:final error) => error,
        AuthenticationLoadingState() => 'Đang đăng nhập...',
        _ => 'Vui lòng đăng nhập để xem bài yêu thích.',
      };
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            message,
            style: AppTypography.medium14(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final userId = authState.user.userId;
    return BlocProvider(
      key: ValueKey(userId),
      create: (context) =>
          FavoritesFeedCubit(context.read<FavoriteRepository>())..watch(userId),
      child: const _FavoritesTabBody(),
    );
  }
}

class _FavoritesTabBody extends StatelessWidget {
  const _FavoritesTabBody();

  Future<void> _openPropertyDetail(
    BuildContext context,
    FavoritePropertyModel item,
  ) async {
    final propertyId = item.propertyId.trim();
    if (propertyId.isEmpty) {
      return;
    }

    final propertyDoc = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .get();
    final propertyData = propertyDoc.data();
    if (!context.mounted || propertyData == null) {
      return;
    }

    final property = PropertyModel.fromMap({
      ...propertyData,
      'propertyId': propertyData['propertyId'] ?? propertyDoc.id,
    });
    final roomsSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .doc(property.propertyId)
        .collection('rooms')
        .get();

    final allRooms = roomsSnapshot.docs
        .map((doc) {
          final data = doc.data();
          return RoomModel.fromMap({
            ...data,
            'roomId': data['roomId'] ?? doc.id,
            'propertyId': data['propertyId'] ?? property.propertyId,
            'landlordId': data['landlordId'] ?? property.landlordId,
          });
        })
        .toList();

    final previewRoomId = item.previewRoomId?.trim() ?? '';
    final availableRooms =
        allRooms.where((room) => room.isAvailable).toList();
    final rooms = <RoomModel>[
      for (final room in availableRooms) room,
      if (previewRoomId.isNotEmpty &&
          !availableRooms.any((room) => room.roomId == previewRoomId))
        ...allRooms.where((room) => room.roomId == previewRoomId),
    ];

    if (!context.mounted) {
      return;
    }
    context.push(
      RouteNames.propertyDetailsPage,
      extra: {
        'property': property,
        'rooms': rooms.isNotEmpty ? rooms : allRooms,
        if (previewRoomId.isNotEmpty) 'initialActiveRoomId': previewRoomId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSizes.gapH12,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            onChanged: context.read<FavoritesFeedCubit>().updateSearchQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên hoặc địa chỉ',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
                size: 20.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        AppSizes.gapH12,
        Expanded(
          child: BlocBuilder<FavoritesFeedCubit, FavoritesFeedState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                return Center(
                  child: Text(
                    state.errorMessage!,
                    style: AppTypography.medium14(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (state.items.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có bài đăng yêu thích',
                    style: AppTypography.medium14(color: AppColors.textPrimary),
                  ),
                );
              }
              if (state.filteredFavorites.isEmpty) {
                return Center(
                  child: Text(
                    'Không tìm thấy kết quả phù hợp',
                    style: AppTypography.medium14(color: AppColors.textPrimary),
                  ),
                );
              }

              final itemCount =
                  state.visibleItems.length + (state.showListFooter ? 1 : 0);

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index >= state.visibleItems.length) {
                    return _FavoritesListFooter(state: state);
                  }
                  final item = state.visibleItems[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: FavoriteCard(
                      item: item,
                      onTap: () => _openPropertyDetail(context, item),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FavoritesListFooter extends StatelessWidget {
  const _FavoritesListFooter({required this.state});

  final FavoritesFeedState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      child: Center(
        child: TextButton(
          onPressed: () => context.read<FavoritesFeedCubit>().loadMore(),
          child: Text(
            'Xem thêm',
            style: AppTypography.medium14(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
