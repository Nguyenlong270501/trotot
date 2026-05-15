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
  final Set<String> _disabledCategoryTypes = {};

  StreamSubscription<List<PropertyModel>>? _propertiesSub;

  Future<void> watch({String? city}) async {
    if (city != null) {
      _selectedCity = city;
      _selectedCategory = null;
    }

    emit(
      HomeSuggestedRoomsLoading(
        selectedCity: _selectedCity,
        disabledCategoryTypes: Set.unmodifiable(_disabledCategoryTypes),
      ),
    );

    await _refreshDisabledCategories();
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
    if (_disabledCategoryTypes.contains(normalized)) {
      return;
    }

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
          disabledCategoryTypes: Set.unmodifiable(_disabledCategoryTypes),
          selectedCategory: _selectedCategory,
        ),
      );
    }

    await _subscribeToFeed();
  }

  Future<void> _refreshDisabledCategories() async {
    final disabled = <String>{};

    for (final type in PropertyConstants.propertyTypes) {
      final normalized = PropertyConstants.normalizePropertyType(type);
      final result = await _repository.hasApprovedPropertyForType(
        city: _selectedCity,
        propertyType: normalized,
      );
      result.fold((_) {}, (hasAny) {
        if (!hasAny) {
          disabled.add(normalized);
        }
      });
    }

    _disabledCategoryTypes
      ..clear()
      ..addAll(disabled);

    if (_selectedCategory != null &&
        _disabledCategoryTypes.contains(_selectedCategory)) {
      _selectedCategory = null;
    }
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
        emit(
          HomeSuggestedRoomsLoaded(
            List<PropertyModel>.from(properties),
            selectedCategory: _selectedCategory,
            selectedCity: _selectedCity,
            disabledCategoryTypes: Set.unmodifiable(_disabledCategoryTypes),
            isRefreshingCategory: false,
          ),
        );
        if (completer != null && !completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object error) {
        if (isClosed) {
          return;
        }
        emit(
          HomeSuggestedRoomsFailure(
            error.toString(),
            selectedCity: _selectedCity,
            disabledCategoryTypes: Set.unmodifiable(_disabledCategoryTypes),
            selectedCategory: _selectedCategory,
          ),
        );
        if (completer != null && !completer.isCompleted) {
          completer.complete();
        }
      },
    );
  }

  @override
  Future<void> close() {
    _propertiesSub?.cancel();
    return super.close();
  }
}
