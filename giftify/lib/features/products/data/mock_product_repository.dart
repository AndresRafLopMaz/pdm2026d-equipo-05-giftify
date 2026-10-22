import '../../../shared/data/mock_products.dart';
import '../../../shared/models/gift_product.dart';
import 'deleted_products_store.dart';
import 'product_repository.dart';

/// Implementación local de [ProductRepository].
///
/// Mantiene el MVP sin backend: devuelve el catálogo de [mockProducts] o una
/// lista configurada, simula latencia y permite provocar un error para probar
/// los estados de la interfaz.
///
/// Los productos eliminados se filtran desde [DeletedProductsStore]. Por
/// defecto usa almacenamiento en memoria; la aplicación inyecta la variante
/// persistente con `shared_preferences`.
class MockProductRepository implements ProductRepository {
  MockProductRepository({
    List<GiftProduct>? products,
    this.delay = const Duration(milliseconds: 350),
    this.error,
    DeletedProductsStore? deletedStore,
  }) : _products = List<GiftProduct>.of(products ?? mockProducts),
       _deletedStore = deletedStore ?? InMemoryDeletedProductsStore();

  final List<GiftProduct> _products;
  final DeletedProductsStore _deletedStore;

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

    final deletedIds = await _deletedStore.load();
    return List<GiftProduct>.unmodifiable(
      _products.where((product) => !deletedIds.contains(product.id)),
    );
  }

  @override
  Future<DeletedProduct> deleteProduct(String id) async {
    final index = _products.indexWhere((product) => product.id == id);

    if (index < 0) {
      throw StateError('No existe el producto $id.');
    }

    await _deletedStore.add(id);
    return DeletedProduct(product: _products[index], index: index);
  }

  @override
  Future<void> restoreProduct(DeletedProduct deletion) async {
    await _deletedStore.remove(deletion.product.id);
  }
}
