import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

void main() {
  testWidgets('el router envía GiftProduct a ProductDetailScreen', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );

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

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );

    navigatorKey.currentState!.pushNamed(AppRoutes.cart, arguments: items);

    await tester.pumpAndSettle();

    final cart = tester.widget<CartScreen>(find.byType(CartScreen));

    expect(cart.initialItems.length, 1);
    expect(cart.initialItems.first.product, same(mockProducts.first));
  });
}
