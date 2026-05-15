import '../../../../auth/data/models/user.dart';

abstract class LandlordProfileRemoteDataSource {
  Future<UserModel?> fetchProfileForLandlord(String landlordId);
}
