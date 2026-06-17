import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/data/models/property_model.dart';
import '../../../home/data/repositories/home_repository.dart';
import 'room_filter_state.dart';

class RoomFilterCubit extends Cubit<RoomFilterState> {
  RoomFilterCubit(this._repository) : super(RoomFilterState.initial);

  final HomeRepository _repository;
  StreamSubscription<List<PropertyModel>>? _filterResultsSub;

  List<FilterSheetOption> _filterSheetOptions(
    String query,
    List<FilterSheetOption> options,
  ) {
    final normalizedQuery = removeDiacritics(query).toLowerCase().trim();
    if (normalizedQuery.isEmpty) {
      return List<FilterSheetOption>.from(options);
    }
    return options
        .where(
          (option) => removeDiacritics(
            option.label,
          ).toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  void setCity(String city, {required bool resetWard}) {
    emit(
      state.copyWith(
        draft: resetWard
            ? state.draft.copyWith(city: city, clearWards: true)
            : state.draft.copyWith(city: city),
        clearApplyError: true,
        clearApplyResults: true,
      ),
    );
  }

  void setWard(String? ward) {
    setSelectedWards(
      ward == null || ward.trim().isEmpty ? const {} : {ward.trim()},
    );
  }

  void setPropertyType(String? propertyType) {
    setSelectedPropertyTypes(
      propertyType == null || propertyType.trim().isEmpty
          ? const {}
          : {propertyType.trim()},
    );
  }

  void setSelectedWards(Set<String> wards) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(selectedWards: wards),
        clearApplyError: true,
        clearApplyResults: true,
      ),
    );
  }

  void setSelectedPropertyTypes(Set<String> types) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(selectedPropertyTypes: types),
        clearApplyError: true,
        clearApplyResults: true,
      ),
    );
  }

  void startSheetEdit({
    required FilterSheetType type,
    required String title,
    required String searchHint,
    required List<FilterSheetOption> options,
    required Set<String> initialSelection,
  }) {
    final sortedOptions = List<FilterSheetOption>.from(options)
      ..sort((a, b) => a.label.compareTo(b.label));
    emit(
      state.copyWith(
        activeSheetType: type,
        sheetTitle: title,
        sheetSearchHint: searchHint,
        sheetQuery: '',
        sheetAllOptions: sortedOptions,
        sheetFilteredOptions: sortedOptions,
        sheetStagedSelection: Set<String>.from(initialSelection),
      ),
    );
  }

  void updateSheetQuery(String query) {
    emit(
      state.copyWith(
        sheetQuery: query,
        sheetFilteredOptions: _filterSheetOptions(query, state.sheetAllOptions),
      ),
    );
  }

  void toggleSheetOption(String value) {
    final next = Set<String>.from(state.sheetStagedSelection);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    emit(state.copyWith(sheetStagedSelection: next));
  }

  void clearSheetSelection() {
    emit(state.copyWith(sheetStagedSelection: const <String>{}));
  }

  void removeSheetOption(String value) {
    final next = Set<String>.from(state.sheetStagedSelection);
    next.remove(value);
    emit(state.copyWith(sheetStagedSelection: next));
  }

  void cancelSheetEdit() {
    emit(state.copyWith(clearSheetDraft: true));
  }

  void confirmSheetEdit() {
    var nextDraft = state.draft;
    if (state.activeSheetType == FilterSheetType.ward) {
      nextDraft = nextDraft.copyWith(
        selectedWards: Set<String>.from(state.sheetStagedSelection),
      );
    } else if (state.activeSheetType == FilterSheetType.propertyType) {
      nextDraft = nextDraft.copyWith(
        selectedPropertyTypes: Set<String>.from(state.sheetStagedSelection),
      );
    }

    emit(
      state.copyWith(
        draft: nextDraft,
        clearApplyError: true,
        clearApplyResults: true,
        clearSheetDraft: true,
      ),
    );
  }

  void togglePriceBracket(int index) {
    final next = Set<int>.from(state.draft.selectedPriceBracketIndexes);
    if (next.contains(index)) {
      next.remove(index);
    } else {
      next.add(index);
    }
    emit(
      state.copyWith(
        draft: state.draft.copyWith(selectedPriceBracketIndexes: next),
        clearApplyError: true,
        clearApplyResults: true,
      ),
    );
  }

  void toggleAmenityLabel(String label) {
    final next = Set<String>.from(state.draft.selectedAmenityLabels);
    if (next.contains(label)) {
      next.remove(label);
    } else {
      next.add(label);
    }
    emit(
      state.copyWith(
        draft: state.draft.copyWith(selectedAmenityLabels: next),
        clearApplyError: true,
        clearApplyResults: true,
      ),
    );
  }

  void resetDraftToInitial() {
    unawaited(_cancelFilterWatch());
    emit(RoomFilterState.initial.copyWith(clearSheetDraft: true));
  }

  void clearApplyOutcome({bool keepTarget = false}) {
    emit(
      state.copyWith(
        clearApplyResults: true,
        clearApplyError: true,
        clearApplyTarget: !keepTarget,
      ),
    );
  }

  Future<void> applyFilter({
    FilterApplyTarget target = FilterApplyTarget.list,
  }) async {
    final criteria = state.draft.toCriteria();
    await _cancelFilterWatch();
    emit(
      state.copyWith(
        isApplying: true,
        isWatchingFilterResults: true,
        applyTarget: target,
        clearApplyError: true,
        clearApplyResults: true,
      ),
    );

    _filterResultsSub = _repository.watchFilterProperties(criteria).listen(
      (list) {
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            isApplying: false,
            applyResults: List.from(list),
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            isApplying: false,
            isWatchingFilterResults: false,
            applyError: error.toString(),
            clearApplyResults: true,
          ),
        );
      },
    );
  }

  Future<void> stopFilterWatch({bool clearResults = true}) async {
    await _cancelFilterWatch();
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        isWatchingFilterResults: false,
        clearApplyResults: clearResults,
        clearApplyError: true,
        clearApplyTarget: true,
      ),
    );
  }

  Future<void> _cancelFilterWatch() async {
    await _filterResultsSub?.cancel();
    _filterResultsSub = null;
  }

  @override
  Future<void> close() async {
    await _cancelFilterWatch();
    return super.close();
  }
}
