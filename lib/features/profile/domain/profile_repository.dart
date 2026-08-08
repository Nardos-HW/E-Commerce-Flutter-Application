import '../../../core/network/result.dart';
import 'user_profile.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getUserProfile(int userId);
}