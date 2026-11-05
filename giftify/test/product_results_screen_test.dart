import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/products/data/product_repository.dart';
import 'package:giftify/features/products/providers/products_provider.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/features/products/screens/product_results_screen.dart';
import 'package:giftify/features/products/utils/product_filters.dart';
import 'package:giftify/features/products/widgets/product_card.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_category.dart';
import 'package:giftify/shared/enums/gift_occasion.dart';
import 'package:giftify/shared/enums/gift_recipient.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

import 'helpers/fake_product_repository.dart';

Widget _testApp({
  required Widget home,
  ProductRepository? repository,
  RouteFactory? onGenerateRoute,
}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        productRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: appTheme,
      home: home,
      onGenerateRoute: onGenerateRoute,
    ),
  );
}

Future<void> _pumpResults(
  WidgetTester tester, {
  required FakeProductRepository repository,
  GiftSearchCriteria? criteria,
}) async {
  await tester.pumpWidget(
    _testApp(
      home: ProductResultsScreen(criteria: criteria),
      repository: repository,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openFilters(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('results-filter-button')));
  await tester.pumpAndSettle();
}

Future<void> _closeFilters(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('filters-close-button')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin criterios muestra el catálogo general', (tester) async {
    await _pumpResults(
      tester,
      repository: FakeProductRepository.success(mockProducts),
    );

    expect(find.byType(ProductCard), findsWidgets);
    expect(find.text('Resultados'), findsOneWidget);
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Filtrar'), findsOneWidget);
  });

  testWidgets('con criterios renderiza resultados y resumen compacto', (
    tester,
  ) async {
    const criteria = GiftSearchCriteria(
      occasion: GiftOccasion.birthday,
      recipientType: GiftRecipient.friend,
      maxBudget: 1000,
    );

    await _pumpResults(
      tester,
      repository: FakeProductRepository.success(mockProducts),
      criteria: criteria,
    );

    expect(find.textContaining('Para Amigo/a'), findsOneWidget);
    expect(find.textContaining('hasta Q1000.00'), findsOneWidget);
    expect(find.text('Cambiar'), findsOneWidget);
    expect(find.byType(ProductCard), findsWidgets);
  });

  testWidgets('muestra estado informativo cuando no hay resultados', (
    tester,
  ) async {
    const criteria = GiftSearchCriteria(
      occasion: GiftOccasion.birthday,
      recipientType: GiftRecipient.friend,
      maxBudget: 1,
    );

    await tester.pumpWidget(
      _testApp(
        home: const ProductResultsScreen(criteria: criteria),
        repository: FakeProductRepository.success(mockProducts),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No encontramos productos.'), findsOneWidget);
    expect(find.text('Modificar búsqueda'), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);
  });

  testWidgets('Modificar búsqueda cambia a Search cuando no puede hacer pop', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        home: const ProductResultsScreen(),
        repository: FakeProductRepository.empty(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Modificar búsqueda'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProductResultsScreen)),
      listen: false,
    );
    expect(container.read(appTabProvider), AppTab.search);
  });

  testWidgets('al pulsar una fila navega al detalle con el producto', (
    tester,
  ) async {
    const criteria = GiftSearchCriteria(
      occasion: GiftOccasion.birthday,
      recipientType: GiftRecipient.friend,
      maxBudget: 1000,
    );
    final expected = filterAndPrioritizeProducts(mockProducts, criteria).first;

    await tester.pumpWidget(
      _testApp(
        home: const ProductResultsScreen(criteria: criteria),
        repository: FakeProductRepository.success(mockProducts),
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

  testWidgets('desde MainShell, tap en Catálogo abre el detalle y vuelve', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        home: const MainShell(),
        repository: FakeProductRepository.success(mockProducts),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Catálogo'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProductCard), findsWidgets);

    final firstCard = tester.widget<ProductCard>(
      find.byType(ProductCard).first,
    );

    await tester.tap(find.byType(ProductCard).first);
    await tester.pumpAndSettle();

    final detail = tester.widget<ProductDetailScreen>(
      find.byType(ProductDetailScreen),
    );

    expect(detail.product, same(firstCard.product));
    expect(find.text(firstCard.product.name), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsNothing);
    expect(find.byType(ProductCard), findsWidgets);
    expect(find.text('Ruta no encontrada'), findsNothing);
  });

  testWidgets('muestra loading mientras el repositorio responde', (
    tester,
  ) async {
    final repository = FakeProductRepository(
      products: mockProducts,
      delay: const Duration(milliseconds: 100),
    );

    await tester.pumpWidget(
      _testApp(home: const ProductResultsScreen(), repository: repository),
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
      _testApp(
        home: const ProductResultsScreen(),
        repository: FakeProductRepository.error(),
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
      _testApp(home: const ProductResultsScreen(), repository: repository),
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

  testWidgets('cambiar filtro actualiza el listado y reconsulta', (
    tester,
  ) async {
    final repository = FakeProductRepository.success(mockProducts);
    await _pumpResults(tester, repository: repository);

    expect(repository.calls, 1);

    await _openFilters(tester);
    await tester.tap(find.byKey(const ValueKey('filter-category-Joyería')));
    await tester.pumpAndSettle();
    await _closeFilters(tester);

    final cards = tester.widgetList<ProductCard>(find.byType(ProductCard));
    expect(cards, isNotEmpty);
    expect(
      cards.every((card) => card.product.category == GiftCategory.jewelry),
      isTrue,
    );
    expect(repository.calls, greaterThan(1));
    expect(find.text('Recargar'), findsNothing);
  });

  testWidgets('filtro sin coincidencias muestra empty y Limpiar filtros', (
    tester,
  ) async {
    final repository = FakeProductRepository.success(mockProducts);
    await _pumpResults(tester, repository: repository);

    await _openFilters(tester);
    await tester.tap(find.byKey(const ValueKey('filter-category-Joyería')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('filter-availability-outOfStock')),
    );
    await tester.pumpAndSettle();
    await _closeFilters(tester);

    expect(find.text('No encontramos productos.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('clear-product-filters-empty')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('clear-product-filters-empty')));
    await tester.pumpAndSettle();

    expect(find.byType(ProductCard), findsWidgets);
  });

  testWidgets('Dismissible usa el id del producto como key', (tester) async {
    await _pumpResults(
      tester,
      repository: FakeProductRepository.success(mockProducts),
    );

    final firstCard = tester.widget<ProductCard>(
      find.byType(ProductCard).first,
    );
    final dismissible = tester.widget<Dismissible>(
      find.byType(Dismissible).first,
    );

    expect(dismissible.key, ValueKey(firstCard.product.id));
  });

  testWidgets('swipe elimina y Deshacer restaura el mismo producto', (
    tester,
  ) async {
    final repository = FakeProductRepository.success(mockProducts);
    await _pumpResults(tester, repository: repository);

    final firstCard = tester.widget<ProductCard>(
      find.byType(ProductCard).first,
    );
    final productId = firstCard.product.id;

    await tester.drag(find.byType(ProductCard).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(find.text('Producto eliminado.'), findsOneWidget);
    expect(
      tester
          .widgetList<ProductCard>(find.byType(ProductCard))
          .any((card) => card.product.id == productId),
      isFalse,
    );

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    final restored = tester
        .widgetList<ProductCard>(find.byType(ProductCard))
        .where((card) => card.product.id == productId);
    expect(restored, isNotEmpty);
  });

  testWidgets('si delete falla, la fila permanece y se informa', (
    tester,
  ) async {
    final repository = FakeProductRepository.success(
      mockProducts,
      deleteError: Exception('fallo al eliminar'),
    );
    await _pumpResults(tester, repository: repository);

    final firstCard = tester.widget<ProductCard>(
      find.byType(ProductCard).first,
    );
    final productId = firstCard.product.id;

    await tester.drag(find.byType(ProductCard).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(
      tester
          .widgetList<ProductCard>(find.byType(ProductCard))
          .any((card) => card.product.id == productId),
      isTrue,
    );
    expect(
      find.text('No se pudo eliminar el producto. Inténtalo de nuevo.'),
      findsOneWidget,
    );
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
      _testApp(home: const ProductResultsScreen(), repository: repository),
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
      _testApp(
        home: const ProductResultsScreen(),
        repository: FakeProductRepository.error(),
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
      _testApp(
        home: const ProductResultsScreen(),
        repository: FakeProductRepository.empty(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('No encontramos productos.'), findsOneWidget);
  });

  testWidgets('no desborda en pantalla móvil pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const criteria = GiftSearchCriteria(
      occasion: GiftOccasion.birthday,
      recipientType: GiftRecipient.friend,
      maxBudget: 1000,
    );

    await tester.pumpWidget(
      _testApp(
        home: const ProductResultsScreen(criteria: criteria),
        repository: FakeProductRepository.success(mockProducts),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsOneWidget);
  });
}
