import '../../../shared/models/gift_product.dart';
import '../../../shared/models/gift_search_criteria.dart';

/// Lógica local de filtrado y priorización para Results.
///
/// Se mantiene como funciones puras para poder probarla sin depender de
/// widgets ni de un backend. No contiene estado ni lógica de interfaz.

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

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _arrivesOnTime(GiftProduct product, DateTime eventDate, DateTime today) {
  final deliveryDays = product.estimatedDeliveryDays;
  if (deliveryDays == null) {
    return false;
  }

  final estimatedArrival = today.add(Duration(days: deliveryDays));
  return !estimatedArrival.isAfter(eventDate);
}

int _scoreFor(GiftProduct product, GiftSearchCriteria criteria) {
  var score = 0;

  if (product.recipientTypes.isNotEmpty &&
      product.recipientTypes.contains(criteria.recipientType)) {
    score += 4;
  }

  if (product.occasions.contains(criteria.occasion)) {
    score += 3;
  }

  final interestMatches = product.interests
      .where(criteria.interests.contains)
      .length;
  score += (interestMatches * 2).clamp(0, 4);

  final ageRange = criteria.ageRange;
  if (ageRange != null &&
      product.ageRanges.isNotEmpty &&
      product.ageRanges.contains(ageRange)) {
    score += 2;
  }

  final giftFormat = criteria.giftFormat;
  if (giftFormat != null && product.giftFormat == giftFormat) {
    score += 2;
  }

  final size = criteria.size;
  if (size != null && product.size == size) {
    score += 1;
  }

  if (criteria.isPersonalizable && product.isPersonalizable) {
    score += 1;
  }

  if (criteria.isLocal && product.isLocal) {
    score += 1;
  }

  final deliveryDays = product.estimatedDeliveryDays;
  if (criteria.fastDelivery && deliveryDays != null && deliveryDays <= 2) {
    score += 1;
  }

  return score;
}

/// Devuelve los productos filtrados y priorizados según [criteria].
///
/// `now` permite inyectar una fecha fija en pruebas. Si se omite, usa la
/// fecha actual.
List<GiftProduct> filterAndPrioritizeProducts(
  Iterable<GiftProduct> products,
  GiftSearchCriteria? criteria, {
  DateTime? now,
}) {
  final catalog = List<GiftProduct>.from(products);

  if (criteria == null) {
    catalog.sort(_compareGeneral);
    return catalog;
  }

  final today = _dateOnly(now ?? DateTime.now());
  final eventDate = criteria.eventDate == null
      ? null
      : _dateOnly(criteria.eventDate!);

  final filtered = catalog.where((product) {
    if (product.price > criteria.maxBudget) {
      return false;
    }

    if (criteria.onlyAvailable && !product.isAvailable) {
      return false;
    }

    if (eventDate != null && !_arrivesOnTime(product, eventDate, today)) {
      return false;
    }

    return true;
  }).toList();

  final scored = filtered
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
