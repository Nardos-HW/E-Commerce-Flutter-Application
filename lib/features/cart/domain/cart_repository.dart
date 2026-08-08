import 'cart_item.dart';

abstract class CartRepository {
  List<CartItem> getCart();
  Future<void> saveCart(List<CartItem> items);
  Future<void> clearCart();
}