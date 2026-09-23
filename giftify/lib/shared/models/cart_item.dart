import 'gift_product.dart';

/// Representa un producto agregado al carrito.
class CartItem {
  const CartItem({required this.product, this.quantity = 1})
    : assert(quantity > 0);

  final GiftProduct product;
  final int quantity;

  /// Importe total correspondiente a este elemento.
  double get subtotal => product.price * quantity;

  CartItem copyWith({GiftProduct? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
