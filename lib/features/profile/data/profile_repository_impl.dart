import '../../../core/network/dio_client.dart';
import '../../../core/network/result.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient dioClient;
  ProfileRepositoryImpl(this.dioClient);

  @override
  Future<Result<UserProfile>> getUserProfile(int userId) {
    return dioClient.safeCall<UserProfile>(
      () => dioClient.dio.get('/users/$userId'),
      (data) => UserProfile.fromJson(data as Map<String, dynamic>),
    );
  }
}