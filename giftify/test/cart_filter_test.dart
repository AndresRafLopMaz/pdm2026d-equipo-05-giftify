import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/cart/data/cart_filter.dart';
import 'package:giftify/features/cart/providers/cart_filter_provider.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

void main() {
  test('CartFilter es inmutable, comparable y permite limpiar categoría', () {
    const initial = CartFilter();
    final filtered = initial.copyWith(category: 'Alimentos');

    expect(initial, const CartFilter());
    expect(initial.isEmpty, isTrue);
    expect(filtered, const CartFilter(category: 'Alimentos'));
    expect(filtered.isEmpty, isFalse);
    expect(filtered.copyWith(clearCategory: true), const CartFilter());
  });

  test('applyCartFilter solo conserva elementos de la categoría', () {
    final items = [
      CartItem(product: mockProducts[0]),
      CartItem(product: mockProducts[1]),
      CartItem(product: mockProducts[5]),
    ];

    final filtered = applyCartFilter(
      items,
      const CartFilter(category: 'Alimentos'),
    );

    expect(filtered.map((item) => item.product.id), [
      mockProducts[1].id,
      mockProducts[5].id,
    ]);
    expect(items, hasLength(3));
  });

  test('sin coincidencias devuelve una lista vacía e inmutable', () {
    final items = [
      CartItem(product: mockProducts[0]),
      CartItem(product: mockProducts[1]),
    ];

    final withoutMatches = applyCartFilter(
      items,
      const CartFilter(category: 'Categoría inexistente'),
    );
    final unfiltered = applyCartFilter(items, const CartFilter());

    expect(withoutMatches, isEmpty);
    expect(unfiltered, hasLength(2));
    expect(
      () => withoutMatches.add(CartItem(product: mockProducts[0])),
      throwsUnsupportedError,
    );
    expect(
      () => unfiltered.add(CartItem(product: mockProducts[0])),
      throwsUnsupportedError,
    );
  });

  test('CartFilterNotifier establece y limpia la categoría', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(cartFilterProvider.notifier)
        .setCategory(mockProducts.first.category);
    expect(
      container.read(cartFilterProvider),
      CartFilter(category: mockProducts.first.category),
    );

    container.read(cartFilterProvider.notifier).clear();
    expect(container.read(cartFilterProvider), const CartFilter());
  });
}
