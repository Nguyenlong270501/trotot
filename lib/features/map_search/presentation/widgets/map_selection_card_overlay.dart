import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../home/data/models/property_model.dart';
import '../blocs/map_search/map_search_cubit.dart';
import '../blocs/map_search/map_search_state.dart';
import 'property_map_card.dart';

class MapSelectionCardOverlay extends StatelessWidget {
  const MapSelectionCardOverlay({
    super.key,
    required this.state,
    required this.onOpenDetails,
  });

  final MapSearchState state;
  final void Function(PropertyModel property) onOpenDetails;

  static const double cardWidth = 320;
  static const double cardHeight = 220;

  @override
  Widget build(BuildContext context) {
    if (state.selectedPropertyId == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 20.h,
      child: Center(
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(18.r),
          child: _MapSelectionCardBody(
            state: state,
            onOpenDetails: onOpenDetails,
          ),
        ),
      ),
    );
  }
}

class _MapSelectionCardBody extends StatelessWidget {
  const _MapSelectionCardBody({
    required this.state,
    required this.onOpenDetails,
  });

  final MapSearchState state;
  final void Function(PropertyModel property) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingSelectedProperty) {
      return const _MapCardSkeleton();
    }

    if (state.selectedProperty == null) {
      return _MapCardError(
        message: state.selectedPropertyError ?? 'Không thể tải dữ liệu phòng',
      );
    }

    final property = state.selectedProperty!;
    return PropertyMapCard(
      property: property,
      onClose: context.read<MapSearchCubit>().clearSelection,
      onTap: () => onOpenDetails(property),
    );
  }
}

class _MapCardError extends StatelessWidget {
  const _MapCardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MapSelectionCardOverlay.cardWidth.w,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 28.sp,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.medium14(color: AppColors.textPrimary),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: context.read<MapSearchCubit>().clearSelection,
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class _MapCardSkeleton extends StatelessWidget {
  const _MapCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MapSelectionCardOverlay.cardWidth.w,
      height: MapSelectionCardOverlay.cardHeight.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18.r),
      ),
    );
  }
}
