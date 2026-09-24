import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

void main() {
  Future<void> pumpCheckout(WidgetTester tester, List<CartItem> items) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: CheckoutScreen(items: items),
      ),
    );
  }

  Future<void> fillRequiredAddress(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const ValueKey('recipient-field')),
      'María López',
    );
    await tester.enterText(
      find.byKey(const ValueKey('address-field')),
      '5a avenida 10-20',
    );
    await tester.enterText(
      find.byKey(const ValueKey('city-field')),
      'Quetzaltenango',
    );
    await tester.enterText(
      find.byKey(const ValueKey('department-field')),
      'Quetzaltenango',
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> finishConfirmation(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra resumen, subtotales y total de los productos', (
    tester,
  ) async {
    await pumpCheckout(tester, [
      CartItem(product: mockProducts.first, quantity: 2),
      CartItem(product: mockProducts[1]),
    ]);
    await tester.scrollUntilVisible(
      find.text('Resumen del pedido'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Pulsera artesanal × 2'), findsOneWidget);
    expect(find.text('Caja de chocolates artesanales × 1'), findsOneWidget);
    expect(find.text('Q 250.00'), findsOneWidget);
    expect(find.text('Q 95.00'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('checkout-total'))).data,
      'Q 345.00',
    );
  });

  testWidgets('maneja una lista vacía sin permitir confirmación', (
    tester,
  ) async {
    await pumpCheckout(tester, const []);

    expect(find.text('No hay productos para procesar.'), findsOneWidget);
    expect(find.byKey(const ValueKey('checkout-total')), findsNothing);
    expect(find.text('Q 0.00'), findsNothing);

    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm-order-button')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('valida los cuatro campos obligatorios de dirección', (
    tester,
  ) async {
    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await tapVisible(tester, find.byKey(const ValueKey('payment-cash')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('confirm-order-button')),
    );

    expect(find.text('Este campo es obligatorio.'), findsNWidgets(4));
    expect(find.text('Pedido confirmado'), findsNothing);
  });

  testWidgets('permite confirmar sin completar la referencia opcional', (
    tester,
  ) async {
    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await fillRequiredAddress(tester);
    await tapVisible(tester, find.byKey(const ValueKey('payment-cash')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('confirm-order-button')),
    );
    await finishConfirmation(tester);

    expect(find.text('Pedido confirmado'), findsOneWidget);
  });

  testWidgets('exige seleccionar un método de pago', (tester) async {
    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await fillRequiredAddress(tester);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('confirm-order-button')),
    );
    await tester.scrollUntilVisible(
      find.text('Selecciona un método de pago.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Selecciona un método de pago.'), findsOneWidget);
    expect(find.text('Pedido confirmado'), findsNothing);
  });

  testWidgets('selecciona tarjeta y muestra una simulación segura', (
    tester,
  ) async {
    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await tapVisible(tester, find.byKey(const ValueKey('payment-card')));

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('payment-card')),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Tarjeta •••• 4242 (simulación, no se procesarán datos reales).',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('CVV'), findsNothing);
    expect(find.textContaining('PIN'), findsNothing);
  });

  testWidgets('selecciona pago contra entrega y muestra su indicación', (
    tester,
  ) async {
    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await tapVisible(tester, find.byKey(const ValueKey('payment-cash')));

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('payment-cash')),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );
    expect(find.text('Pagarás al recibir el pedido.'), findsOneWidget);
  });

  testWidgets('bloquea nuevos envíos mientras procesa la confirmación', (
    tester,
  ) async {
    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await fillRequiredAddress(tester);
    await tapVisible(tester, find.byKey(const ValueKey('payment-cash')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('confirm-order-button')),
    );

    expect(find.text('Procesando...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm-order-button')),
    );
    expect(button.onPressed, isNull);

    await finishConfirmation(tester);
    expect(find.text('Pedido confirmado'), findsOneWidget);
  });

  testWidgets('muestra feedback después de una confirmación válida', (
    tester,
  ) async {
    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await fillRequiredAddress(tester);
    await tester.enterText(
      find.byKey(const ValueKey('reference-field')),
      'Portón verde',
    );
    await tapVisible(tester, find.byKey(const ValueKey('payment-card')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('confirm-order-button')),
    );
    await finishConfirmation(tester);

    expect(find.text('Pedido confirmado'), findsOneWidget);
    expect(
      find.textContaining('Confirmación simulada para María López.'),
      findsOneWidget,
    );
    expect(find.textContaining('Tarjeta simulada •••• 4242'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);
  });

  testWidgets('se adapta a una pantalla móvil estrecha', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('confirm-order-button')), findsOneWidget);
  });

  testWidgets('permite desplazar el formulario con el teclado abierto', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await pumpCheckout(tester, [CartItem(product: mockProducts.first)]);
    await tester.tap(find.byKey(const ValueKey('recipient-field')));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('city-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('confirm-order-button')), findsOneWidget);
  });
}
