import 'package:giftify/features/products/data/product_repository.dart';
import 'package:giftify/shared/models/gift_product.dart';

/// Repositorio falso para pruebas de widget.
///
/// Permite controlar de forma determinista si devuelve datos, una lista vacía,
/// falla siempre o falla una sola vez antes de responder correctamente.
class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    List<GiftProduct>? products,
    this.error,
    this.failures = 0,
    this.delay = Duration.zero,
    this.deleteError,
  }) : products = List<GiftProduct>.of(products ?? const []),
       _deletedIds = <String>{};

  factory FakeProductRepository.success(
    List<GiftProduct> products, {
    Object? deleteError,
  }) {
    return FakeProductRepository(products: products, deleteError: deleteError);
  }

  factory FakeProductRepository.empty() {
    return FakeProductRepository(products: const []);
  }

  factory FakeProductRepository.error([Object? error]) {
    return FakeProductRepository(
      error: error ?? Exception('fallo simulado'),
      failures: -1,
    );
  }

  factory FakeProductRepository.failOnceThenSuccess(
    List<GiftProduct> products, {
    Object? error,
  }) {
    return FakeProductRepository(
      products: products,
      error: error ?? Exception('fallo simulado'),
      failures: 1,
    );
  }

  final List<GiftProduct> products;
  final Object? error;

  /// Cantidad de llamadas que deben fallar antes de devolver [products].
  ///
  /// `0` significa que no falla; un valor negativo significa que falla siempre.
  final int failures;

  final Duration delay;

  /// Error opcional que se lanzará al intentar eliminar un producto.
  final Object? deleteError;

  final Set<String> _deletedIds;

  /// Número de veces que se ejecutó [fetchProducts].
  int calls = 0;

  /// Número de veces que se intentó eliminar un producto.
  int deleteCalls = 0;

  @override
  Future<List<GiftProduct>> fetchProducts() async {
    calls++;

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final failure = error;
    final shouldFail = failure != null && (failures < 0 || calls <= failures);

    if (shouldFail) {
      throw failure;
    }

    return List<GiftProduct>.unmodifiable(
      products.where((product) => !_deletedIds.contains(product.id)),
    );
  }

  @override
  Future<DeletedProduct> deleteProduct(String id) async {
    deleteCalls++;

    if (deleteError != null) {
      throw deleteError!;
    }

    final index = products.indexWhere((product) => product.id == id);

    if (index < 0) {
      throw StateError('No existe el producto $id.');
    }

    _deletedIds.add(id);
    return DeletedProduct(product: products[index], index: index);
  }

  @override
  Future<void> restoreProduct(DeletedProduct deletion) async {
    _deletedIds.remove(deletion.product.id);
  }
}
