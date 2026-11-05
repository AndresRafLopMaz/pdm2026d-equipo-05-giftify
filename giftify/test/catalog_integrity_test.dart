import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_availability.dart';
import 'package:giftify/shared/enums/gift_category.dart';
import 'package:giftify/shared/enums/gift_format.dart';

void main() {
  group('integridad del catálogo', () {
    test('contiene 36 productos con IDs únicos y estables', () {
      expect(mockProducts, hasLength(36));

      final ids = mockProducts.map((product) => product.id).toList();
      expect(ids.toSet(), hasLength(36));

      for (var index = 1; index <= 36; index++) {
        expect(ids, contains('gift-${index.toString().padLeft(3, '0')}'));
      }
    });

    test('conserva nombre y precio de gift-001 a gift-006', () {
      const expected = {
        'gift-001': ('Pulsera artesanal', 125.00),
        'gift-002': ('Caja de chocolates artesanales', 95.00),
        'gift-003': ('Taza térmica', 180.00),
        'gift-004': ('Bolsa típica con productos guatemaltecos', 210.00),
        'gift-005': ('Marco fotográfico personalizado', 160.00),
        'gift-006': ('Set de café guatemalteco', 145.00),
      };

      for (final entry in expected.entries) {
        final product = mockProducts.firstWhere(
          (product) => product.id == entry.key,
        );
        expect(product.name, entry.value.$1);
        expect(product.price, entry.value.$2);
      }
    });

    test('respeta la distribución de categorías', () {
      final counts = <GiftCategory, int>{};
      for (final product in mockProducts) {
        counts.update(
          product.category,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      expect(counts, {
        GiftCategory.technology: 5,
        GiftCategory.jewelry: 4,
        GiftCategory.food: 4,
        GiftCategory.accessories: 4,
        GiftCategory.home: 4,
        GiftCategory.books: 3,
        GiftCategory.gaming: 3,
        GiftCategory.beauty: 3,
        GiftCategory.crafts: 3,
        GiftCategory.experiences: 3,
      });
    });

    test('tiene datos numéricos y metadata válidos', () {
      for (final product in mockProducts) {
        expect(product.price, greaterThan(0), reason: product.id);
        expect(
          product.sellerRating,
          inInclusiveRange(0, 5),
          reason: product.id,
        );
        expect(product.sellerName.trim(), isNotEmpty, reason: product.id);
        expect(product.estimatedDeliveryDays, isNotNull, reason: product.id);
        expect(
          product.estimatedDeliveryDays,
          inInclusiveRange(1, 10),
          reason: product.id,
        );
        expect(product.recipientTypes, isNotEmpty, reason: product.id);
        expect(product.ageRanges, isNotEmpty, reason: product.id);
        expect(product.interests, isNotEmpty, reason: product.id);
        expect(product.occasions, isNotEmpty, reason: product.id);
        expect(
          product.imageAsset == null || !product.imageAsset!.startsWith('http'),
          isTrue,
          reason: product.id,
        );
      }
    });

    test('incluye variedad de disponibilidad y experiencias', () {
      final availability = mockProducts
          .map((product) => product.availability)
          .toSet();
      expect(availability, containsAll(GiftAvailability.values));

      final experiences = mockProducts.where(
        (product) => product.category == GiftCategory.experiences,
      );
      expect(experiences, hasLength(3));
      expect(
        experiences.every(
          (product) => product.giftFormat == GiftFormat.experience,
        ),
        isTrue,
      );
    });
  });
}
