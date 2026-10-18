import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/features/products/screens/product_results_screen.dart';
import 'package:giftify/features/products/utils/product_filters.dart';
import 'package:giftify/features/products/widgets/product_card.dart';
import 'package:giftify/features/search/screens/gift_search_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

import 'helpers/fake_product_repository.dart';

void main() {
  testWidgets('sin criterios muestra el catálogo general', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductResultsScreen(
          repository: FakeProductRepository.success(mockProducts),
        ),
      ),
    );
    await tester.pumpAndSettle();

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
      MaterialApp(
        home: ProductResultsScreen(
          criteria: criteria,
          repository: FakeProductRepository.success(mockProducts),
        ),
      ),
    );
    await tester.pumpAndSettle();

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
      MaterialApp(
        home: ProductResultsScreen(
          criteria: criteria,
          repository: FakeProductRepository.success(mockProducts),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No encontramos productos.'), findsOneWidget);
    expect(find.text('Modificar búsqueda'), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);

    await tester.tap(find.text('Modificar búsqueda'));
    await tester.pumpAndSettle();

    expect(find.byType(GiftSearchScreen), findsOneWidget);
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

    await tester.pumpWidget(
      MaterialApp(
        home: ProductResultsScreen(
          criteria: criteria,
          repository: FakeProductRepository.success(mockProducts),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProductCard).first);
    await tester.pumpAndSettle();

    final detail = tester.widget<ProductDetailScreen>(
      find.byType(ProductDetailScreen),
    );

    expect(detail.product, same(expected));
  });

  testWidgets('muestra loading mientras el repositorio responde', (
    tester,
  ) async {
    final repository = FakeProductRepository(
      products: mockProducts,
      delay: const Duration(milliseconds: 100),
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductResultsScreen(repository: repository)),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando…'), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(ProductCard), findsWidgets);
  });

  testWidgets('muestra error humano sin crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductResultsScreen(repository: FakeProductRepository.error()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('No pudimos cargar los productos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);
  });

  testWidgets('Reintentar ejecuta una nueva consulta y muestra datos', (
    tester,
  ) async {
    final repository = FakeProductRepository.failOnceThenSuccess(mockProducts);

    await tester.pumpWidget(
      MaterialApp(home: ProductResultsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar los productos.'), findsOneWidget);
    expect(repository.calls, 1);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.byType(ProductCard), findsWidgets);
    expect(find.text('No pudimos cargar los productos.'), findsNothing);
  });

  testWidgets('muestra estado vacío con acción para modificar búsqueda', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductResultsScreen(repository: FakeProductRepository.empty()),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No encontramos productos.'), findsOneWidget);
    expect(find.text('Modificar búsqueda'), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);

    await tester.tap(find.text('Modificar búsqueda'));
    await tester.pumpAndSettle();

    expect(find.byType(GiftSearchScreen), findsOneWidget);
  });

  testWidgets('loading no desborda en pantalla móvil pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeProductRepository(
      products: mockProducts,
      delay: const Duration(milliseconds: 100),
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductResultsScreen(repository: repository)),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Cargando…'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('error no desborda en pantalla móvil pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductResultsScreen(repository: FakeProductRepository.error()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('No pudimos cargar los productos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('vacío no desborda en pantalla móvil pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductResultsScreen(repository: FakeProductRepository.empty()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('No encontramos productos.'), findsOneWidget);
    expect(find.text('Modificar búsqueda'), findsOneWidget);
  });

  testWidgets('no desborda en pantalla móvil pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const criteria = GiftSearchCriteria(
      occasion: 'Cumpleaños',
      recipient: 'Un destinatario con nombre largo',
      maxBudget: 1000,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductResultsScreen(
          criteria: criteria,
          repository: FakeProductRepository.success(mockProducts),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsOneWidget);
  });
}
