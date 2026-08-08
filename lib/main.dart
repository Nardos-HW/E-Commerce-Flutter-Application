import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/routing/app_router.dart';
import 'features/cart/data/cart_item_hive_adapter.dart';
import 'features/cart/domain/cart_item.dart';
import 'features/cart/presentation/providers/cart_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());
  final cartBox = await Hive.openBox<CartItem>('cartBox');

  runApp(
    ProviderScope(
      overrides: [cartBoxProvider.overrideWithValue(cartBox)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce',
      routerConfig: router,
    );
  }
}