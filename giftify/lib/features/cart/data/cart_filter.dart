import '../../../shared/models/cart_item.dart';

/// Filtro inmutable aplicado únicamente a la lista visible del carrito.
class CartFilter {
  const CartFilter({this.category});

  final String? category;

  bool get isEmpty => category == null;

  CartFilter copyWith({String? category, bool clearCategory = false}) {
    return CartFilter(
      category: clearCategory ? null : category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartFilter && other.category == category;

  @override
  int get hashCode => category.hashCode;
}

List<CartItem> applyCartFilter(Iterable<CartItem> items, CartFilter filter) {
  final category = filter.category;
  if (category == null) {
    return List<CartItem>.unmodifiable(items);
  }

  return List<CartItem>.unmodifiable(
    items.where((item) => item.product.category == category),
  );
}
