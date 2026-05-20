import '../../features/home/data/models/amenity_option.dart';
import 'dart:math' as math;

class PriceFilterBracket {
  const PriceFilterBracket({
    required this.label,
    required this.minInclusive,
    required this.maxInclusive,
  });

  final String label;
  final int minInclusive;
  final int maxInclusive;

  bool containsPrice(int priceVnd) =>
      priceVnd >= minInclusive && priceVnd <= maxInclusive;
}

class PropertyConstants {
  static const List<String> propertyTypes = [
    'Phòng trọ bình dân',
    'Chung cư mini',
    'Căn hộ Studio',
    'Ký túc xá / Ở ghép',
    'Nhà nguyên căn / Căn hộ chung cư',
  ];

  static const List<String> cities = ['Hà Nội', 'TP. HCM'];

  static List<String> firestoreCityAliases(String city) {
    final value = city.trim();
    if (value.isEmpty) {
      return const [];
    }
    if (value == cities[0]) {
      return const ['Hà Nội', 'Ha Noi', 'Hanoi', 'Thành phố Hà Nội'];
    }
    if (value == cities[1]) {
      return const [
        'TP. HCM',
        'TP.HCM',
        'TP HCM',
        'Thành phố Hồ Chí Minh',
        'Ho Chi Minh',
        'Hồ Chí Minh',
      ];
    }
    return [value];
  }

  static String normalizePropertyType(String value) {
    return value.trim();
  }

  static const List<PriceFilterBracket> priceBrackets = [
    PriceFilterBracket(
      label: '< 2 triệu',
      minInclusive: 0,
      maxInclusive: 2000000,
    ),
    PriceFilterBracket(
      label: '2 - 3 triệu',
      minInclusive: 2000000,
      maxInclusive: 3000000,
    ),
    PriceFilterBracket(
      label: '3 - 4 triệu',
      minInclusive: 3000000,
      maxInclusive: 4000000,
    ),
    PriceFilterBracket(
      label: '4 - 5 triệu',
      minInclusive: 4000000,
      maxInclusive: 5000000,
    ),
    PriceFilterBracket(
      label: '5 - 6 triệu',
      minInclusive: 5000000,
      maxInclusive: 6000000,
    ),
    PriceFilterBracket(
      label: '6 - 8 triệu',
      minInclusive: 6000000,
      maxInclusive: 8000000,
    ),
    PriceFilterBracket(
      label: '8 - 10 triệu',
      minInclusive: 8000000,
      maxInclusive: 10000000,
    ),
    PriceFilterBracket(
      label: '10 - 12 triệu',
      minInclusive: 10000000,
      maxInclusive: 12000000,
    ),
    PriceFilterBracket(
      label: '> 12 triệu',
      minInclusive: 12000000,
      maxInclusive: 2000000000,
    ),
  ];

  static PriceFilterBracket? bracketAt(int index) {
    if (index < 0 || index >= priceBrackets.length) {
      return null;
    }
    return priceBrackets[index];
  }

  static bool priceMatchesAnySelectedBrackets(
    int priceVnd,
    Set<int> selectedIndexes,
  ) {
    if (selectedIndexes.isEmpty) {
      return true;
    }
    for (final index in selectedIndexes) {
      final bracket = bracketAt(index);
      if (bracket != null && bracket.containsPrice(priceVnd)) {
        return true;
      }
    }
    return false;
  }

  static bool propertyPriceOverlapsSelectedBrackets({
    required int? minRoomPrice,
    required int? maxRoomPrice,
    required Set<int> selectedIndexes,
  }) {
    if (selectedIndexes.isEmpty) {
      return true;
    }
    if (minRoomPrice == null || maxRoomPrice == null) {
      return false;
    }
    final bounds = priceBracketSearchUnion(selectedIndexes);
    if (bounds == null) {
      return true;
    }
    return minRoomPrice <= bounds.maxInclusive &&
        maxRoomPrice >= bounds.minInclusive;
  }

  static ({int minInclusive, int maxInclusive})? priceBracketSearchUnion(
    Set<int> indexes,
  ) {
    if (indexes.isEmpty) {
      return null;
    }

    int? minInclusive;
    int? maxInclusive;

    for (final index in indexes) {
      final bracket = bracketAt(index);
      if (bracket == null) {
        continue;
      }

      minInclusive = minInclusive == null
          ? bracket.minInclusive
          : math.min(minInclusive, bracket.minInclusive);

      maxInclusive = maxInclusive == null
          ? bracket.maxInclusive
          : math.max(maxInclusive, bracket.maxInclusive);
    }

    if (minInclusive == null || maxInclusive == null) {
      return null;
    }

    return (minInclusive: minInclusive, maxInclusive: maxInclusive);
  }

  static const List<AmenityOption> amenities = [
    AmenityOption(emoji: '🛜', label: 'Wifi Free'),
    AmenityOption(emoji: '🅿️', label: 'Bãi để xe'),
    AmenityOption(emoji: '🛗', label: 'Thang máy'),
    AmenityOption(emoji: '📹', label: 'Camera 24/7'),
    AmenityOption(emoji: '🧺', label: 'Máy giặt chung'),
    AmenityOption(emoji: '🚿', label: 'Nhà tắm riêng'),
  ];

  static const List<AmenityOption> roomAmenities = [
    AmenityOption(emoji: '❄️', label: 'Điều hòa'),
    AmenityOption(emoji: '🚿', label: 'Nóng lạnh'),
    AmenityOption(emoji: '🍳', label: 'Kệ bếp'),
    AmenityOption(emoji: '🛏️', label: 'Giường nệm'),
    AmenityOption(emoji: '🍳', label: 'Bếp'),
    AmenityOption(emoji: '🪟', label: 'Cửa sổ'),
    AmenityOption(emoji: '🪜', label: 'Gác xép'),
    AmenityOption(emoji: '🚪', label: 'Tủ quần áo'),
    AmenityOption(emoji: '🧊', label: 'Tủ lạnh'),
    AmenityOption(emoji: '🌅', label: 'Ban công'),
    AmenityOption(emoji: '💼', label: 'Phù hợp kinh doanh'),
    AmenityOption(emoji: '🧺', label: 'Máy giặt riêng'),
  ];
}
