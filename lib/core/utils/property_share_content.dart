import '../../features/home/data/models/property_model.dart';
import 'property_helper.dart';

class PropertyShareContent {
  const PropertyShareContent._();

  static String buildText(PropertyModel property) {

    final address = PropertyHelper.propertyLocationSubtitle(property).trim();

    final price = _priceLabel(property);

    return [
      if (address.isNotEmpty) '📍 $address',
      if (price.isNotEmpty) '💰 $price',
      '',
      'Liên hệ qua ứng dụng Trọ Tốt để xem chi tiết.',
    ].join('\n');
  }

  static String _priceLabel(PropertyModel property) {
    final min = property.minRoomPrice;
    final max = property.maxRoomPrice;

    if (min == null && max == null) {
      return '';
    }

    if (min == null) {
      return '${PropertyHelper.formatPrice(max!)} đ/tháng';
    }

    if (max == null || min == max) {
      return '${PropertyHelper.formatPrice(min)} đ/tháng';
    }

    return '${PropertyHelper.formatPrice(min)} - '
        '${PropertyHelper.formatPrice(max)} đ/tháng';
  }
}
