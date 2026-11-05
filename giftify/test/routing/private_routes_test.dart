import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/features/addresses/screens/address_list_screen.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_harness.dart';
import '../helpers/fake_address_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  AuthTestHarness authenticatedHarness() {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    return harness;
  }

  Future<void> pumpRoute(
    WidgetTester tester,
    String route, {
    required AuthTestHarness harness,
    FakeAddressRepository? addressRepository,
    bool authenticate = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          if (addressRepository != null)
            addressRepositoryProvider.overrideWithValue(addressRepository),
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: InMemoryCartStore()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: authenticate ? route : route,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('/addresses sin sesión no expone direcciones', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(
      tester,
      AppRoutes.addresses,
      harness: harness,
      addressRepository: FakeAddressRepository(),
      authenticate: false,
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AddressListScreen), findsNothing);
  });

  testWidgets('/cart sin sesión no expone el carrito', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(
      tester,
      AppRoutes.cart,
      harness: harness,
      authenticate: false,
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CartScreen), findsNothing);
  });

  testWidgets('/checkout sin sesión no expone checkout', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(
      tester,
      AppRoutes.checkout,
      harness: harness,
      authenticate: false,
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CheckoutScreen), findsNothing);
  });

  testWidgets('/addresses con sesión abre direcciones', (tester) async {
    final harness = authenticatedHarness();

    await pumpRoute(
      tester,
      AppRoutes.addresses,
      harness: harness,
      addressRepository: FakeAddressRepository(),
    );

    expect(find.byType(AddressListScreen), findsOneWidget);
  });

  testWidgets('/cart con sesión abre carrito', (tester) async {
    final harness = authenticatedHarness();

    await pumpRoute(tester, AppRoutes.cart, harness: harness);

    expect(find.byType(CartScreen), findsOneWidget);
  });

  testWidgets('/checkout con sesión abre checkout', (tester) async {
    final harness = authenticatedHarness();

    await pumpRoute(tester, AppRoutes.checkout, harness: harness);

    expect(find.byType(CheckoutScreen), findsOneWidget);
  });
}
