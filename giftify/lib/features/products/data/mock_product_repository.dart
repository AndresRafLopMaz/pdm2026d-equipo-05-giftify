import '../../../shared/data/mock_products.dart';
import '../../../shared/models/gift_product.dart';
import 'product_repository.dart';

/// Implementación local de [ProductRepository].
///
/// Mantiene el MVP sin backend: devuelve el catálogo de [mockProducts] o una
/// lista configurada, simula latencia y permite provocar un error para probar
/// los estados de la interfaz.
class MockProductRepository implements ProductRepository {
  MockProductRepository({
    this.products = mockProducts,
    this.delay = const Duration(milliseconds: 350),
    this.error,
  });

  /// Productos que devolverá la consulta.
  final List<GiftProduct> products;

  /// Latencia simulada antes de responder.
  final Duration delay;

  /// Error opcional que se lanzará en lugar de devolver productos.
  final Object? error;

  @override
  Future<List<GiftProduct>> fetchProducts() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final failure = error;
    if (failure != null) {
      throw failure;
    }

    return List<GiftProduct>.unmodifiable(products);
  }
}
