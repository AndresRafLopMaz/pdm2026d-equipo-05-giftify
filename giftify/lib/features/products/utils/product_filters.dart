import '../../../shared/models/gift_product.dart';
import '../../../shared/models/gift_search_criteria.dart';

/// Lógica local de filtrado y priorización para la Pantalla 4.
///
/// Se mantiene como funciones puras para poder probarla sin depender de
/// widgets ni de un backend. No contiene estado ni lógica de interfaz.

/// Normalización sencilla utilizada únicamente para comparar textos.
String _normalize(String value) => value.trim().toLowerCase();

/// Orden determinista del catálogo general cuando no hay criterios.
///
/// Prioriza la calificación del vendedor, luego el precio y finalmente
/// el id para garantizar un resultado estable entre ejecuciones.
int _compareGeneral(GiftProduct a, GiftProduct b) {
  final byRating = b.sellerRating.compareTo(a.sellerRating);
  if (byRating != 0) {
    return byRating;
  }

  final byPrice = a.price.compareTo(b.price);
  if (byPrice != 0) {
    return byPrice;
  }

  return a.id.compareTo(b.id);
}

/// Indica si el producto podría llegar antes de [GiftSearchCriteria.eventDate].
///
/// Solo se evalúa cuando existen tanto `eventDate` como
/// `estimatedDeliveryDays`.
bool _arrivesOnTime(GiftProduct product, GiftSearchCriteria criteria) {
  final eventDate = criteria.eventDate;
  final deliveryDays = product.estimatedDeliveryDays;

  if (eventDate == null || deliveryDays == null) {
    return false;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
  final estimatedArrival = today.add(Duration(days: deliveryDays));

  return !estimatedArrival.isAfter(eventDay);
}

/// Calcula la puntuación de coincidencia de un producto con los criterios.
///
/// category == giftType                    +2
/// suggestedOccasions contiene occasion    +2
/// size == criteria.size                   +1
/// llega antes de eventDate                +1
int _scoreFor(GiftProduct product, GiftSearchCriteria criteria) {
  var score = 0;

  final giftType = criteria.giftType;
  if (giftType != null &&
      giftType.trim().isNotEmpty &&
      _normalize(product.category) == _normalize(giftType)) {
    score += 2;
  }

  final occasion = criteria.occasion;
  if (occasion.trim().isNotEmpty &&
      product.suggestedOccasions.any(
        (suggested) => _normalize(suggested) == _normalize(occasion),
      )) {
    score += 2;
  }

  final size = criteria.size;
  if (size != null &&
      size.trim().isNotEmpty &&
      _normalize(product.size) == _normalize(size)) {
    score += 1;
  }

  if (_arrivesOnTime(product, criteria)) {
    score += 1;
  }

  return score;
}

/// Devuelve los productos filtrados y priorizados según [criteria].
///
/// Si [criteria] es `null`, devuelve el catálogo completo con un orden
/// determinista. Si existen criterios, excluye los productos cuyo precio
/// supera `maxBudget` y ordena el resto por puntuación de coincidencia.
///
/// El destinatario (`recipient`) no se utiliza para filtrar porque
/// `GiftProduct` no contiene información al respecto.
List<GiftProduct> filterAndPrioritizeProducts(
  Iterable<GiftProduct> products,
  GiftSearchCriteria? criteria,
) {
  final catalog = List<GiftProduct>.from(products);

  if (criteria == null) {
    catalog.sort(_compareGeneral);
    return catalog;
  }

  final withinBudget = catalog
      .where((product) => product.price <= criteria.maxBudget)
      .toList();

  final scored = withinBudget
      .map((product) => (product: product, score: _scoreFor(product, criteria)))
      .toList();

  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) {
      return byScore;
    }

    final byPrice = a.product.price.compareTo(b.product.price);
    if (byPrice != 0) {
      return byPrice;
    }

    return a.product.id.compareTo(b.product.id);
  });

  return scored.map((entry) => entry.product).toList();
}
