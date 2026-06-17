import '../services/local_location_service.dart';

/// Hàm dùng chung: đổi mã phường/xã (codename) hoặc tên cũ → nhãn hiển thị tiếng Việt.
abstract final class LocationDisplay {
  static String formatWard({String? city, required String ward}) {
    return LocalLocationService().wardDisplayName(city: city, ward: ward);
  }
}
