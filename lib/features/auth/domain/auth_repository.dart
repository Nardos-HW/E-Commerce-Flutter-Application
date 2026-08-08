import '../../../core/network/result.dart';
import 'session.dart';

abstract class AuthRepository {
  Future<Result<Session>> login(String username, String password);
  Future<void> logout();
  Future<Session?> getSavedSession();
}