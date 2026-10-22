import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/products/data/deleted_products_store.dart';
import 'package:giftify/features/products/data/mock_product_repository.dart';
import 'package:giftify/features/products/data/product_repository.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/gift_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MockProductRepository', () {
    test(
      'devuelve el catálogo por defecto como Future<List<GiftProduct>>',
      () async {
        final ProductRepository repository = MockProductRepository(
          delay: Duration.zero,
        );

        final Future<List<GiftProduct>> future = repository.fetchProducts();

        expect(future, isA<Future<List<GiftProduct>>>());

        final products = await future;

        expect(products, isNotEmpty);
        expect(products.length, mockProducts.length);
        expect(products.first.id, mockProducts.first.id);
      },
    );

    test('devuelve la lista de productos configurada', () async {
      final expected = mockProducts.take(2).toList();
      final repository = MockProductRepository(
        products: expected,
        delay: Duration.zero,
      );

      final products = await repository.fetchProducts();

      expect(products.length, 2);
      expect(products.map((product) => product.id), [
        expected[0].id,
        expected[1].id,
      ]);
    });

    test('devuelve una lista vacía cuando se configura así', () async {
      final repository = MockProductRepository(
        products: const [],
        delay: Duration.zero,
      );

      final products = await repository.fetchProducts();

      expect(products, isEmpty);
    });

    test('lanza el error configurado en lugar de devolver productos', () async {
      final repository = MockProductRepository(
        delay: Duration.zero,
        error: Exception('fallo simulado'),
      );

      await expectLater(repository.fetchProducts(), throwsA(isA<Exception>()));
    });

    test('elimina y restaura el producto conservando id y posición', () async {
      final repository = MockProductRepository(delay: Duration.zero);
      final before = await repository.fetchProducts();
      final target = before.first;
      final originalIndex = before.indexWhere(
        (product) => product.id == target.id,
      );

      final deletion = await repository.deleteProduct(target.id);

      expect(deletion.product.id, target.id);
      expect(deletion.index, originalIndex);
      expect(
        (await repository.fetchProducts()).any(
          (product) => product.id == target.id,
        ),
        isFalse,
      );

      await repository.restoreProduct(deletion);

      final restored = await repository.fetchProducts();
      expect(restored.any((product) => product.id == target.id), isTrue);
    });

    test('la eliminación persiste entre instancias del repositorio', () async {
      final store = InMemoryDeletedProductsStore();
      final repository1 = MockProductRepository(
        deletedStore: store,
        delay: Duration.zero,
      );
      final target = (await repository1.fetchProducts()).first;

      await repository1.deleteProduct(target.id);

      final repository2 = MockProductRepository(
        deletedStore: store,
        delay: Duration.zero,
      );
      expect(
        (await repository2.fetchProducts()).any(
          (product) => product.id == target.id,
        ),
        isFalse,
      );

      final deletion = DeletedProduct(product: target, index: 0);
      await repository2.restoreProduct(deletion);

      final repository3 = MockProductRepository(
        deletedStore: store,
        delay: Duration.zero,
      );
      expect(
        (await repository3.fetchProducts()).any(
          (product) => product.id == target.id,
        ),
        isTrue,
      );
    });

    test('SharedPreferences conserva eliminados y restauraciones', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final store = SharedPreferencesDeletedProductsStore();
      final repository1 = MockProductRepository(
        deletedStore: store,
        delay: Duration.zero,
      );
      final target = (await repository1.fetchProducts()).first;
      final deletion = await repository1.deleteProduct(target.id);

      final repository2 = MockProductRepository(
        deletedStore: store,
        delay: Duration.zero,
      );
      expect(
        (await repository2.fetchProducts()).any(
          (product) => product.id == target.id,
        ),
        isFalse,
      );

      await repository2.restoreProduct(deletion);

      final repository3 = MockProductRepository(
        deletedStore: store,
        delay: Duration.zero,
      );
      expect(
        (await repository3.fetchProducts()).any(
          (product) => product.id == target.id,
        ),
        isTrue,
      );
    });
  });
}
