import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/property_constants.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/home_repository.dart';
import 'home_suggested_rooms_state.dart';

class HomeSuggestedRoomsCubit extends Cubit<HomeSuggestedRoomsState> {
  HomeSuggestedRoomsCubit({required HomeRepository repository})
    : _repository = repository,
      _selectedCity = PropertyConstants.cities.first,
      super(
        HomeSuggestedRoomsInitial(
          selectedCity: PropertyConstants.cities.first,
          disabledCategoryTypes: const {},
        ),
      );

  final HomeRepository _repository;
  String _selectedCity;
  String? _selectedCategory;

  StreamSubscription<List<PropertyModel>>? _propertiesSub;
  Timer? _feedDebounce;

  static const Duration _feedDebounceDuration = Duration(milliseconds: 350);

  Future<void> watch({String? city}) async {
    if (city != null) {
      _selectedCity = city;
      _selectedCategory = null;
    }

    emit(
      HomeSuggestedRoomsLoading(
        selectedCity: _selectedCity,
        disabledCategoryTypes: const {},
      ),
    );

    final completer = Completer<void>();
    await _subscribeToFeed(completer: completer);
    return completer.future;
  }

  void changeCity(String city) {
    if (city == _selectedCity) {
      return;
    }
    watch(city: city);
  }

  Future<void> selectCategory(String categoryType) async {
    final normalized = PropertyConstants.normalizePropertyType(categoryType);
    _selectedCategory = _selectedCategory == normalized ? null : normalized;

    final current = state;
    if (current is HomeSuggestedRoomsLoaded) {
      emit(
        current.copyWith(
          selectedCategory: _selectedCategory,
          clearSelectedCategory: _selectedCategory == null,
          isRefreshingCategory: true,
        ),
      );
    } else {
      emit(
        HomeSuggestedRoomsLoading(
          selectedCity: _selectedCity,
          disabledCategoryTypes: const {},
          selectedCategory: _selectedCategory,
        ),
      );
    }

    await _subscribeToFeed();
  }

  Future<void> _subscribeToFeed({Completer<void>? completer}) async {
    await _propertiesSub?.cancel();
    _propertiesSub = null;

    final stream = _selectedCategory == null
        ? _repository.watchSuggestedProperties(city: _selectedCity)
        : _repository.watchLatestPropertiesByType(
            city: _selectedCity,
            propertyType: _selectedCategory!,
          );

    _propertiesSub = stream.listen(
      (properties) {
        if (isClosed) {
          return;
        }
        _scheduleFeedEmit(
          properties: properties,
          onComplete: completer,
        );
      },
      onError: (Object error) {
        if (isClosed) {
          return;
        }
        _feedDebounce?.cancel();
        emit(
          HomeSuggestedRoomsFailure(
            error.toString(),
            selectedCity: _selectedCity,
            disabledCategoryTypes: const {},
            selectedCategory: _selectedCategory,
          ),
        );
        if (completer != null && !completer.isCompleted) {
          completer.complete();
        }
      },
    );
  }

  void _scheduleFeedEmit({
    required List<PropertyModel> properties,
    Completer<void>? onComplete,
  }) {
    _feedDebounce?.cancel();
    final emitImmediately =
        state is HomeSuggestedRoomsLoading || state is HomeSuggestedRoomsInitial;

    if (emitImmediately) {
      _emitFeed(properties: properties, onComplete: onComplete);
      return;
    }

    _feedDebounce = Timer(_feedDebounceDuration, () {
      if (isClosed) {
        return;
      }
      _emitFeed(properties: properties, onComplete: onComplete);
    });
  }

  void _emitFeed({
    required List<PropertyModel> properties,
    Completer<void>? onComplete,
  }) {
    emit(
      HomeSuggestedRoomsLoaded(
        List<PropertyModel>.from(properties),
        selectedCategory: _selectedCategory,
        selectedCity: _selectedCity,
        disabledCategoryTypes: const {},
        isRefreshingCategory: false,
      ),
    );
    if (onComplete != null && !onComplete.isCompleted) {
      onComplete.complete();
    }
  }

  @override
  Future<void> close() {
    _feedDebounce?.cancel();
    _propertiesSub?.cancel();
    return super.close();
  }
}
