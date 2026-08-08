import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';

// Bridges Riverpod state changes into something go_router's redirect can listen to.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // Auth status not resolved yet (checking SharedPreferences) — don't redirect mid-flight.
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final isOnLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLoginPage) return '/login';
      if (isLoggedIn && isOnLoginPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const ProductListScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    ],
  );
});