import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/property_model.dart';
import '../models/room_filter_draft.dart';

abstract class HomeRepository {
  Stream<List<PropertyModel>> watchSuggestedProperties({required String city});

  Stream<List<PropertyModel>> watchLatestPropertiesByType({
    required String city,
    required String propertyType,
  });

  Stream<List<PropertyModel>> watchFilterProperties(RoomFilterCriteria criteria);

  Future<Either<Failure, List<PropertyModel>>> filterProperties(
    RoomFilterCriteria criteria,
  );

}
