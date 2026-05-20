import '../../../home/data/models/property_model.dart';
import '../../../../core/utils/property_helper.dart';
import '../models/map_property_pin.dart';

abstract final class MapPropertyPinMapper {
  static const int mapFilterPinLimit = 50;

  static MapPropertyPin fromProperty(PropertyModel property) {
    final location = property.location!;
    return MapPropertyPin(
      propertyId: property.propertyId,
      latitude: location.latitude,
      longitude: location.longitude,
      priceLabel: PropertyHelper.mapMarkerPriceLabel(
        minRoomPrice: property.minRoomPrice,
        maxRoomPrice: property.maxRoomPrice,
      ),
    );
  }

  static List<MapPropertyPin> fromProperties(List<PropertyModel> properties) {
    return properties
        .where((property) => property.location != null)
        .take(mapFilterPinLimit)
        .map(fromProperty)
        .toList();
  }

  static String resultsSignature(List<PropertyModel> properties) {
    return properties.map((p) => p.propertyId).join(',');
  }
}
