import 'package:flutter/foundation.dart';

import '../../../shared/enums/gift_availability.dart';
import '../../../shared/models/gift_product.dart';

/// Filtro adicional aplicado al catálogo de productos.
///
/// Es independiente de `GiftSearchCriteria`: los criterios representan la
/// búsqueda personalizada y este filtro refina el listado visible.
@immutable
class ProductFilter {
  const ProductFilter({this.category, this.availability});

  final String? category;
  final GiftAvailability? availability;

  bool get isEmpty => category == null && availability == null;

  ProductFilter copyWith({
    String? category,
    GiftAvailability? availability,
    bool clearCategory = false,
    bool clearAvailability = false,
  }) {
    return ProductFilter(
      category: clearCategory ? null : (category ?? this.category),
      availability: clearAvailability
          ? null
          : (availability ?? this.availability),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductFilter &&
            other.category == category &&
            other.availability == availability;
  }

  @override
  int get hashCode => Object.hash(category, availability);
}

/// Aplica el filtro a una colección de productos.
List<GiftProduct> applyProductFilter(
  Iterable<GiftProduct> products,
  ProductFilter filter,
) {
  return products
      .where((product) {
        if (filter.category != null && product.category != filter.category) {
          return false;
        }

        if (filter.availability != null &&
            product.availability != filter.availability) {
          return false;
        }

        return true;
      })
      .toList(growable: false);
}
