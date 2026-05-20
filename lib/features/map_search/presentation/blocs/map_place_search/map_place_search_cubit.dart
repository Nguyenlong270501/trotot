import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/goong_autocomplete_prediction_model.dart';
import '../../../data/models/goong_place_detail_model.dart';
import '../../../data/repositories/map_place_search_repository.dart';
import 'map_place_search_state.dart';

class MapPlaceSearchCubit extends Cubit<MapPlaceSearchState> {
  MapPlaceSearchCubit({required MapPlaceSearchRepository repository})
    : _repository = repository,
      super(MapPlaceSearchState.initial());

  static const Duration debounceDuration = Duration(milliseconds: 700);
  static const int minQueryLength = 3;

  final MapPlaceSearchRepository _repository;

  Timer? _debounce;
  int _searchGeneration = 0;
  int _detailGeneration = 0;
  double _biasLatitude = 0;
  double _biasLongitude = 0;

  void reset({
    required double latitude,
    required double longitude,
  }) {
    _debounce?.cancel();
    _searchGeneration++;
    _detailGeneration++;
    _biasLatitude = latitude;
    _biasLongitude = longitude;
    emit(MapPlaceSearchState.initial());
  }

  void updateBias({
    required double latitude,
    required double longitude,
  }) {
    _biasLatitude = latitude;
    _biasLongitude = longitude;
  }

  void onQueryChanged(String value) {
    final query = value.trim();
    _debounce?.cancel();
    _searchGeneration++;

    emit(
      state.copyWith(
        query: value,
        isSearching: false,
        predictions: query.length >= minQueryLength ? state.predictions : [],
        selectedPlace: null,
        errorMessage: null,
      ),
    );

    if (query.length < minQueryLength) {
      return;
    }

    final generation = _searchGeneration;
    _debounce = Timer(debounceDuration, () {
      unawaited(_searchAutocomplete(query, generation));
    });
  }

  Future<void> retry() async {
    final query = state.query.trim();
    if (query.length < minQueryLength) {
      return;
    }
    _debounce?.cancel();
    final generation = ++_searchGeneration;
    await _searchAutocomplete(query, generation);
  }

  Future<void> _searchAutocomplete(String query, int generation) async {
    if (isClosed || generation != _searchGeneration) {
      return;
    }

    emit(
      state.copyWith(
        isSearching: true,
        errorMessage: null,
      ),
    );

    try {
      final predictions = await _repository.autocomplete(
        input: query,
        latitude: _biasLatitude,
        longitude: _biasLongitude,
      );
      if (isClosed || generation != _searchGeneration) {
        return;
      }

      emit(
        state.copyWith(
          isSearching: false,
          predictions: predictions,
          errorMessage: null,
        ),
      );
    } catch (_) {
      if (isClosed || generation != _searchGeneration) {
        return;
      }

      emit(
        state.copyWith(
          isSearching: false,
          predictions: const [],
          errorMessage: 'Không thể tải gợi ý. Thử lại.',
        ),
      );
    }
  }

  Future<GoongPlaceDetailModel?> selectPrediction(
    GoongAutocompletePredictionModel prediction,
  ) async {
    if (prediction.placeId.isEmpty) {
      return null;
    }

    _debounce?.cancel();
    _searchGeneration++;
    final generation = ++_detailGeneration;

    emit(
      state.copyWith(
        isResolvingPlace: true,
        errorMessage: null,
      ),
    );

    try {
      final detail = await _repository.detail(placeId: prediction.placeId);
      if (isClosed || generation != _detailGeneration) {
        return null;
      }

      emit(
        state.copyWith(
          query: detail.displayTitle,
          isResolvingPlace: false,
          predictions: const [],
          selectedPlace: detail,
          errorMessage: null,
        ),
      );
      return detail;
    } catch (_) {
      if (isClosed || generation != _detailGeneration) {
        return null;
      }

      emit(
        state.copyWith(
          isResolvingPlace: false,
          selectedPlace: null,
          errorMessage: 'Không thể lấy vị trí địa điểm này.',
        ),
      );
      return null;
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
