import '../../features/home/data/models/amenity_option.dart';

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

  static const List<String> priceFilterLabels = [
    '< 2 triệu',
    '2 - 3 triệu',
    '3 - 4 triệu',
    '4 - 5 triệu',
    '5 - 6 triệu',
    '6 - 8 triệu',
    '8 - 10 triệu',
    '10 - 12 triệu',
    '> 12 triệu',
  ];

  static bool priceMatchesBracket(int priceVnd, int index) {
    switch (index) {
      case 0:
        return priceVnd < 2000000;
      case 1:
        return priceVnd >= 2000000 && priceVnd <= 3000000;
      case 2:
        return priceVnd >= 3000000 && priceVnd <= 4000000;
      case 3:
        return priceVnd >= 4000000 && priceVnd <= 5000000;
      case 4:
        return priceVnd >= 5000000 && priceVnd <= 6000000;
      case 5:
        return priceVnd >= 6000000 && priceVnd <= 8000000;
      case 6:
        return priceVnd >= 8000000 && priceVnd <= 10000000;
      case 7:
        return priceVnd >= 10000000 && priceVnd <= 12000000;
      case 8:
        return priceVnd >= 12000000;
      default:
        return false;
    }
  }

  static bool priceMatchesAnySelectedBrackets(
    int priceVnd,
    Set<int> selectedIndexes,
  ) {
    if (selectedIndexes.isEmpty) return true;
    for (final i in selectedIndexes) {
      if (priceMatchesBracket(priceVnd, i)) return true;
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
    var minInclusive = 9223372036854775807;
    var maxInclusive = 0;
    for (final i in indexes) {
      final b = _bracketInclusiveBounds(i);
      if (b == null) {
        continue;
      }
      if (b.$1 < minInclusive) {
        minInclusive = b.$1;
      }
      if (b.$2 > maxInclusive) {
        maxInclusive = b.$2;
      }
    }
    if (minInclusive > maxInclusive) {
      return null;
    }
    return (minInclusive: minInclusive, maxInclusive: maxInclusive);
  }

  static (int minInclusive, int maxInclusive)? _bracketInclusiveBounds(
    int index,
  ) {
    switch (index) {
      case 0:
        return (0, 1999999);
      case 1:
        return (2000000, 2999999);
      case 2:
        return (3000000, 3999999);
      case 3:
        return (4000000, 4999999);
      case 4:
        return (5000000, 5999999);
      case 5:
        return (6000000, 7999999);
      case 6:
        return (8000000, 9999999);
      case 7:
        return (10000000, 11999999);
      case 8:
        return (12000000, 2000000000);
      default:
        return null;
    }
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
  ];
}
