import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/shared/data/mock_products.dart';
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
        occasion: 'Cumpleaños',
        recipient: 'Amigo',
        maxBudget: 200,
      );

      final updated = criteria.copyWith(maxBudget: 300);

      expect(updated.occasion, 'Cumpleaños');
      expect(updated.recipient, 'Amigo');
      expect(updated.maxBudget, 300);
    });
  });
}
