import 'package:hive/hive.dart';
import '../domain/cart_item.dart';
import '../domain/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Box<CartItem> box;
  CartRepositoryImpl(this.box);

  @override
  List<CartItem> getCart() => box.values.toList();

  @override
  Future<void> saveCart(List<CartItem> items) async {
    await box.clear();
    await box.addAll(items);
  }

  @override
  Future<void> clearCart() async => box.clear();
}