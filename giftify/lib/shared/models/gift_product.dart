/// Estado de disponibilidad de un producto.
enum GiftAvailability { inStock, lowStock, outOfStock, unknown }

/// Producto que puede ser recomendado dentro de Giftify.
///
/// Es utilizado principalmente por resultados, detalle y carrito.
class GiftProduct {
  const GiftProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.availability,
    required this.sellerName,
    required this.sellerRating,
    this.estimatedDeliveryDays,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String description;

  /// Precio expresado en quetzales.
  final double price;

  final GiftAvailability availability;

  /// Cantidad estimada de días necesarios para entregar el producto.
  final int? estimatedDeliveryDays;

  final String sellerName;

  /// Calificación en una escala de 0 a 5.
  final double sellerRating;

  /// Ruta opcional hacia una imagen local de assets.
  final String? imageAsset;
}
