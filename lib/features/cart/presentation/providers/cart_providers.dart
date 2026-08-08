import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../products/domain/product.dart';
import '../../data/cart_repository_impl.dart';
import '../../domain/cart_item.dart';
import '../../domain/cart_repository.dart';

// Overridden in main() with the real opened Box — see Step 6.6.
final cartBoxProvider = Provider<Box<CartItem>>((ref) {
  throw UnimplementedError('cartBoxProvider must be overridden in main()');
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartBoxProvider));
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    // Box is already open by the time the app starts (see main.dart),
    // so this read is synchronous — no loading state needed for cart.
    return ref.read(cartRepositoryProvider).getCart();
  }

  void addProduct(Product product, {int quantity = 1}) {
    final index = state.indexWhere((item) => item.productId == product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + quantity,
      );
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(
          productId: product.id,
          title: product.title,
          price: product.price,
          image: product.image,
          quantity: quantity,
        ),
      ];
    }
    _persist();
  }

  void incrementQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.productId == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
    _persist();
  }

  void decrementQuantity(int productId) {
    final item = state.firstWhere((i) => i.productId == productId);
    if (item.quantity <= 1) {
      removeProduct(productId); // never go below 1 — remove instead
      return;
    }
    state = [
      for (final i in state)
        if (i.productId == productId) i.copyWith(quantity: i.quantity - 1) else i,
    ];
    _persist();
  }

  void removeProduct(int productId) {
    state = state.where((item) => item.productId != productId).toList();
    _persist();
  }

  void clear() {
    state = [];
    ref.read(cartRepositoryProvider).clearCart();
  }

  void _persist() {
    ref.read(cartRepositoryProvider).saveCart(state);
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.price * item.quantity);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});