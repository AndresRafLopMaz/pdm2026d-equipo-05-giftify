import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/products/data/mock_product_repository.dart';
import 'package:giftify/features/products/data/product_repository.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/gift_product.dart';

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
  });
}
