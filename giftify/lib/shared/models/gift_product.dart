import '../enums/gift_age_range.dart';
import '../enums/gift_availability.dart';
import '../enums/gift_category.dart';
import '../enums/gift_format.dart';
import '../enums/gift_interest.dart';
import '../enums/gift_occasion.dart';
import '../enums/gift_recipient.dart';
import '../enums/gift_size.dart';

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
    this.occasions = const {},
    this.recipientTypes = const {},
    this.ageRanges = const {},
    this.interests = const {},
    this.giftFormat = GiftFormat.physical,
    this.isPersonalizable = false,
    this.isLocal = false,
    this.estimatedDeliveryDays,
    this.imageAsset,
  });

  /// Identificador único del producto.
  final String id;

  final String name;
  final String description;

  /// Precio expresado en quetzales.
  final double price;

  final GiftCategory category;
  final GiftSize size;
  final GiftAvailability availability;

  /// Nombre del comercio o proveedor.
  final String sellerName;

  /// Calificación del vendedor en escala de 0 a 5.
  final double sellerRating;

  /// Ocasiones para las que normalmente puede recomendarse.
  final Set<GiftOccasion> occasions;

  /// Tipos de destinatario compatibles. Un set vacío es neutral.
  final Set<GiftRecipient> recipientTypes;

  /// Rangos de edad recomendados. Un set vacío es neutral.
  final Set<GiftAgeRange> ageRanges;

  /// Intereses afines al producto.
  final Set<GiftInterest> interests;

  final GiftFormat giftFormat;
  final bool isPersonalizable;
  final bool isLocal;

  /// Tiempo aproximado de entrega.
  final int? estimatedDeliveryDays;

  /// Ruta opcional a una imagen local dentro de assets.
  final String? imageAsset;

  /// Indica si actualmente se puede considerar disponible.
  bool get isAvailable =>
      availability == GiftAvailability.inStock ||
      availability == GiftAvailability.lowStock;
}
