import '../enums/gift_availability.dart';

/// Producto recomendado por Giftify.
///
/// Este modelo es compartido por resultados, detalle y carrito.
/// No pertenece exclusivamente a ninguna pantalla.
class GiftProduct {
  const GiftProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.size,
    required this.availability,
    required this.sellerName,
    required this.sellerRating,
    required this.suggestedOccasions,
    this.estimatedDeliveryDays,
    this.imageAsset,
  });

  /// Identificador único del producto.
  final String id;

  final String name;
  final String description;

  /// Precio expresado en quetzales.
  final double price;

  /// Categoría general del producto.
  final String category;

  /// Tamaño utilizado por el filtrado inicial.
  final String size;

  final GiftAvailability availability;

  /// Nombre del comercio o proveedor.
  final String sellerName;

  /// Calificación del vendedor en escala de 0 a 5.
  final double sellerRating;

  /// Ocasiones para las que normalmente puede recomendarse.
  final List<String> suggestedOccasions;

  /// Tiempo aproximado de entrega.
  final int? estimatedDeliveryDays;

  /// Ruta opcional a una imagen local dentro de assets.
  final String? imageAsset;

  /// Indica si actualmente se puede considerar disponible.
  bool get isAvailable =>
      availability == GiftAvailability.inStock ||
      availability == GiftAvailability.lowStock;
}
