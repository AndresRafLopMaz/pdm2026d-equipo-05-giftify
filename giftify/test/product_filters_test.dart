import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/products/utils/product_filters.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_availability.dart';
import 'package:giftify/shared/enums/gift_category.dart';
import 'package:giftify/shared/enums/gift_occasion.dart';
import 'package:giftify/shared/enums/gift_size.dart';
import 'package:giftify/shared/models/gift_product.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

GiftProduct _product({
  required String id,
  double price = 100,
  GiftCategory category = GiftCategory.jewelry,
  GiftSize size = GiftSize.small,
  Set<GiftOccasion> occasions = const {GiftOccasion.birthday},
  int? estimatedDeliveryDays,
}) {
  return GiftProduct(
    id: id,
    name: 'Producto $id',
    description: 'Descripción de prueba',
    price: price,
    category: category,
    size: size,
    availability: GiftAvailability.inStock,
    sellerName: 'Vendedor',
    sellerRating: 4.5,
    occasions: occasions,
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
        occasion: 'Cumpleaños',
        recipient: 'Amigo',
        maxBudget: 200,
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(_ids(result), ['barato']);
    });

    test('prioriza la coincidencia de categoría con giftType', () {
      final products = [
        _product(id: 'otro', category: GiftCategory.food, occasions: const {}),
        _product(
          id: 'coincide',
          category: GiftCategory.jewelry,
          occasions: const {},
        ),
      ];

      const criteria = GiftSearchCriteria(
        occasion: 'Cumpleaños',
        recipient: 'Amiga',
        maxBudget: 1000,
        giftType: 'Joyería',
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'coincide');
    });

    test('prioriza la coincidencia dentro de occasions', () {
      final products = [
        _product(id: 'otro', occasions: const {GiftOccasion.thankYou}),
        _product(id: 'coincide', occasions: const {GiftOccasion.anniversary}),
      ];

      const criteria = GiftSearchCriteria(
        occasion: 'Aniversario',
        recipient: 'Pareja',
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
        occasion: 'Cumpleaños',
        recipient: 'Amigo',
        maxBudget: 1000,
        size: 'Mediano',
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'mediano');
    });

    test('con criteria null devuelve el catálogo completo y ordenado', () {
      final result = filterAndPrioritizeProducts(mockProducts, null);

      expect(result.length, mockProducts.length);
      // Orden determinista: primero la mejor calificación (4.8, gift-004).
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
        occasion: 'Cumpleaños',
        recipient: 'Amigo',
        maxBudget: 1000,
        eventDate: DateTime.now().add(const Duration(days: 5)),
      );

      final result = filterAndPrioritizeProducts(products, criteria);

      expect(result.first.id, 'a_tiempo');
    });

    test('el destinatario no altera el resultado', () {
      final products = mockProducts;

      const forFriend = GiftSearchCriteria(
        occasion: 'Cumpleaños',
        recipient: 'Amigo',
        maxBudget: 500,
      );
      const forMother = GiftSearchCriteria(
        occasion: 'Cumpleaños',
        recipient: 'Madre',
        maxBudget: 500,
      );

      final friendResult = filterAndPrioritizeProducts(products, forFriend);
      final motherResult = filterAndPrioritizeProducts(products, forMother);

      expect(_ids(friendResult), _ids(motherResult));
    });

    test('devuelve una lista vacía cuando nada cumple el presupuesto', () {
      const criteria = GiftSearchCriteria(
        occasion: 'Cumpleaños',
        recipient: 'Amigo',
        maxBudget: 10,
      );

      final result = filterAndPrioritizeProducts(mockProducts, criteria);

      expect(result, isEmpty);
    });
  });
}
