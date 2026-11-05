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
import 'package:giftify/features/checkout/screens/checkout_success_screen.dart';
import 'package:giftify/features/payments/providers/payment_methods_provider.dart';
import 'package:giftify/features/payments/screens/add_payment_method_screen.dart';
import 'package:giftify/features/payments/screens/payment_methods_screen.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/features/products/screens/product_results_screen.dart';
import 'package:giftify/features/search/screens/gift_search_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_harness.dart';
import '../helpers/fake_address_repository.dart';
import '../helpers/fake_payment_method_repository.dart';

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
    FakePaymentMethodRepository? paymentRepository,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          if (addressRepository != null)
            addressRepositoryProvider.overrideWithValue(addressRepository),
          if (paymentRepository != null)
            paymentMethodRepositoryProvider.overrideWithValue(
              paymentRepository,
            ),
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: InMemoryCartStore()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: route,
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
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AddressListScreen), findsNothing);
  });

  testWidgets('/cart sin sesión no expone el carrito', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(tester, AppRoutes.cart, harness: harness);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CartScreen), findsNothing);
  });

  testWidgets('/checkout sin sesión no expone checkout', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(tester, AppRoutes.checkout, harness: harness);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CheckoutScreen), findsNothing);
  });

  testWidgets('/checkout/success sin sesión no expone la confirmación', (
    tester,
  ) async {
    final harness = AuthTestHarness();

    await pumpRoute(tester, AppRoutes.checkoutSuccess, harness: harness);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CheckoutSuccessScreen), findsNothing);
  });

  testWidgets('/search sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(tester, AppRoutes.search, harness: harness);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(GiftSearchScreen), findsNothing);
  });

  testWidgets('/products sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(tester, AppRoutes.productResults, harness: harness);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProductResultsScreen), findsNothing);
  });

  testWidgets('/products/detail sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(tester, AppRoutes.productDetail, harness: harness);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProductDetailScreen), findsNothing);
  });

  testWidgets('/search con sesión abre Search', (tester) async {
    final harness = authenticatedHarness();

    await pumpRoute(tester, AppRoutes.search, harness: harness);

    expect(find.byType(GiftSearchScreen), findsOneWidget);
  });

  testWidgets('/products con sesión abre Results', (tester) async {
    final harness = authenticatedHarness();

    await pumpRoute(tester, AppRoutes.productResults, harness: harness);

    expect(find.byType(ProductResultsScreen), findsOneWidget);
  });

  testWidgets('/products/detail con sesión envía el producto', (tester) async {
    final harness = authenticatedHarness();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          navigatorKey: navigatorKey,
          home: const SizedBox.shrink(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pushNamed(
      AppRoutes.productDetail,
      arguments: mockProducts.first,
    );
    await tester.pumpAndSettle();

    final detail = tester.widget<ProductDetailScreen>(
      find.byType(ProductDetailScreen),
    );
    expect(detail.product, same(mockProducts.first));
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

  testWidgets('/payment-methods sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(
      tester,
      AppRoutes.paymentMethods,
      harness: harness,
      paymentRepository: FakePaymentMethodRepository(userId: 1),
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(PaymentMethodsScreen), findsNothing);
  });

  testWidgets('/payment-methods/new sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();

    await pumpRoute(
      tester,
      AppRoutes.addPaymentMethod,
      harness: harness,
      paymentRepository: FakePaymentMethodRepository(userId: 1),
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AddPaymentMethodScreen), findsNothing);
  });

  testWidgets('/payment-methods con sesión abre Payments', (tester) async {
    final harness = authenticatedHarness();

    await pumpRoute(
      tester,
      AppRoutes.paymentMethods,
      harness: harness,
      paymentRepository: FakePaymentMethodRepository(userId: 1),
    );

    expect(find.byType(PaymentMethodsScreen), findsOneWidget);
  });

  testWidgets('/payment-methods/new con sesión abre Add', (tester) async {
    final harness = authenticatedHarness();

    await pumpRoute(
      tester,
      AppRoutes.addPaymentMethod,
      harness: harness,
      paymentRepository: FakePaymentMethodRepository(userId: 1),
    );

    expect(find.byType(AddPaymentMethodScreen), findsOneWidget);
  });
}
