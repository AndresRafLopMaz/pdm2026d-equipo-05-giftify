import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/features/cart/data/cart_repository.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:giftify/features/checkout/screens/checkout_success_screen.dart';
import 'package:giftify/features/payments/providers/payment_methods_provider.dart';
import 'package:giftify/features/payments/screens/add_payment_method_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/payment_brand.dart';
import 'package:giftify/shared/models/delivery_address.dart';
import 'package:giftify/shared/models/payment_method.dart';

import 'helpers/auth_test_harness.dart';
import 'helpers/fake_address_repository.dart';
import 'helpers/fake_payment_method_repository.dart';

class _FailingClearStore extends InMemoryCartStore {
  _FailingClearStore(super.entries);

  @override
  Future<void> clear() async {
    throw StateError('No se pudo vaciar el carrito.');
  }
}

void main() {
  final defaultNow = DateTime(2026, 11, 5);
  const casa = DeliveryAddress(
    id: 'addr-casa',
    label: 'Casa',
    recipientName: 'Ana',
    addressLine: '5a avenida 10-20',
    city: 'Guatemala',
    department: 'Guatemala',
    isDefault: true,
  );
  const trabajo = DeliveryAddress(
    id: 'addr-trabajo',
    label: 'Trabajo',
    recipientName: 'Ana',
    addressLine: '1a calle 2-30, zona 4',
    city: 'Guatemala',
    department: 'Guatemala',
  );
  const visa = PaymentMethod(
    id: 'pay-1',
    userId: 1,
    holderName: 'Ana',
    brand: PaymentBrand.visa,
    last4: '4242',
    expiryMonth: 8,
    expiryYear: 2099,
    isDefault: true,
  );
  const mastercard = PaymentMethod(
    id: 'pay-2',
    userId: 1,
    holderName: 'Ana',
    brand: PaymentBrand.mastercard,
    last4: '4444',
    expiryMonth: 9,
    expiryYear: 2099,
  );
  const expired = PaymentMethod(
    id: 'pay-expired',
    userId: 1,
    holderName: 'Ana',
    brand: PaymentBrand.visa,
    last4: '0000',
    expiryMonth: 1,
    expiryYear: 2020,
  );

  Future<CartStore> pumpCheckout(
    WidgetTester tester, {
    CartStore? store,
    CartRepository? repository,
    List<DeliveryAddress> addresses = const [casa, trabajo],
    List<PaymentMethod> payments = const [visa, mastercard],
    Object? addressLoadError,
    DateTime? nowOverride,
  }) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;

    final cartStore =
        store ??
        InMemoryCartStore([
          CartEntry(productId: mockProducts.first.id, quantity: 2),
        ]);
    final addressRepository = FakeAddressRepository(
      initial: addresses,
      loadError: addressLoadError,
    );
    final paymentRepository = FakePaymentMethodRepository(
      userId: user.id,
      initial: payments,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          cartRepositoryProvider.overrideWithValue(
            repository ?? PersistentCartRepository(store: cartStore),
          ),
          addressRepositoryProvider.overrideWithValue(addressRepository),
          paymentMethodRepositoryProvider.overrideWithValue(paymentRepository),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: CheckoutScreen(now: nowOverride ?? defaultNow),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cartStore;
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('confirm-order-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra dirección y pago guardados en lugar del formulario', (
    tester,
  ) async {
    await pumpCheckout(tester);

    expect(find.text('Casa · Ana'), findsOneWidget);
    expect(find.byKey(const ValueKey('recipient-field')), findsNothing);
    expect(find.byKey(const ValueKey('address-field')), findsNothing);
    expect(find.byKey(const ValueKey('payment-cash')), findsNothing);

    await scrollTo(tester, find.byKey(const ValueKey('checkout-payment-card')));
    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(find.textContaining('CVV'), findsNothing);
    expect(find.textContaining('PIN'), findsNothing);

    await scrollTo(tester, find.byKey(const ValueKey('checkout-total')));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('checkout-total'))).data,
      'Q 250.00',
    );
    expect(
      find.text(
        'Compra de demostración: no se procesa ningún pago real ni se '
        'crea una orden de compra.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('carrito vacío no permite confirmar y ofrece volver al inicio', (
    tester,
  ) async {
    await pumpCheckout(tester, store: InMemoryCartStore());

    expect(find.byKey(const ValueKey('checkout-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('confirm-order-button')), findsNothing);
    expect(find.byKey(const ValueKey('checkout-empty-home')), findsOneWidget);
  });

  testWidgets('sin dirección o sin pago bloquea la confirmación', (
    tester,
  ) async {
    await pumpCheckout(tester, addresses: const []);
    expect(find.byKey(const ValueKey('checkout-address-add')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('confirm-order-button')),
          )
          .onPressed,
      isNull,
    );

    await pumpCheckout(tester, payments: const []);
    expect(
      find.byKey(const ValueKey('checkout-payment-required')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('confirm-order-button')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('todos los pagos vencidos ofrecen agregar uno vigente', (
    tester,
  ) async {
    await pumpCheckout(tester, payments: const [expired]);

    await scrollTo(
      tester,
      find.byKey(const ValueKey('checkout-payment-expired')),
    );
    expect(find.text('Sin método de pago vigente'), findsOneWidget);
    expect(find.text('No tienes un método de pago vigente.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('checkout-payment-add-expired')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('confirm-order-button')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('el selector con pagos vencidos no permite elegirlos', (
    tester,
  ) async {
    await pumpCheckout(tester, payments: const [expired]);

    await scrollTo(
      tester,
      find.byKey(const ValueKey('checkout-payment-expired-change')),
    );
    await tester.tap(
      find.byKey(const ValueKey('checkout-payment-expired-change')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vence 01/20 · Vencido'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('checkout-payment-add-from-selector')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('checkout-payment-add-from-selector')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AddPaymentMethodScreen), findsOneWidget);
  });

  testWidgets('agrega un pago vigente desde checkout y permite confirmar', (
    tester,
  ) async {
    await pumpCheckout(tester, payments: const [expired]);

    await scrollTo(
      tester,
      find.byKey(const ValueKey('checkout-payment-add-expired')),
    );
    await tester.tap(
      find.byKey(const ValueKey('checkout-payment-add-expired')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddPaymentMethodScreen), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('payment-holder')), 'Ana');
    await tester.tap(find.byKey(const ValueKey('payment-brand')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('payment-last4')), '4242');
    final submit = find.byKey(const ValueKey('payment-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutScreen), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('checkout-payment-card')));
    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('confirm-order-button')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('permite cambiar dirección y método de pago guardados', (
    tester,
  ) async {
    await pumpCheckout(tester);

    await tester.tap(find.byKey(const ValueKey('checkout-address-change')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trabajo').last);
    await tester.pumpAndSettle();
    expect(find.text('Trabajo · Ana'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('checkout-payment-change')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mastercard •••• 4444').last);
    await tester.pumpAndSettle();
    expect(find.text('Mastercard •••• 4444'), findsOneWidget);
  });

  testWidgets('confirma, muestra el snapshot y vacía el carrito', (
    tester,
  ) async {
    final store = await pumpCheckout(tester);

    await tester.tap(find.byKey(const ValueKey('confirm-order-button')));
    await tester.pump();
    expect(find.text('Procesando…'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('confirm-order-button')),
          )
          .onPressed,
      isNull,
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutSuccessScreen), findsOneWidget);
    expect(find.text('Compra simulada completada'), findsOneWidget);
    expect(find.text('2 artículos'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('checkout-success-total')))
          .data,
      'Q 250.00',
    );
    expect(find.text('Casa · Ana'), findsOneWidget);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(find.textContaining('CVV'), findsNothing);
    expect(await store.load(), isEmpty);
  });

  testWidgets('si falla el vaciado permanece en checkout y no confirma', (
    tester,
  ) async {
    final store = _FailingClearStore([
      CartEntry(productId: mockProducts.first.id, quantity: 2),
    ]);
    await pumpCheckout(tester, store: store);

    await confirm(tester);

    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(find.byType(CheckoutSuccessScreen), findsNothing);
    expect(
      find.text(
        'No pudimos vaciar el carrito. Tu compra no se completó; '
        'inténtalo de nuevo.',
      ),
      findsOneWidget,
    );
    expect(await store.load(), isNotEmpty);
  });

  testWidgets('muestra error de carga y permite reintentar', (tester) async {
    await pumpCheckout(
      tester,
      addressLoadError: StateError('falló la carga de direcciones'),
    );

    expect(find.byKey(const ValueKey('checkout-error')), findsOneWidget);
    expect(find.byKey(const ValueKey('checkout-retry')), findsOneWidget);
  });

  testWidgets('se adapta a 320x640 con el botón de confirmación visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCheckout(tester);

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byKey(const ValueKey('checkout-scroll-view')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('confirm-order-button')), findsOneWidget);
  });

  testWidgets('soporta text scale 2.0 en 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpCheckout(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('confirm-order-button')), findsOneWidget);
  });
}
