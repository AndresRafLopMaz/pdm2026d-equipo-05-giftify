import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/features/addresses/screens/address_list_screen.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

import 'helpers/auth_test_harness.dart';
import 'helpers/fake_address_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  AuthTestHarness authenticatedHarness() {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    return harness;
  }

  testWidgets('el router envía GiftProduct a ProductDetailScreen', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final harness = authenticatedHarness();

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: AppRoutes.home,
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

  testWidgets('el router envía CartItem a CartScreen', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    final items = [CartItem(product: mockProducts.first)];
    final harness = authenticatedHarness();

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pushNamed(AppRoutes.cart, arguments: items);

    await tester.pumpAndSettle();

    final cart = tester.widget<CartScreen>(find.byType(CartScreen));

    expect(cart.initialItems.length, 1);
    expect(cart.initialItems.first.product, same(mockProducts.first));
  });

  testWidgets('el router abre AddressListScreen', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final repository = FakeAddressRepository();
    final harness = authenticatedHarness();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          addressRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pushNamed(AppRoutes.addresses);
    await tester.pumpAndSettle();

    expect(find.byType(AddressListScreen), findsOneWidget);
    expect(find.text('Mis direcciones'), findsOneWidget);
  });
}
