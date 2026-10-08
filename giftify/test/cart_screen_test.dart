import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

void main() {
  Future<void> pumpCart(WidgetTester tester, List<CartItem> items) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: CartScreen(initialItems: items),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }

  String textForKey(WidgetTester tester, String key) {
    return tester.widget<Text>(find.byKey(ValueKey(key))).data!;
  }

  testWidgets('renderiza producto, precio, subtotal y total', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product, quantity: 2)]);

    expect(find.text(product.name), findsOneWidget);
    expect(find.text('Precio unitario: Q 125.00'), findsOneWidget);
    expect(textForKey(tester, 'subtotal-${product.id}'), 'Q 250.00');
    expect(textForKey(tester, 'cart-total'), 'Q 250.00');
    expect(
      find.byKey(const ValueKey('product-image-placeholder')),
      findsOneWidget,
    );
  });

  testWidgets('incrementa la cantidad y recalcula importes', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);
    await tester.tap(find.byKey(ValueKey('increase-${product.id}')));
    await tester.pump();

    expect(textForKey(tester, 'quantity-${product.id}'), '2');
    expect(textForKey(tester, 'subtotal-${product.id}'), 'Q 250.00');
    expect(textForKey(tester, 'cart-total'), 'Q 250.00');
  });

  testWidgets('disminuye la cantidad y recalcula importes', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product, quantity: 2)]);
    await tester.tap(find.byKey(ValueKey('decrease-${product.id}')));
    await tester.pump();

    expect(textForKey(tester, 'quantity-${product.id}'), '1');
    expect(textForKey(tester, 'subtotal-${product.id}'), 'Q 125.00');
    expect(textForKey(tester, 'cart-total'), 'Q 125.00');
  });

  testWidgets('no permite disminuir la cantidad por debajo de uno', (
    tester,
  ) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);

    final decreaseButton = tester.widget<IconButton>(
      find.byKey(ValueKey('decrease-${product.id}')),
    );
    expect(decreaseButton.onPressed, isNull);
    expect(textForKey(tester, 'quantity-${product.id}'), '1');
  });

  testWidgets('elimina explícitamente un producto', (tester) async {
    final firstProduct = mockProducts.first;
    final secondProduct = mockProducts[1];

    await pumpCart(tester, [
      CartItem(product: firstProduct),
      CartItem(product: secondProduct),
    ]);
    await tester.tap(find.byKey(ValueKey('remove-${firstProduct.id}')));
    await tester.pump();

    expect(find.text(firstProduct.name), findsNothing);
    expect(find.text(secondProduct.name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 95.00');
  });

  testWidgets('eliminar el último producto muestra el carrito vacío', (
    tester,
  ) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);
    await tester.tap(find.byKey(ValueKey('remove-${product.id}')));
    await tester.pump();

    expect(find.text('Tu carrito está vacío'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-total')), findsNothing);
    expect(find.text('Q 0.00'), findsNothing);

    final checkoutButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('checkout-button')),
    );
    expect(checkoutButton.onPressed, isNull);
  });

  testWidgets('renderiza el estado vacío sin una compra válida', (
    tester,
  ) async {
    await pumpCart(tester, const []);

    expect(find.text('Tu carrito está vacío'), findsOneWidget);
    expect(
      find.text('Agrega un regalo para continuar con tu compra.'),
      findsOneWidget,
    );
    expect(find.text('Q 0.00'), findsNothing);
    expect(find.byKey(const ValueKey('cart-total')), findsNothing);

    final checkoutButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('checkout-button')),
    );
    expect(checkoutButton.onPressed, isNull);
  });

  testWidgets('se adapta a una pantalla móvil estrecha', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCart(tester, [CartItem(product: mockProducts.first)]);

    expect(tester.takeException(), isNull);
    expect(find.text(mockProducts.first.name), findsOneWidget);
    expect(find.byKey(const ValueKey('checkout-button')), findsOneWidget);
  });

  testWidgets('navega a checkout con la lista actualizada', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);
    await tester.tap(find.byKey(ValueKey('increase-${product.id}')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutScreen), findsOneWidget);
    final checkout = tester.widget<CheckoutScreen>(find.byType(CheckoutScreen));
    expect(checkout.items, hasLength(1));
    expect(checkout.items.single.product, same(product));
    expect(checkout.items.single.quantity, 2);
  });
}
