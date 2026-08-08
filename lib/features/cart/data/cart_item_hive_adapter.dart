import 'package:hive/hive.dart';
import '../domain/cart_item.dart';

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 1; // must be unique across every Hive adapter in the app

  @override
  CartItem read(BinaryReader reader) {
    // Order here MUST exactly match the order in write() below.
    return CartItem(
      productId: reader.readInt(),
      title: reader.readString(),
      price: reader.readDouble(),
      image: reader.readString(),
      quantity: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer.writeInt(obj.productId);
    writer.writeString(obj.title);
    writer.writeDouble(obj.price);
    writer.writeString(obj.image);
    writer.writeInt(obj.quantity);
  }
}