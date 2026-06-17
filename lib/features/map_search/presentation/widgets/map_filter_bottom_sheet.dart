import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_filter_draft.dart';
import '../../../search/blocs/room_filter/room_filter_cubit.dart';
import '../../../search/blocs/room_filter/room_filter_state.dart';
import '../../../search/presentations/search_screen/widgets/room_filter_form_slivers.dart';

Future<void> showMapFilterBottomSheet(
  BuildContext context, {
  required void Function(List<PropertyModel> results) onFilterApplied,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => MapFilterBottomSheet(
      onFilterApplied: onFilterApplied,
    ),
  );
}

class MapFilterBottomSheet extends StatelessWidget {
  const MapFilterBottomSheet({
    super.key,
    required this.onFilterApplied,
  });

  final void Function(List<PropertyModel> results) onFilterApplied;

  static bool _listenForMapApply(RoomFilterState prev, RoomFilterState curr) {
    if (curr.applyTarget != FilterApplyTarget.map) {
      return false;
    }
    final mapError =
        curr.applyError != null &&
        curr.applyError != prev.applyError &&
        !curr.isApplying;
    final mapResultsReady =
        !curr.isApplying &&
        curr.applyError == null &&
        curr.applyResults != null &&
        curr.applyResults != prev.applyResults;
    return mapResultsReady || mapError;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomFilterCubit, RoomFilterState>(
      listenWhen: _listenForMapApply,
      listener: (context, state) {
        if (state.applyError != null && state.applyError!.isNotEmpty) {
          Alerts.of(context).showError(state.applyError!);
          context.read<RoomFilterCubit>().clearApplyOutcome();
          return;
        }

        final results = state.applyResults;
        if (results == null) {
          return;
        }

        Navigator.of(context).pop();
        onFilterApplied(results);
        context.read<RoomFilterCubit>().clearApplyOutcome(keepTarget: true);
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: _MapFilterSheetHeader(
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const RoomFilterFormSlivers(),
                      SliverToBoxAdapter(child: SizedBox(height: 96.h)),
                    ],
                  ),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 16.h,
                    child: SafeArea(
                      top: false,
                      child: _MapFilterApplyButton(
                        onApply: () => context
                            .read<RoomFilterCubit>()
                            .applyFilter(target: FilterApplyTarget.map),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapFilterSheetHeader extends StatelessWidget {
  const _MapFilterSheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final draft = context.select<RoomFilterCubit, RoomFilterDraft>(
      (cubit) => cubit.state.draft,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
          Expanded(
            child: Text(
              'Lọc tìm phòng',
              textAlign: TextAlign.center,
              style: AppTypography.bold16(),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            onPressed: draft == RoomFilterDraft.initial
                ? null
                : () => context.read<RoomFilterCubit>().resetDraftToInitial(),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );
  }
}

class _MapFilterApplyButton extends StatelessWidget {
  const _MapFilterApplyButton({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final isApplying = context.select<RoomFilterCubit, bool>(
      (cubit) => cubit.state.isApplying,
    );

    return FilledButton(
      onPressed: isApplying ? null : onApply,
      child: Text(isApplying ? 'Đang lọc...' : 'Áp dụng'),
    );
  }
}
