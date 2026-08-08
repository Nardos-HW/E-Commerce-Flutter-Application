import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';

@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({
    required int productId,
    required String title,
    required double price,
    required String image,
    required int quantity,
  }) = _CartItem;
}