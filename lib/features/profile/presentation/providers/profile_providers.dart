import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/profile_repository_impl.dart';
import '../../domain/profile_repository.dart';
import '../../domain/user_profile.dart';
import '../../../products/presentation/providers/product_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(dioClientProvider));
});

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) {
    throw StateError('No active session — profile requested while logged out.');
  }
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getUserProfile(session.userId);
  return result.fold((f) => throw f, (profile) => profile);
});