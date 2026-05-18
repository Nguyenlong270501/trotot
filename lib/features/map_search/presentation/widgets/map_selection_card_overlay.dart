import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/property_model.dart';
import '../blocs/map_search/map_search_cubit.dart';
import '../blocs/map_search/map_search_state.dart';
import 'property_map_card.dart';

/// Property card pinned to the bottom while a map marker is selected.
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
    if (state.isLoadingSelectedProperty || state.selectedProperty == null) {
      return const _MapCardSkeleton();
    }

    final property = state.selectedProperty!;
    return PropertyMapCard(
      property: property,
      onClose: context.read<MapSearchCubit>().clearSelection,
      onTap: () => onOpenDetails(property),
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
