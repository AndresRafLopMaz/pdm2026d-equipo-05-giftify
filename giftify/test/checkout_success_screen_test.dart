import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/checkout/models/checkout_success_data.dart';
import 'package:giftify/features/checkout/screens/checkout_success_screen.dart';
import 'package:giftify/shared/enums/payment_brand.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const data = CheckoutSuccessData(
    totalUnits: 2,
    total: 250,
    addressLabel: 'Casa',
    recipientName: 'Ana',
    paymentBrand: PaymentBrand.visa,
    paymentLast4: '4242',
  );

  AuthTestHarness authenticatedHarness() {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    return harness;
  }

  testWidgets('muestra el resumen y vuelve al inicio', (tester) async {
    final harness = authenticatedHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: InMemoryCartStore()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CheckoutSuccessScreen(data: data),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pedido confirmado'), findsOneWidget);
    expect(find.text('2 artículos'), findsOneWidget);
    expect(find.text('Casa · Ana'), findsOneWidget);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(find.textContaining('CVV'), findsNothing);
    expect(find.textContaining('PIN'), findsNothing);

    final homeButton = find.byKey(
      const ValueKey('checkout-success-home-button'),
    );
    await tester.ensureVisible(homeButton);
    await tester.pumpAndSettle();
    await tester.tap(homeButton);
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(CheckoutSuccessScreen), findsNothing);
  });

  testWidgets('un deep link sin snapshot no muestra una confirmación falsa', (
    tester,
  ) async {
    final harness = authenticatedHarness();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: InMemoryCartStore()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          navigatorKey: navigatorKey,
          home: const SizedBox.shrink(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );

    navigatorKey.currentState!.pushNamed(AppRoutes.checkoutSuccess);
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutSuccessScreen), findsNothing);
    expect(find.text('Pedido confirmado'), findsNothing);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('un deep link con snapshot abre el resumen', (tester) async {
    final harness = authenticatedHarness();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: InMemoryCartStore()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          navigatorKey: navigatorKey,
          home: const SizedBox.shrink(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );

    navigatorKey.currentState!.pushNamed(
      AppRoutes.checkoutSuccess,
      arguments: data,
    );
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutSuccessScreen), findsOneWidget);
    expect(find.text('Pedido confirmado'), findsOneWidget);
  });

  testWidgets('el back desde Success vuelve a Inicio', (tester) async {
    final harness = authenticatedHarness();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: InMemoryCartStore()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          navigatorKey: navigatorKey,
          home: const MainShell(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainShell)),
    );
    container.read(appTabProvider.notifier).select(AppTab.cart);
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pushNamed(
      AppRoutes.checkoutSuccess,
      arguments: data,
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutSuccessScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutSuccessScreen), findsNothing);
    expect(find.byType(MainShell), findsOneWidget);
    expect(container.read(appTabProvider), AppTab.home);
  });

  testWidgets('Success es responsive y soporta text scale', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final size in const [Size(320, 640), Size(390, 844), Size(800, 800)]) {
      for (final scale in const [1.3, 2.0]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        final harness = authenticatedHarness();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...harness.overrides,
              cartRepositoryProvider.overrideWithValue(
                PersistentCartRepository(store: InMemoryCartStore()),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CheckoutSuccessScreen(data: data),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Pedido confirmado'), findsOneWidget);
      }
    }
  });
}
