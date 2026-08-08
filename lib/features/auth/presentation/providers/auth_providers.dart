import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../../domain/session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = DioClient(); // reuse products' dioClientProvider if you already have one in scope
  return AuthRepositoryImpl(dioClient);
});

class AuthNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    return ref.read(authRepositoryProvider).getSavedSession();
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(username, password);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (session) {
        state = AsyncData(session);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Session?>(AuthNotifier.new);