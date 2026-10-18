import '../../../shared/models/gift_product.dart';

/// Fuente de productos de Giftify.
///
/// La interfaz desacopla la UI de la implementación concreta (mock local,
/// backend remoto o un fake de pruebas). No conoce HTTP, JSON ni widgets.
abstract class ProductRepository {
  Future<List<GiftProduct>> fetchProducts();
}
