import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../data/models/goong_autocomplete_prediction_model.dart';
import '../../data/models/goong_place_detail_model.dart';
import '../blocs/map_place_search/map_place_search_cubit.dart';
import '../blocs/map_place_search/map_place_search_state.dart';

class MapSearchTopBarController {
  _MapSearchTopBarState? _state;

  void unfocus() => _state?._unfocus();
}

class MapSearchTopBar extends StatefulWidget {
  const MapSearchTopBar({
    super.key,
    required this.onPlaceSelected,
    this.controller,
    this.onFocus,
    this.onFocusChanged,
  });

  final Future<void> Function(GoongPlaceDetailModel place) onPlaceSelected;
  final MapSearchTopBarController? controller;
  final VoidCallback? onFocus;
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<MapSearchTopBar> createState() => _MapSearchTopBarState();
}

class _MapSearchTopBarState extends State<MapSearchTopBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _hasFocusNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant MapSearchTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    _focusNode.removeListener(_handleFocusChanged);
    _hasFocusNotifier.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      widget.onFocus?.call();
    }
    widget.onFocusChanged?.call(_focusNode.hasFocus);
    _hasFocusNotifier.value = _focusNode.hasFocus;
  }

  void _unfocus() {
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapPlaceSearchCubit, MapPlaceSearchState>(
      listenWhen: (previous, current) =>
          previous.selectedPlace != current.selectedPlace,
      listener: (context, state) {
        final selectedPlace = state.selectedPlace;
        if (selectedPlace == null) {
          return;
        }
        _controller.text = selectedPlace.displayTitle;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SearchField(controller: _controller, focusNode: _focusNode),
          ValueListenableBuilder<bool>(
            valueListenable: _hasFocusNotifier,
            builder: (context, hasFocus, child) {
              if (!hasFocus) {
                return const SizedBox.shrink();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSizes.gapH4,
                  _SuggestionDropdown(
                    onSelected: (place) async {
                      _focusNode.unfocus();
                      await widget.onPlaceSelected(place);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 4,
      shadowColor: AppColors.shadowSoft,
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 48.h,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          onChanged: context.read<MapPlaceSearchCubit>().onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Tìm khu vực, địa chỉ...',
            hintStyle: AppTypography.medium14(color: AppColors.textMuted),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 22.sp,
              color: AppColors.textMuted,
            ),
            suffixIcon: BlocBuilder<MapPlaceSearchCubit, MapPlaceSearchState>(
              buildWhen: (previous, current) =>
                  previous.query != current.query ||
                  previous.isSearching != current.isSearching ||
                  previous.isResolvingPlace != current.isResolvingPlace,
              builder: (context, state) {
                if (state.isSearching || state.isResolvingPlace) {
                  return Padding(
                    padding: EdgeInsets.all(14.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (state.query.trim().isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  constraints: BoxConstraints.tightFor(
                    width: 48.w,
                    height: 48.h,
                  ),
                  onPressed: () {
                    controller.clear();
                    context.read<MapPlaceSearchCubit>().onQueryChanged('');
                    focusNode.requestFocus();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

class _SuggestionDropdown extends StatelessWidget {
  const _SuggestionDropdown({required this.onSelected});

  final Future<void> Function(GoongPlaceDetailModel place) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapPlaceSearchCubit, MapPlaceSearchState>(
      builder: (context, state) {
        final query = state.query.trim();
        final shouldShow =
            query.length >= MapPlaceSearchCubit.minQueryLength ||
            state.predictions.isNotEmpty ||
            state.errorMessage != null;
        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return Material(
          color: AppColors.surface,
          elevation: 4,
          shadowColor: AppColors.shadowSoft,
          borderRadius: BorderRadius.circular(10.r),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 220.h),
            child: _SuggestionContent(state: state, onSelected: onSelected),
          ),
        );
      },
    );
  }
}

class _SuggestionContent extends StatelessWidget {
  const _SuggestionContent({required this.state, required this.onSelected});

  final MapPlaceSearchState state;
  final Future<void> Function(GoongPlaceDetailModel place) onSelected;

  @override
  Widget build(BuildContext context) {
    final query = state.query.trim();
    if (query.length < MapPlaceSearchCubit.minQueryLength) {
      return const SizedBox.shrink();
    }
    if (state.errorMessage != null) {
      return _DropdownError(message: state.errorMessage!);
    }
    if (state.isSearching && state.predictions.isEmpty) {
      return const _DropdownMessage(
        text: 'Đang tải gợi ý...',
        showSpinner: true,
      );
    }
    if (state.isResolvingPlace) {
      return const _DropdownMessage(
        text: 'Đang lấy vị trí địa điểm...',
        showSpinner: true,
      );
    }
    if (state.predictions.isEmpty) {
      return const _DropdownMessage(text: 'Không tìm thấy địa điểm');
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: state.predictions.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        return _SuggestionTile(
          prediction: state.predictions[index],
          onSelected: onSelected,
        );
      },
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.prediction, required this.onSelected});

  final GoongAutocompletePredictionModel prediction;
  final Future<void> Function(GoongPlaceDetailModel place) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.h,
      child: ListTile(
        minLeadingWidth: 24.w,
        horizontalTitleGap: 8.w,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
        leading: Icon(
          Icons.location_on_outlined,
          size: 24.sp,
          color: AppColors.primary,
        ),
        title: Text(
          prediction.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bold14(
            color: AppColors.textPrimary,
          ).copyWith(height: 1.2),
        ),
        onTap: () async {
          final cubit = context.read<MapPlaceSearchCubit>();
          final detail = await cubit.selectPrediction(prediction);
          if (detail != null) {
            await onSelected(detail);
          }
        },
      ),
    );
  }
}

class _DropdownError extends StatelessWidget {
  const _DropdownError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.medium12(
                  color: AppColors.textPrimary,
                ).copyWith(height: 1.2),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.read<MapPlaceSearchCubit>().retry(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _DropdownMessage extends StatelessWidget {
  const _DropdownMessage({required this.text, this.showSpinner = false});

  final String text;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner) ...[
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            AppSizes.gapW10,
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.medium12(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
