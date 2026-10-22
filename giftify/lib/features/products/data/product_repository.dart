import '../../../shared/models/gift_product.dart';

/// Producto eliminado junto con su posición original.
class DeletedProduct {
  const DeletedProduct({required this.product, required this.index});

  final GiftProduct product;
  final int index;
}

/// Fuente de productos de Giftify.
///
/// La interfaz desacopla la UI de la implementación concreta (mock local,
/// backend remoto o un fake de pruebas). No conoce HTTP, JSON ni widgets.
abstract class ProductRepository {
  Future<List<GiftProduct>> fetchProducts();

  /// Elimina el producto de la persistencia y devuelve sus datos y posición.
  Future<DeletedProduct> deleteProduct(String id);

  /// Restaura el producto eliminado, conservando su identidad.
  Future<void> restoreProduct(DeletedProduct deletion);
}
