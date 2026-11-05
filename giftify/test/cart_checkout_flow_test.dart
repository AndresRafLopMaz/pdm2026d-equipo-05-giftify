import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_availability.dart';
import 'package:giftify/shared/models/cart_item.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  String textForKey(WidgetTester tester, String key) {
    return tester.widget<Text>(find.byKey(ValueKey(key))).data!;
  }

  Future<void> verifyCartToCheckoutFlow(WidgetTester tester) async {
    final product = mockProducts.first;
    final initialItem = CartItem(product: product);
    final expectedItem = initialItem.copyWith(quantity: 2);
    final expectedTotalText = 'Q ${expectedItem.subtotal.toStringAsFixed(2)}';

    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
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
      find.text('Resumen'),
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

  testWidgets('ProductDetail agrega, Ver carrito y Checkout conserva todo', (
    tester,
  ) async {
    final product = mockProducts.firstWhere(
      (item) => item.availability == GiftAvailability.inStock,
    );
    final store = InMemoryCartStore();
    final navigatorKey = GlobalKey<NavigatorState>();

    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: store),
          ),
        ],
        child: MaterialApp(
          theme: appTheme,
          navigatorKey: navigatorKey,
          home: const MainShell(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pushNamed(
      AppRoutes.productDetail,
      arguments: product,
    );
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Agregar al carrito');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(find.text('Producto agregado al carrito.'), findsOneWidget);

    await tester.tap(find.text('Ver carrito'));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(CartScreen), findsOneWidget);
    expect(navigatorKey.currentState!.canPop(), isFalse);
    expect(find.text(product.name), findsOneWidget);
    expect(textForKey(tester, 'quantity-${product.id}'), '1');
    expect(
      textForKey(tester, 'cart-total'),
      'Q ${product.price.toStringAsFixed(2)}',
    );

    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();

    final checkout = tester.widget<CheckoutScreen>(find.byType(CheckoutScreen));
    expect(checkout.items, hasLength(1));
    expect(checkout.items.single.product, same(product));
    expect(checkout.items.single.quantity, 1);
    expect(checkout.items.single.subtotal, product.price);
  });
}
