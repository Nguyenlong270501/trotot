import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../appointment/data/models/appointment_model.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_model.dart';
import '../../blocs/appointments_feed/appointments_feed_cubit.dart';
import '../../blocs/appointments_feed/appointments_feed_state.dart';

class AppointmentsPanel extends StatelessWidget {
  const AppointmentsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsFeedCubit, AppointmentsFeedState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          return Center(
            child: Text(
              state.errorMessage!,
              style: AppTypography.medium14(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: _AppointmentTabChips(state: state),
            ),
            Expanded(child: _AppointmentTabList(state: state)),
          ],
        );
      },
    );
  }
}

class _AppointmentTabChips extends StatelessWidget {
  const _AppointmentTabChips({required this.state});

  final AppointmentsFeedState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppointmentsFeedCubit>();
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _buildChip(
          context: context,
          label: 'Chờ xác nhận (${state.awaitingConfirmationCount})',
          tab: AppointmentFeedTab.pending,
          onSelected: cubit.selectTab,
        ),
        _buildChip(
          context: context,
          label: 'Sắp tới (${state.upcomingCount})',
          tab: AppointmentFeedTab.upcoming,
          onSelected: cubit.selectTab,
        ),
        _buildChip(
          context: context,
          label: 'Lịch sử',
          tab: AppointmentFeedTab.history,
          onSelected: cubit.selectTab,
        ),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required AppointmentFeedTab tab,
    required void Function(AppointmentFeedTab tab) onSelected,
  }) {
    final selected = state.selectedTab == tab;
    return ChoiceChip(
      label: Text(
        label,
        style: AppTypography.medium12(
          color: selected ? AppColors.surface : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceCard,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      onSelected: (_) => onSelected(tab),
    );
  }
}

class _AppointmentTabList extends StatelessWidget {
  const _AppointmentTabList({required this.state});

  final AppointmentsFeedState state;

  @override
  Widget build(BuildContext context) {
    if (state.itemsForSelectedTab.isEmpty) {
      return Center(
        child: Text(
          state.emptyMessage,
          style: AppTypography.medium14(color: AppColors.textPrimary),
        ),
      );
    }

    final itemCount =
        state.visibleItems.length + (state.showListFooter ? 1 : 0);

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= state.visibleItems.length) {
          return _ListFooter(state: state);
        }
        return _AppointmentCard(item: state.visibleItems[index]);
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final AppointmentsFeedState state;

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
          onPressed: () =>
              context.read<AppointmentsFeedCubit>().loadMore(),
          child: Text(
            'Xem thêm',
            style: AppTypography.medium14(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.item});

  final AppointmentModel item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAppointmentDetail(context, item),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.propertyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bold14(color: AppColors.textPrimary),
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            AppSizes.gapH6,
            Text(
              item.propertyAddress,
              style: AppTypography.medium12(color: AppColors.textSecondary),
            ),
            AppSizes.gapH6,
            Text(
              '${item.appointmentDate.hour.toString().padLeft(2, '0')}:${item.appointmentDate.minute.toString().padLeft(2, '0')} - ${item.appointmentDate.day}/${item.appointmentDate.month}/${item.appointmentDate.year}',
              style: AppTypography.bold14(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAppointmentDetail(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final propertyDoc = await FirebaseFirestore.instance
        .collection('properties')
        .doc(appointment.propertyId)
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
    final rooms = roomsSnapshot.docs.map((doc) {
      final data = doc.data();
      return RoomModel.fromMap({
        ...data,
        'roomId': data['roomId'] ?? doc.id,
        'propertyId': data['propertyId'] ?? property.propertyId,
        'landlordId': data['landlordId'] ?? property.landlordId,
      });
    }).toList();

    if (!context.mounted) {
      return;
    }
    context.push(
      RouteNames.appointmentPage,
      extra: {
        'property': property,
        'rooms': rooms,
        'initialAppointment': appointment,
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      AppointmentStatus.accepted => ('Đã xác nhận', AppColors.success),
      AppointmentStatus.pending => ('Chờ xác nhận', AppColors.warning),
      AppointmentStatus.rescheduled => ('Đã đổi lịch', AppColors.infoDark),
      AppointmentStatus.success => ('Đã xem', AppColors.accent),
      AppointmentStatus.cancelled => ('Đã hủy', AppColors.danger),
      AppointmentStatus.rejected => ('Từ chối', AppColors.dangerDark),
      _ => ('Không rõ', AppColors.textMuted),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTypography.bold10(color: color)),
    );
  }
}
