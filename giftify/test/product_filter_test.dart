import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/products/data/product_filter.dart';
import 'package:giftify/features/products/providers/product_filter_provider.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_availability.dart';

void main() {
  test('ProductFilter es inmutable y compara por valor', () {
    const filter = ProductFilter(category: 'Joyería');
    final copy = filter.copyWith(availability: GiftAvailability.inStock);

    expect(filter.category, 'Joyería');
    expect(filter.availability, isNull);
    expect(copy.category, 'Joyería');
    expect(copy.availability, GiftAvailability.inStock);
    expect(copy, isNot(filter));

    final cleared = copy.copyWith(clearCategory: true);
    expect(cleared.category, isNull);
    expect(cleared.isEmpty, isFalse);

    expect(cleared.copyWith(clearAvailability: true).isEmpty, isTrue);
  });

  test('applyProductFilter filtra por categoría y disponibilidad', () {
    final byCategory = applyProductFilter(
      mockProducts,
      const ProductFilter(category: 'Joyería'),
    );
    expect(byCategory, isNotEmpty);
    expect(
      byCategory.every((product) => product.category == 'Joyería'),
      isTrue,
    );

    final byAvailability = applyProductFilter(
      mockProducts,
      const ProductFilter(availability: GiftAvailability.outOfStock),
    );
    expect(byAvailability, isNotEmpty);
    expect(
      byAvailability.every(
        (product) => product.availability == GiftAvailability.outOfStock,
      ),
      isTrue,
    );

    final empty = applyProductFilter(
      mockProducts,
      const ProductFilter(
        category: 'Joyería',
        availability: GiftAvailability.outOfStock,
      ),
    );
    expect(empty, isEmpty);
  });

  test('ProductFilterNotifier actualiza y limpia el filtro', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(productFilterProvider), const ProductFilter());

    container.read(productFilterProvider.notifier).setCategory('Joyería');
    expect(container.read(productFilterProvider).category, 'Joyería');

    container
        .read(productFilterProvider.notifier)
        .setAvailability(GiftAvailability.inStock);
    expect(
      container.read(productFilterProvider).availability,
      GiftAvailability.inStock,
    );

    container.read(productFilterProvider.notifier).clear();
    expect(container.read(productFilterProvider), const ProductFilter());
  });
}
