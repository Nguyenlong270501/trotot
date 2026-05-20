import '../../../home/data/models/property_model.dart';
import '../../../../core/utils/property_helper.dart';
import '../../../../core/constants/map_search_constants.dart';
import '../models/map_property_pin.dart';

abstract final class MapPropertyPinMapper {
  static MapPropertyPin fromProperty(PropertyModel property) {
    return MapPropertyPin(
      propertyId: property.propertyId,
      latitude: property.latitude!,
      longitude: property.longitude!,
      priceLabel: PropertyHelper.mapMarkerPriceLabel(
        minRoomPrice: property.minRoomPrice,
        maxRoomPrice: property.maxRoomPrice,
      ),
    );
  }

  static List<MapPropertyPin> fromProperties(List<PropertyModel> properties) {
    return properties
        .where(
          (property) => property.latitude != null && property.longitude != null,
        )
        .take(MapSearchConstants.mapPropertyRenderLimit)
        .map(fromProperty)
        .toList();
  }

  static String resultsSignature(List<PropertyModel> properties) {
    return properties
        .map((p) => '${p.propertyId}:${p.latitude}:${p.longitude}')
        .join(',');
  }
}
