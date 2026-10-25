import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

void main() {
  String textForKey(WidgetTester tester, String key) {
    return tester.widget<Text>(find.byKey(ValueKey(key))).data!;
  }

  Future<void> verifyCartToCheckoutFlow(WidgetTester tester) async {
    final product = mockProducts.first;
    final initialItem = CartItem(product: product);
    final expectedItem = initialItem.copyWith(quantity: 2);
    final expectedTotalText = 'Q ${expectedItem.subtotal.toStringAsFixed(2)}';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: InMemoryCartStore()),
          ),
        ],
        child: MaterialApp(
          theme: appTheme,
          home: CartScreen(initialItems: [initialItem]),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cart = tester.widget<CartScreen>(find.byType(CartScreen));
    expect(cart.initialItems, hasLength(1));
    expect(cart.initialItems.single, same(initialItem));

    await tester.tap(find.byKey(ValueKey('increase-${product.id}')));
    await tester.pumpAndSettle();

    expect(textForKey(tester, 'quantity-${product.id}'), '2');
    expect(textForKey(tester, 'subtotal-${product.id}'), expectedTotalText);

    final cartTotalText = textForKey(tester, 'cart-total');
    expect(cartTotalText, expectedTotalText);

    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();

    final checkout = tester.widget<CheckoutScreen>(find.byType(CheckoutScreen));
    expect(checkout.items, hasLength(1));
    expect(checkout.items.single.product, same(product));
    expect(checkout.items.single.quantity, 2);

    final receivedTotal = checkout.items.fold<double>(
      0,
      (total, item) => total + item.subtotal,
    );
    expect(receivedTotal, expectedItem.subtotal);

    await tester.scrollUntilVisible(
      find.text('Resumen del pedido'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(textForKey(tester, 'checkout-total'), cartTotalText);
  }

  testWidgets('mantiene items y total en el flujo Cart a Checkout', (
    tester,
  ) async {
    await verifyCartToCheckoutFlow(tester);
  });

  testWidgets('completa el flujo Cart a Checkout en 320x640 sin overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await verifyCartToCheckoutFlow(tester);

    expect(tester.takeException(), isNull);
  });
}
