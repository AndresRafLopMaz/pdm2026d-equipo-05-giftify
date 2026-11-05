import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/auth_gate.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/payments/providers/payment_methods_provider.dart';
import 'package:giftify/features/payments/screens/add_payment_method_screen.dart';
import 'package:giftify/features/payments/screens/payment_methods_screen.dart';
import 'package:giftify/shared/enums/payment_brand.dart';
import 'package:giftify/shared/models/payment_method.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_harness.dart';
import '../helpers/fake_payment_method_repository.dart';
import '../helpers/ownership_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const visa = PaymentMethod(
    id: 'pay-1',
    userId: 1,
    holderName: 'Ana',
    brand: PaymentBrand.visa,
    last4: '4242',
    expiryMonth: 8,
    expiryYear: 2030,
    isDefault: true,
  );

  const mastercard = PaymentMethod(
    id: 'pay-2',
    userId: 1,
    holderName: 'Ana',
    brand: PaymentBrand.mastercard,
    last4: '4444',
    expiryMonth: 9,
    expiryYear: 2031,
  );

  Future<void> pumpPayments(
    WidgetTester tester, {
    List<PaymentMethod> initial = const [],
    ThemeData? theme,
    bool withAuth = true,
  }) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    final fake = FakePaymentMethodRepository(userId: user.id, initial: initial);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (withAuth) ...harness.overrides,
          if (!withAuth) ownershipNotNeededOverride,
          paymentMethodRepositoryProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.lightTheme,
          home: withAuth
              ? const AuthGate(authenticatedChild: PaymentMethodsScreen())
              : const PaymentMethodsScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpAddForm(
    WidgetTester tester, {
    ThemeData? theme,
    DateTime? now,
  }) async {
    final fake = FakePaymentMethodRepository(userId: 1);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ownershipNotNeededOverride,
          paymentMethodRepositoryProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.lightTheme,
          home: AddPaymentMethodScreen(now: now),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra empty state y CTA', (tester) async {
    await pumpPayments(tester);

    expect(find.text('Aún no tienes métodos de pago'), findsOneWidget);
    expect(find.byKey(const ValueKey('payment-add-button')), findsOneWidget);
    expect(
      find.text('Usa datos ficticios para esta demostración.'),
      findsOneWidget,
    );
  });

  testWidgets('muestra métodos, default y menú', (tester) async {
    await pumpPayments(tester, initial: const [visa, mastercard]);

    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(find.text('Mastercard •••• 4444'), findsOneWidget);
    expect(find.text('Predeterminado'), findsOneWidget);
    expect(find.text('Vence 08/30'), findsOneWidget);
    expect(find.byKey(const ValueKey('payment-menu-pay-2')), findsOneWidget);
  });

  testWidgets('establece un método como predeterminado', (tester) async {
    await pumpPayments(tester, initial: const [visa, mastercard]);

    await tester.tap(find.byKey(const ValueKey('payment-menu-pay-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Establecer como predeterminado'));
    await tester.pumpAndSettle();

    expect(find.text('Predeterminado'), findsOneWidget);
  });

  testWidgets('elimina con confirmación', (tester) async {
    await pumpPayments(tester, initial: const [visa, mastercard]);

    await tester.tap(find.byKey(const ValueKey('payment-menu-pay-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar método de pago?'), findsOneWidget);
    expect(find.text('Mastercard •••• 4444'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('payment-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Mastercard •••• 4444'), findsNothing);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
  });

  testWidgets('agrega método desde el flujo de pantalla', (tester) async {
    await pumpPayments(tester);

    await tester.tap(find.byKey(const ValueKey('payment-add-button')));
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

    expect(find.byType(PaymentMethodsScreen), findsOneWidget);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(find.text('Método de pago agregado.'), findsOneWidget);
  });

  testWidgets('muestra error de carga y permite reintentar', (tester) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    final fake = FakePaymentMethodRepository(userId: user.id)..failList = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          paymentMethodRepositoryProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthGate(authenticatedChild: PaymentMethodsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar tus métodos de pago.'), findsOneWidget);

    fake.failList = false;
    await tester.tap(find.byKey(const ValueKey('payments-retry')));
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes métodos de pago'), findsOneWidget);
  });

  testWidgets('PaymentMethodsScreen es responsive y dark', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpPayments(
      tester,
      initial: const [visa],
      theme: AppTheme.darkTheme,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
  });

  testWidgets('AddPaymentMethod valida campos y no pide PAN/CVV', (
    tester,
  ) async {
    await pumpAddForm(tester, now: DateTime(2026, 11, 5));

    expect(
      find.text('Usa datos ficticios para esta demostración.'),
      findsOneWidget,
    );
    expect(find.text('Número de tarjeta'), findsNothing);
    expect(find.text('CVV'), findsNothing);

    final submit = find.byKey(const ValueKey('payment-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa el nombre del titular.'), findsOneWidget);
    expect(find.text('Selecciona una marca.'), findsOneWidget);
    expect(find.text('Ingresa exactamente 4 dígitos.'), findsOneWidget);
  });

  testWidgets('AddPaymentMethod detecta vencimiento pasado', (tester) async {
    await pumpAddForm(tester, now: DateTime(2026, 11, 5));

    await tester.enterText(find.byKey(const ValueKey('payment-holder')), 'Ana');
    await tester.tap(find.byKey(const ValueKey('payment-brand')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('payment-last4')), '4242');
    await tester.tap(find.byKey(const ValueKey('payment-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10').last);
    await tester.pumpAndSettle();

    final submit = find.byKey(const ValueKey('payment-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('La fecha no puede estar en el pasado.'), findsWidgets);
  });

  testWidgets('AddPaymentMethod es responsive, dark y text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpAddForm(tester, theme: AppTheme.darkTheme);

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    final submit = find.byKey(const ValueKey('payment-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    expect(submit.hitTestable(), findsOneWidget);
  });

  for (final size in const [Size(390, 844), Size(412, 915), Size(800, 800)]) {
    testWidgets('PaymentMethods soporta ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpPayments(tester, initial: const [visa, mastercard]);

      expect(tester.takeException(), isNull);
      expect(find.text('Visa •••• 4242'), findsOneWidget);
    });

    testWidgets('AddPaymentMethod soporta ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAddForm(tester);

      expect(tester.takeException(), isNull);
      final submit = find.byKey(const ValueKey('payment-submit'));
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(submit.hitTestable(), findsOneWidget);
    });
  }

  testWidgets('PaymentMethods soporta text scale 1.3', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpPayments(tester, initial: const [visa]);
    expect(tester.takeException(), isNull);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
  });

  testWidgets('AddPaymentMethod soporta text scale 1.3', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpAddForm(tester);
    expect(tester.takeException(), isNull);
    final submit = find.byKey(const ValueKey('payment-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    expect(submit.hitTestable(), findsOneWidget);
  });
}
