import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_interest.dart';
import 'package:giftify/shared/enums/gift_occasion.dart';
import 'package:giftify/shared/enums/gift_recipient.dart';
import 'package:giftify/shared/models/cart_item.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

void main() {
  group('Modelos compartidos de Giftify', () {
    test('el catálogo mock contiene productos', () {
      expect(mockProducts, isNotEmpty);
    });

    test('el subtotal del carrito se calcula correctamente', () {
      final product = mockProducts.first;

      final item = CartItem(product: product, quantity: 2);

      expect(item.subtotal, product.price * 2);
    });

    test('los criterios de búsqueda pueden copiarse con cambios', () {
      const criteria = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 200,
      );

      final updated = criteria.copyWith(
        maxBudget: 300,
        interests: const {GiftInterest.technology},
      );

      expect(updated.occasion, GiftOccasion.birthday);
      expect(updated.recipientType, GiftRecipient.friend);
      expect(updated.maxBudget, 300);
      expect(updated.interests, {GiftInterest.technology});
    });

    test('GiftSearchCriteria compara por valor', () {
      const first = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 200,
        interests: {GiftInterest.technology, GiftInterest.music},
      );
      const second = GiftSearchCriteria(
        occasion: GiftOccasion.birthday,
        recipientType: GiftRecipient.friend,
        maxBudget: 200,
        interests: {GiftInterest.music, GiftInterest.technology},
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
