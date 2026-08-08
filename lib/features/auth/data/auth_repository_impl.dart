import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/failure.dart';
import '../../../core/network/result.dart';
import '../domain/auth_repository.dart';
import '../domain/session.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  AuthRepositoryImpl(this.dioClient);

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _usernameKey = 'auth_username';

@override
  Future<Result<Session>> login(String username, String password) async {
    final loginResult = await dioClient.safeCall<String>(
      () => dioClient.dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      }),
      (data) => (data as Map<String, dynamic>)['token'] as String,
    );

    if (loginResult is FailureResult<String>) {
      return FailureResult(loginResult.failure);
    }
    final token = (loginResult as Success<String>).data;

    final usersResult = await dioClient.safeCall<List<dynamic>>(
      () => dioClient.dio.get('/users'),
      (data) => data as List<dynamic>,
    );

    if (usersResult is FailureResult<List<dynamic>>) {
      return FailureResult(usersResult.failure);
    }
    final users = (usersResult as Success<List<dynamic>>).data;

    final match = users.firstWhere(
      (u) => u['username'] == username,
      orElse: () => null,
    );
    if (match == null) return FailureResult(UnknownFailure());

    final session = Session(token: token, userId: match['id'] as int, username: username);
    await _saveSession(session);
    return Success(session);
  }

  Future<void> _saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setInt(_userIdKey, session.userId);
    await prefs.setString(_usernameKey, session.username);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  @override
  Future<Session?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getInt(_userIdKey);
    final username = prefs.getString(_usernameKey);
    if (token == null || userId == null || username == null) return null;
    return Session(token: token, userId: userId, username: username);
  }
}