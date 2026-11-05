import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/products/utils/product_filters.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_age_range.dart';
import 'package:giftify/shared/enums/gift_availability.dart';
import 'package:giftify/shared/enums/gift_category.dart';
import 'package:giftify/shared/enums/gift_format.dart';
import 'package:giftify/shared/enums/gift_interest.dart';
import 'package:giftify/shared/enums/gift_occasion.dart';
import 'package:giftify/shared/enums/gift_recipient.dart';
import 'package:giftify/shared/enums/gift_size.dart';
import 'package:giftify/shared/models/gift_product.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

GiftProduct _product({
  required String id,
  double price = 100,
  GiftCategory category = GiftCategory.jewelry,
  GiftSize size = GiftSize.small,
  GiftFormat giftFormat = GiftFormat.physical,
  Set<GiftOccasion> occasions = const {GiftOccasion.birthday},
  Set<GiftRecipient> recipientTypes = const {GiftRecipient.friend},
  Set<GiftAgeRange> ageRanges = const {GiftAgeRange.adult},
  Set<GiftInterest> interests = const {},
  GiftAvailability availability = GiftAvailability.inStock,
  bool isPersonalizable = false,
  bool isLocal = false,
  int? estimatedDeliveryDays,
}) {
  return GiftProduct(
    id: id,
    name: 'Producto $id',
    description: 'Descripción de prueba',
    price: price,
    category: category,
    size: size,
    availability: availability,
    sellerName: 'Vendedor',
    sellerRating: 4.5,
    occasions: occasions,
    recipientTypes: recipientTypes,
    ageRanges: ageRanges,
    interests: interests,
    giftFormat: giftFormat,
    isPersonalizable: isPersonalizable,
    isLocal: isLocal,
    estimatedDeliveryDays: estimatedDeliveryDays,
  );
}

List<String> _ids(List<GiftProduct> products) =>
    products.map((product) => product.id).toList();

void main() {
  group('filterAndPrioritizeProducts', () {
    test('excluye productos cuyo precio supera el presupuesto', () {
      final products = [
        _product(id: 'barato', price: 100),
        _product(id: 'caro', price: 500),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 200,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(_ids(result), ['barato']);
    });

    test('prioriza la coincidencia de formato', () {
      final products = [
        _product(id: 'fisico'),
        _product(id: 'experiencia', giftFormat: GiftFormat.experience),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
        giftFormat: GiftFormat.experience,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'experiencia');
    });

    test('prioriza la coincidencia de ocasión', () {
      final products = [
        _product(id: 'otro', occasions: const {GiftOccasion.thankYou}),
        _product(id: 'coincide', occasions: const {GiftOccasion.anniversary}),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.anniversary,
        recipientType: GiftRecipient.partner,
        maxBudget: 1000,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'coincide');
    });

    test('prioriza la coincidencia de tamaño', () {
      final products = [
        _product(id: 'pequeno', size: GiftSize.small),
        _product(id: 'mediano', size: GiftSize.medium),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
        size: GiftSize.medium,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'mediano');
    });

    test('con criteria null devuelve el catálogo completo y ordenado', () {
      final result = filterAndPrioritizeProducts(mockProducts, null);

      expect(result.length, mockProducts.length);
      expect(result.first.id, 'gift-004');

      final second = filterAndPrioritizeProducts(mockProducts, null);
      expect(_ids(result), _ids(second));
    });

    test('prioriza el producto que llega antes de eventDate', () {
      final products = [
        _product(id: 'tarde', occasions: const {}, estimatedDeliveryDays: 10),
        _product(id: 'a_tiempo', occasions: const {}, estimatedDeliveryDays: 2),
      ];

      final criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
        eventDate: DateTime(2026, 1, 6),
      );

      final result = filterAndPrioritizeProducts(
        products,
        criteria,
        now: DateTime(2026, 1, 1),
      );

      expect(_ids(result), ['a_tiempo']);
    });

    test('prioriza la coincidencia de destinatario', () {
      final products = [
        _product(id: 'amigo', recipientTypes: const {GiftRecipient.friend}),
        _product(id: 'pareja', recipientTypes: const {GiftRecipient.partner}),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.partner,
        maxBudget: 1000,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'pareja');
    });

    test('limita a +4 el score por intereses', () {
      final products = [
        _product(
          id: 'muchos',
          interests: const {
            GiftInterest.technology,
            GiftInterest.gaming,
            GiftInterest.music,
          },
        ),
        _product(
          id: 'local',
          interests: const {GiftInterest.technology, GiftInterest.gaming},
          isLocal: true,
        ),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
        interests: {
          GiftInterest.technology,
          GiftInterest.gaming,
          GiftInterest.music,
        },
        isLocal: true,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'local');
    });

    test('onlyAvailable excluye productos agotados', () {
      final products = [
        _product(id: 'disponible'),
        _product(id: 'agotado', availability: GiftAvailability.outOfStock),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
        onlyAvailable: true,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(_ids(result), ['disponible']);
    });

    test('prioriza entrega rápida, local y personalizable', () {
      final products = [
        _product(id: 'normal', estimatedDeliveryDays: 5),
        _product(
          id: 'preferido',
          estimatedDeliveryDays: 2,
          isLocal: true,
          isPersonalizable: true,
        ),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
        fastDelivery: true,
        isLocal: true,
        isPersonalizable: true,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'preferido');
    });

    test('prioriza el rango de edad compatible', () {
      final products = [
        _product(id: 'mayor', ageRanges: const {GiftAgeRange.senior}),
        _product(id: 'adulto', ageRanges: const {GiftAgeRange.adult}),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
        ageRange: GiftAgeRange.adult,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'adulto');
    });

    test('usa precio e id como tie breakers', () {
      final products = [
        _product(id: 'b', price: 100),
        _product(id: 'a', price: 100),
      ];

      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 1000,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(_ids(result), ['a', 'b']);
    });

    test('devuelve una lista vacía cuando nada cumple el presupuesto', () {
      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 10,
      );

      final result = filterAndPrioritizeProducts(mockProducts, criteria);

      expect(result, isEmpty);
    });
  });
}
