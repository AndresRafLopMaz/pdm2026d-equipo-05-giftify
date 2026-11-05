import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/auth_gate.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/features/addresses/screens/address_form_screen.dart';
import 'package:giftify/features/addresses/screens/address_list_screen.dart';
import 'package:giftify/features/auth/providers/current_user_provider.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';
import 'package:giftify/features/auth/screens/register_screen.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:giftify/features/home/screens/home_screen.dart';
import 'package:giftify/features/payments/providers/payment_methods_provider.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/features/products/screens/product_results_screen.dart';
import 'package:giftify/features/profile/screens/profile_screen.dart';
import 'package:giftify/features/search/screens/gift_search_screen.dart';
import 'package:giftify/features/settings/screens/settings_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/payment_brand.dart';
import 'package:giftify/shared/models/cart_item.dart';
import 'package:giftify/shared/models/delivery_address.dart';
import 'package:giftify/shared/models/payment_method.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/auth_test_harness.dart';
import 'helpers/fake_address_repository.dart';
import 'helpers/fake_payment_method_repository.dart';
import 'helpers/ownership_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpDark(
    WidgetTester tester,
    Widget home, {
    List<Override> overrides = const [],
    bool includeOwnership = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (includeOwnership) currentUserIdProvider.overrideWithValue(1),
          if (includeOwnership) ownershipNotNeededOverride,
          ...overrides,
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: home,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  AuthTestHarness authenticatedHarness() {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana López',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    return harness;
  }

  testWidgets('Login y Register renderizan en dark', (tester) async {
    await pumpDark(tester, LoginScreen(onCreateAccount: () {}));
    expect(find.byType(LoginScreen), findsOneWidget);

    await pumpDark(tester, RegisterScreen(onLogin: () {}));
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('AuthGate Login en dark', (tester) async {
    final harness = AuthTestHarness();
    await pumpDark(
      tester,
      const AuthGate(),
      overrides: harness.overrides,
      includeOwnership: false,
    );
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('AuthGate error en dark', (tester) async {
    final failing = AuthTestHarness()..session.failRead = true;
    await pumpDark(
      tester,
      const AuthGate(),
      overrides: failing.overrides,
      includeOwnership: false,
    );
    expect(find.text('No pudimos restaurar tu sesión.'), findsOneWidget);
  });

  testWidgets('Home y Profile renderizan en dark con usuario real', (
    tester,
  ) async {
    final harness = authenticatedHarness();

    await pumpDark(
      tester,
      const HomeScreen(),
      overrides: harness.overrides,
      includeOwnership: false,
    );
    expect(find.text('Hola, Ana'), findsOneWidget);

    await pumpDark(
      tester,
      const AuthGate(authenticatedChild: ProfileScreen()),
      overrides: harness.overrides,
      includeOwnership: false,
    );
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('ana@mail.com'), findsOneWidget);
  });

  testWidgets('Settings renderiza en dark', (tester) async {
    await pumpDark(tester, const SettingsScreen());
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Search, Results y Detail renderizan en dark', (tester) async {
    await pumpDark(tester, const GiftSearchScreen());
    expect(find.byType(GiftSearchScreen), findsOneWidget);

    await pumpDark(tester, const ProductResultsScreen());
    expect(find.byType(ProductResultsScreen), findsOneWidget);

    await pumpDark(tester, ProductDetailScreen(product: mockProducts.first));
    expect(find.byType(ProductDetailScreen), findsOneWidget);
  });

  testWidgets('Cart renderiza en dark', (tester) async {
    final item = CartItem(product: mockProducts.first);

    await pumpDark(tester, CartScreen(initialItems: [item]));
    expect(find.byType(CartScreen), findsOneWidget);
  });

  testWidgets('Checkout renderiza en dark', (tester) async {
    final item = CartItem(product: mockProducts.first);

    await pumpDark(
      tester,
      CheckoutScreen(now: DateTime(2026, 11, 5)),
      overrides: [
        cartRepositoryProvider.overrideWithValue(
          PersistentCartRepository(
            store: InMemoryCartStore([
              CartEntry(productId: item.product.id, quantity: 1),
            ]),
          ),
        ),
        addressRepositoryProvider.overrideWithValue(
          FakeAddressRepository(
            initial: [
              DeliveryAddress(
                id: 'addr-casa',
                label: 'Casa',
                recipientName: 'Ana',
                addressLine: '5a avenida 10-20',
                city: 'Guatemala',
                department: 'Guatemala',
                isDefault: true,
              ),
            ],
          ),
        ),
        paymentMethodRepositoryProvider.overrideWithValue(
          FakePaymentMethodRepository(
            userId: 1,
            initial: const [
              PaymentMethod(
                id: 'pay-1',
                userId: 1,
                holderName: 'Ana',
                brand: PaymentBrand.visa,
                last4: '4242',
                expiryMonth: 8,
                expiryYear: 2099,
                isDefault: true,
              ),
            ],
          ),
        ),
      ],
    );
    expect(find.byType(CheckoutScreen), findsOneWidget);
  });

  testWidgets('AddressList renderiza en dark', (tester) async {
    final repository = FakeAddressRepository();

    await pumpDark(
      tester,
      const AddressListScreen(),
      overrides: [addressRepositoryProvider.overrideWithValue(repository)],
    );
    expect(find.byType(AddressListScreen), findsOneWidget);
  });

  testWidgets('AddressForm renderiza en dark', (tester) async {
    await pumpDark(tester, AddressFormScreen(onSubmit: (_) async {}));
    expect(find.byType(AddressFormScreen), findsOneWidget);
  });
}
