import '../../features/home/data/models/property_model.dart';
import '../../features/home/data/models/room_model.dart';
import '../../features/home/data/models/room_amenity.dart';
import '../constants/rules_key.dart';
import 'location_display.dart';


class PropertyHelper {

  static String orPlaceholder(String? value, String placeholder) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? placeholder : trimmed;
  }


  static String formatPrice(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// Định dạng giá kèm đơn vị (Ví dụ: 3.000.000 đ/tháng)
  static String formatFeePerUnit(String rawValue, String suffix) {
    final value = int.tryParse(rawValue) ?? 0;
    return '${formatPrice(value)} $suffix';
  }

  // --- 2. XỬ LÝ ĐỊA CHỈ (Đã chuyển từ HomeScreen sang) ---

  /// Trả về chuỗi địa chỉ rút gọn: "Phường/Xã, Quận/Huyện"
  static String propertyLocationSubtitle(PropertyModel p) {
    final street = p.streetAddress.trim();
    final ward = LocationDisplay.formatWard(city: p.city, ward: p.ward);
    final city = p.city.trim();
    if (ward.isEmpty && city.isEmpty && street.isEmpty) return '';
    if (ward.isEmpty && city.isEmpty) return street;
    if (ward.isEmpty) return city;
    if (city.isEmpty) return ward;
    return '$street, $ward, $city';
  }

  /// Trả về địa chỉ dự phòng cho phòng: "Đường, Phường" hoặc "Thành phố"
  static String roomFallbackLocation(RoomModel room, PropertyModel p) {
    final street = p.streetAddress.trim();
    final ward = LocationDisplay.formatWard(city: p.city, ward: p.ward);
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (ward.isNotEmpty) parts.add(ward);
    if (parts.isEmpty) return p.city.trim();
    return parts.join(', ');
  }

  // --- 3. LOGIC TIỆN ÍCH & NỘI QUY (Dành cho màn Chi tiết) ---

  /// Chuyển đổi dữ liệu thô từ PropertyModel thành danh sách các icon và nhãn hiển thị
  static List<RoomAmenity> getAmenitiesAndRules(PropertyModel property) {
    final chips = <RoomAmenity>[];
    
    // Giả định bồ có danh sách mẫu để map emoji
    // final amenities = PropertyConstants.amenities; 

    // Quét tiện ích cơ bản
    for (final label in property.facilities ?? []) {
      // Tìm emoji tương ứng hoặc dùng mặc định ✅
      // final matched = amenities.where((a) => a.label == label);
      // final emoji = matched.isNotEmpty ? matched.first.emoji : '✅';
      chips.add(RoomAmenity('✅', label)); 
    }

    // Quét nội quy quan trọng
    final rules = property.rules ?? [];

    if (rules.contains(RuleKeys.noShared)) {
      chips.add(const RoomAmenity('🗝️', 'Không chung chủ'));
    }
    if (rules.contains(RuleKeys.allowPet)) {
      chips.add(const RoomAmenity('🐾', 'Cho nuôi Pet'));
    }

    // Xử lý giờ giấc
    if (rules.contains(RuleKeys.freeTime)) {
      chips.add(const RoomAmenity('🕛', 'Giờ giấc tự do'));
    } else if (property.curfewTime != null && property.curfewTime!.trim().isNotEmpty) {
      chips.add(RoomAmenity('🕛', 'Đóng cửa ${property.curfewTime}'));
    }

    if (rules.contains(RuleKeys.electricBike)) {
      chips.add(const RoomAmenity('🛵', 'Cho để xe điện'));
    }
    
    return chips;
  }

  // --- 4. THÔNG TIN PHÒNG & GIÁ ---

  /// Tính toán khoảng giá từ danh sách phòng (Ví dụ: "Giá từ: 2 đến 5 triệu/tháng")
  static (String, String) priceRangeLabel(List<RoomModel> rooms) {
    if (rooms.isEmpty) return ('Giá: ', '—');
    final prices = rooms.map((r) => r.price).toList(); 
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    String toTrieu(int p) {
      double trieu = p / 1000000;
      return trieu == trieu.toInt()
          ? trieu.toInt().toString()
          : trieu.toString().replaceAll('.', ',');
    }

    if (minPrice == maxPrice) {
      return ('Giá: ', '${toTrieu(minPrice)} triệu/tháng');
    } else {
      return ('Giá từ: ', '${toTrieu(minPrice)} đến ${toTrieu(maxPrice)} triệu/tháng');
    }
  }

  /// Định dạng nhãn tiền cọc
  static String buildDepositLabel(int firstRoomDeposit) {
    if (firstRoomDeposit <= 0) return 'Không yêu cầu cọc';
    return '${formatPrice(firstRoomDeposit)} đ';
  }

  /// Định dạng diện tích (Ví dụ: 25.0 -> 25 m2)
  static String formatAreaLabel(String area) {
    if (area.trim().isEmpty) return '—';
    final cleanArea = area.replaceAll(RegExp(r'\.0*$'), '');
    return '$cleanArea m2';
  }

  static const Duration newListingMaxAge = Duration(days: 7);

  /// Bài đăng trong vòng [maxAge] (mặc định 7 ngày) được coi là "MỚI".
  static bool isNewListing(
    DateTime createdAt, {
    Duration maxAge = newListingMaxAge,
  }) {
    return DateTime.now().difference(createdAt) < maxAge;
  }

  /// Định dạng thời gian đăng bài (Ví dụ: "Đăng 3 giờ trước")
  static String formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return 'Đăng ${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return 'Đăng ${diff.inHours} giờ trước';
    return 'Đăng ${diff.inDays} ngày trước';
  }

  /// Thâm niên hiển thị trên card chủ nhà.
  static String landlordHostingTenureLabel(DateTime memberSince) {
    final diff = DateTime.now().difference(memberSince).inDays;
    if (diff < 30) return 'Dưới 1 tháng';
    final months = diff ~/ 30;
    return '$months tháng';
  }
}