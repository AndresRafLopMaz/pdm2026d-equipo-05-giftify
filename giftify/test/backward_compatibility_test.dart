import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/products/data/deleted_products_store.dart';
import 'package:giftify/features/products/data/mock_product_repository.dart';
import 'package:giftify/shared/data/mock_products.dart';

void main() {
  test(
    'el carrito persistido resuelve IDs existentes tras ampliar el catálogo',
    () async {
      final store = InMemoryCartStore([
        CartEntry(productId: 'gift-001', quantity: 2),
        CartEntry(productId: 'gift-006', quantity: 1),
      ]);
      final repository = PersistentCartRepository(store: store);

      final items = await repository.loadItems();

      expect(items, hasLength(2));
      expect(items[0].product.id, 'gift-001');
      expect(items[0].product.name, 'Pulsera artesanal');
      expect(items[0].quantity, 2);
      expect(items[1].product.id, 'gift-006');
      expect(items[1].product.name, 'Set de café guatemalteco');
      expect(items[1].quantity, 1);
    },
  );

  test('los IDs eliminados y restaurados siguen resolviendo', () async {
    final deletedStore = InMemoryDeletedProductsStore();
    await deletedStore.add('gift-006');

    final repository = MockProductRepository(
      deletedStore: deletedStore,
      delay: Duration.zero,
    );

    final withoutDeleted = await repository.fetchProducts();
    expect(withoutDeleted.any((product) => product.id == 'gift-006'), isFalse);
    expect(withoutDeleted, hasLength(mockProducts.length - 1));

    final deletion = await repository.deleteProduct('gift-001');
    await repository.restoreProduct(deletion);

    final restored = await repository.fetchProducts();
    expect(restored.any((product) => product.id == 'gift-001'), isTrue);
    expect(restored.any((product) => product.id == 'gift-006'), isFalse);
  });
}
