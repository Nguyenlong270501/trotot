import 'package:equatable/equatable.dart';

import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/room_filter_draft.dart';

enum FilterApplyTarget { list, map }

enum FilterSheetType { none, ward, propertyType }

final class FilterSheetOption extends Equatable {
  const FilterSheetOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}

final class RoomFilterState extends Equatable {
  const RoomFilterState({
    required this.draft,
    this.isApplying = false,
    this.isWatchingFilterResults = false,
    this.applyError,
    this.applyResults,
    this.applyTarget,
    this.activeSheetType = FilterSheetType.none,
    this.sheetTitle = '',
    this.sheetSearchHint = '',
    this.sheetQuery = '',
    this.sheetAllOptions = const <FilterSheetOption>[],
    this.sheetFilteredOptions = const <FilterSheetOption>[],
    this.sheetStagedSelection = const <String>{},
  });

  final RoomFilterDraft draft;
  final bool isApplying;

  /// Đang subscribe Firestore cho màn kết quả lọc.
  final bool isWatchingFilterResults;

  /// Thông báo lỗi lần apply gần nhất (ghi đè mỗi lần thử).
  final String? applyError;

  /// Sau khi apply thành công UI đọc và điều hướng, rồi gọi [clearApplyOutcome].
  final List<PropertyModel>? applyResults;

  /// Đích hiển thị kết quả lần apply gần nhất (list hoặc map).
  final FilterApplyTarget? applyTarget;

  final FilterSheetType activeSheetType;
  final String sheetTitle;
  final String sheetSearchHint;
  final String sheetQuery;
  final List<FilterSheetOption> sheetAllOptions;
  final List<FilterSheetOption> sheetFilteredOptions;
  final Set<String> sheetStagedSelection;

  static const RoomFilterState initial = RoomFilterState(
    draft: RoomFilterDraft.initial,
  );

  RoomFilterState copyWith({
    RoomFilterDraft? draft,
    bool? isApplying,
    bool? isWatchingFilterResults,
    String? applyError,
    List<PropertyModel>? applyResults,
    FilterApplyTarget? applyTarget,
    bool clearApplyError = false,
    bool clearApplyResults = false,
    bool clearApplyTarget = false,
    FilterSheetType? activeSheetType,
    String? sheetTitle,
    String? sheetSearchHint,
    String? sheetQuery,
    List<FilterSheetOption>? sheetAllOptions,
    List<FilterSheetOption>? sheetFilteredOptions,
    Set<String>? sheetStagedSelection,
    bool clearSheetDraft = false,
  }) {
    return RoomFilterState(
      draft: draft ?? this.draft,
      isApplying: isApplying ?? this.isApplying,
      isWatchingFilterResults:
          isWatchingFilterResults ?? this.isWatchingFilterResults,
      applyError: clearApplyError ? null : (applyError ?? this.applyError),
      applyResults: clearApplyResults
          ? null
          : (applyResults ?? this.applyResults),
      applyTarget: clearApplyTarget ? null : (applyTarget ?? this.applyTarget),
      activeSheetType: clearSheetDraft
          ? FilterSheetType.none
          : (activeSheetType ?? this.activeSheetType),
      sheetTitle: clearSheetDraft ? '' : (sheetTitle ?? this.sheetTitle),
      sheetSearchHint: clearSheetDraft
          ? ''
          : (sheetSearchHint ?? this.sheetSearchHint),
      sheetQuery: clearSheetDraft ? '' : (sheetQuery ?? this.sheetQuery),
      sheetAllOptions: clearSheetDraft
          ? const <FilterSheetOption>[]
          : (sheetAllOptions ?? this.sheetAllOptions),
      sheetFilteredOptions: clearSheetDraft
          ? const <FilterSheetOption>[]
          : (sheetFilteredOptions ?? this.sheetFilteredOptions),
      sheetStagedSelection: clearSheetDraft
          ? const <String>{}
          : (sheetStagedSelection ?? this.sheetStagedSelection),
    );
  }

  @override
  List<Object?> get props => [
    draft,
    isApplying,
    isWatchingFilterResults,
    applyError,
    applyResults,
    applyTarget,
    activeSheetType,
    sheetTitle,
    sheetSearchHint,
    sheetQuery,
    sheetAllOptions,
    sheetFilteredOptions,
    sheetStagedSelection,
  ];
}
