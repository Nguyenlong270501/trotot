import 'package:equatable/equatable.dart';

import '../../data/models/goong_autocomplete_prediction_model.dart';
import '../../data/models/goong_place_detail_model.dart';

class MapPlaceSearchState extends Equatable {
  const MapPlaceSearchState({
    required this.query,
    required this.isSearching,
    required this.isResolvingPlace,
    required this.predictions,
    this.selectedPlace,
    this.errorMessage,
  });

  factory MapPlaceSearchState.initial() {
    return const MapPlaceSearchState(
      query: '',
      isSearching: false,
      isResolvingPlace: false,
      predictions: [],
      selectedPlace: null,
      errorMessage: null,
    );
  }

  final String query;
  final bool isSearching;
  final bool isResolvingPlace;
  final List<GoongAutocompletePredictionModel> predictions;
  final GoongPlaceDetailModel? selectedPlace;
  final String? errorMessage;

  static const Object _unset = Object();

  MapPlaceSearchState copyWith({
    String? query,
    bool? isSearching,
    bool? isResolvingPlace,
    List<GoongAutocompletePredictionModel>? predictions,
    Object? selectedPlace = _unset,
    Object? errorMessage = _unset,
  }) {
    return MapPlaceSearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      isResolvingPlace: isResolvingPlace ?? this.isResolvingPlace,
      predictions: predictions ?? this.predictions,
      selectedPlace: selectedPlace == _unset
          ? this.selectedPlace
          : selectedPlace as GoongPlaceDetailModel?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    query,
    isSearching,
    isResolvingPlace,
    predictions,
    selectedPlace,
    errorMessage,
  ];
}
