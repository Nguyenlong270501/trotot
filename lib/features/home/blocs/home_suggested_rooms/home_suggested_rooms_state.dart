import 'package:equatable/equatable.dart';

import '../../data/models/property_model.dart';

abstract class HomeSuggestedRoomsState extends Equatable {
  const HomeSuggestedRoomsState({
    required this.selectedCity,
    required this.disabledCategoryTypes,
    this.selectedCategory,
  });

  final String selectedCity;
  final Set<String> disabledCategoryTypes;
  final String? selectedCategory;

  @override
  List<Object?> get props => [
    selectedCity,
    disabledCategoryTypes,
    selectedCategory,
  ];
}

class HomeSuggestedRoomsInitial extends HomeSuggestedRoomsState {
  const HomeSuggestedRoomsInitial({
    required super.selectedCity,
    required super.disabledCategoryTypes,
  });
}

class HomeSuggestedRoomsLoading extends HomeSuggestedRoomsState {
  const HomeSuggestedRoomsLoading({
    required super.selectedCity,
    required super.disabledCategoryTypes,
    super.selectedCategory,
  });
}

class HomeSuggestedRoomsLoaded extends HomeSuggestedRoomsState {
  const HomeSuggestedRoomsLoaded(
    this.properties, {
    required super.selectedCity,
    required super.disabledCategoryTypes,
    super.selectedCategory,
    this.isRefreshingCategory = false,
  });

  final List<PropertyModel> properties;
  final bool isRefreshingCategory;

  HomeSuggestedRoomsLoaded copyWith({
    List<PropertyModel>? properties,
    String? selectedCity,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    Set<String>? disabledCategoryTypes,
    bool? isRefreshingCategory,
  }) {
    return HomeSuggestedRoomsLoaded(
      properties ?? this.properties,
      selectedCity: selectedCity ?? this.selectedCity,
      disabledCategoryTypes:
          disabledCategoryTypes ?? this.disabledCategoryTypes,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      isRefreshingCategory: isRefreshingCategory ?? this.isRefreshingCategory,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    properties,
    isRefreshingCategory,
  ];
}

class HomeSuggestedRoomsFailure extends HomeSuggestedRoomsState {
  const HomeSuggestedRoomsFailure(
    this.message, {
    required super.selectedCity,
    required super.disabledCategoryTypes,
    super.selectedCategory,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
