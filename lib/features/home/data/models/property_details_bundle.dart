import 'property_model.dart';
import 'room_model.dart';

class PropertyDetailsBundle {
  const PropertyDetailsBundle({
    required this.property,
    required this.rooms,
    this.exists = true,
  });

  const PropertyDetailsBundle.missing()
    : property = null,
      rooms = const [],
      exists = false;

  final PropertyModel? property;
  final List<RoomModel> rooms;
  final bool exists;
}
