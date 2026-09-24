import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/features/products/screens/product_results_screen.dart';
import 'package:giftify/features/products/utils/product_filters.dart';
import 'package:giftify/features/products/widgets/product_card.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

void main() {
  testWidgets('sin criterios muestra el catálogo general', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductResultsScreen()));

    expect(find.byType(ProductCard), findsWidgets);
    expect(find.text('Resultados'), findsOneWidget);
  });

  testWidgets('con criterios renderiza resultados y resumen', (tester) async {
    const criteria = GiftSearchCriteria(
      occasion: 'Cumpleaños',
      recipient: 'Amigo',
      maxBudget: 1000,
    );

    await tester.pumpWidget(
      const MaterialApp(home: ProductResultsScreen(criteria: criteria)),
    );

    expect(find.text('Tu búsqueda'), findsOneWidget);
    expect(find.byType(ProductCard), findsWidgets);
  });

  testWidgets('muestra estado informativo cuando no hay resultados', (
    tester,
  ) async {
    const criteria = GiftSearchCriteria(
      occasion: 'Cumpleaños',
      recipient: 'Amigo',
      maxBudget: 1,
    );

    await tester.pumpWidget(
      const MaterialApp(home: ProductResultsScreen(criteria: criteria)),
    );

    expect(
      find.text('No encontramos opciones que cumplan todos los criterios.'),
      findsOneWidget,
    );
    expect(find.byType(ProductCard), findsNothing);
  });

  testWidgets('al pulsar una tarjeta navega al detalle con el producto', (
    tester,
  ) async {
    const criteria = GiftSearchCriteria(
      occasion: 'Cumpleaños',
      recipient: 'Amigo',
      maxBudget: 1000,
    );
    final expected = filterAndPrioritizeProducts(mockProducts, criteria).first;

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );

    navigatorKey.currentState!.pushNamed(
      AppRoutes.productResults,
      arguments: criteria,
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProductCard).first);
    await tester.pumpAndSettle();

    final detail = tester.widget<ProductDetailScreen>(
      find.byType(ProductDetailScreen),
    );

    expect(detail.product, same(expected));
  });
}
