import '../../../../core/constants/property_constants.dart';
import '../../../../core/services/local_location_service.dart';
import '../models/property_model.dart';
import '../models/room_filter_draft.dart';
import '../models/room_model.dart';

abstract class PropertyFilterMatcher {
  static List<PropertyModel> applyCriteria(
    List<PropertyModel> source,
    RoomFilterCriteria criteria,
  ) {
    final out = <PropertyModel>[];
    for (final p in source) {
      final rooms = p.rooms ?? [];
      if (rooms.isEmpty) {
        continue;
      }

      if (!_matchesCity(p, criteria)) {
        continue;
      }
      if (!_matchesWard(p, criteria)) {
        continue;
      }
      if (!_matchesPropertyType(p, criteria)) {
        continue;
      }
      if (!_matchesPropertyPriceRange(p, criteria)) {
        continue;
      }

      final filteredRooms = rooms
          .where(
            (r) =>
                PropertyConstants.priceMatchesAnySelectedBrackets(
                  r.price,
                  criteria.selectedPriceBracketIndexes,
                ) &&
                _roomMatchesAmenities(r, p, criteria.selectedAmenityLabels),
          )
          .toList();

      if (filteredRooms.isEmpty) {
        continue;
      }
      out.add(p.copyWith(rooms: filteredRooms));
    }
    return out;
  }

  static String _fold(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static bool _matchesCity(PropertyModel p, RoomFilterCriteria c) {
    if (c.city == null || c.city!.isEmpty) {
      return true;
    }
    final fc = _fold(c.city!);
    final pc = _fold(p.city);

    if (fc.contains('tp.') && fc.contains('hcm')) {
      return pc.contains('hồ chí minh') ||
          pc.contains('ho chi minh') ||
          pc.contains('tphcm') ||
          pc.contains('tp hcm') ||
          pc.contains('thành phố hồ chí minh');
    }
    if (fc.contains('hà nội') || fc.contains('ha noi')) {
      return pc.contains('hà nội') || pc.contains('ha noi');
    }
    return pc.contains(fc) || fc.contains(pc);
  }

  static bool _matchesWard(PropertyModel p, RoomFilterCriteria c) {
    if (c.selectedWards.isEmpty) {
      return true;
    }
    final loc = LocalLocationService();
    for (final selected in c.selectedWards) {
      if (loc.wardsMatch(
        city: c.city ?? p.city,
        propertyWard: p.ward,
        selectedWard: selected,
      )) {
        return true;
      }
    }
    return false;
  }

  /// Bước 2 (local tinh): chỉ giữ phòng khớp từng bracket đã chọn.
  static bool _matchesPropertyPriceRange(
    PropertyModel p,
    RoomFilterCriteria c,
  ) {
    return PropertyConstants.propertyPriceOverlapsSelectedBrackets(
      minRoomPrice: p.minRoomPrice,
      maxRoomPrice: p.maxRoomPrice,
      selectedIndexes: c.selectedPriceBracketIndexes,
    );
  }

  static bool _matchesPropertyType(PropertyModel p, RoomFilterCriteria c) {
    if (c.selectedPropertyTypes.isEmpty) {
      return true;
    }
    final wants = c.selectedPropertyTypes
        .map(PropertyConstants.normalizePropertyType)
        .map(_fold)
        .where((e) => e.isNotEmpty)
        .toSet();
    if (wants.isEmpty) {
      return true;
    }
    for (final pt in p.propertyTypes) {
      final got = _fold(PropertyConstants.normalizePropertyType(pt));
      if (got.isEmpty) {
        continue;
      }
      for (final want in wants) {
        if (got.contains(want) || want.contains(got)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Mỗi nhãn chip đã chọn phải thỏa (AND).
  static bool _roomMatchesAmenities(
    RoomModel room,
    PropertyModel property,
    Set<String> selectedLabels,
  ) {
    if (selectedLabels.isEmpty) {
      return true;
    }
    for (final label in selectedLabels) {
      if (!_singleAmenity(room, property, label)) {
        return false;
      }
    }
    return true;
  }

  static bool _singleAmenity(
    RoomModel room,
    PropertyModel property,
    String label,
  ) {
    final needle = _fold(label);
    for (final a in room.amenities) {
      final hay = _fold(a.label);
      if (hay.contains(needle) || needle.contains(hay)) {
        return true;
      }
    }
    for (final f in property.facilities ?? const <String>[]) {
      final hay = _fold(f);
      if (hay.contains(needle)) {
        return true;
      }
    }
    return false;
  }
}
