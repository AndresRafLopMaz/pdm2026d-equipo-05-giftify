import '../../../shared/models/cart_item.dart';

/// Elemento eliminado junto con su posición original.
class RemovedCartItem {
  const RemovedCartItem({required this.item, required this.index});

  final CartItem item;
  final int index;
}

/// Fuente persistente de los elementos del carrito.
abstract class CartRepository {
  Future<List<CartItem>> loadItems();

  Future<List<CartItem>> addItems(List<CartItem> incoming);

  Future<CartItem> updateQuantity(String productId, int quantity);

  Future<RemovedCartItem> removeItem(String productId);

  Future<void> restoreItem(RemovedCartItem removed);
}
