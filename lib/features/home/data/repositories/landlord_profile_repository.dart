import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../auth/data/models/user.dart';

abstract class LandlordProfileRepository {
  Future<Either<Failure, UserModel>> getLandlordProfile(String landlordId);
}
