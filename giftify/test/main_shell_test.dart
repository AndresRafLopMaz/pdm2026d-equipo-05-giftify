import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/auth/providers/current_user_provider.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';

import 'helpers/ownership_test_overrides.dart';

Future<ProviderContainer> _pumpShell(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      ...overrides,
      currentUserIdProvider.overrideWithValue(1),
      ownershipNotNeededOverride,
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MainShell()),
    ),
  );
  await tester.pumpAndSettle();

  return container;
}

Finder _destination(String label) {
  return find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
}

int _stackIndex(WidgetTester tester) {
  return tester
      .widget<IndexedStack>(find.byKey(const ValueKey('main-shell-stack')))
      .index!;
}

Future<void> _tapDestination(WidgetTester tester, String label) async {
  await tester.tap(_destination(label));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('MainShell inicia en Inicio', (tester) async {
    final container = await _pumpShell(tester);

    expect(container.read(appTabProvider), AppTab.home);
    expect(_stackIndex(tester), AppTab.home.index);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('MainShell muestra exactamente cuatro tabs y no Próximamente', (
    tester,
  ) async {
    await _pumpShell(tester);

    for (final label in ['Inicio', 'Buscar', 'Catálogo', 'Carrito']) {
      expect(_destination(label), findsOneWidget);
    }
    expect(find.text('Próximamente'), findsNothing);
  });

  testWidgets('cada NavigationDestination cambia la pestaña', (tester) async {
    final container = await _pumpShell(tester);

    await _tapDestination(tester, 'Buscar');
    expect(container.read(appTabProvider), AppTab.search);
    expect(_stackIndex(tester), AppTab.search.index);

    await _tapDestination(tester, 'Catálogo');
    expect(container.read(appTabProvider), AppTab.catalog);
    expect(_stackIndex(tester), AppTab.catalog.index);

    await _tapDestination(tester, 'Carrito');
    expect(container.read(appTabProvider), AppTab.cart);
    expect(_stackIndex(tester), AppTab.cart.index);
    expect(find.byType(CartScreen), findsOneWidget);

    await _tapDestination(tester, 'Inicio');
    expect(container.read(appTabProvider), AppTab.home);
    expect(_stackIndex(tester), AppTab.home.index);
  });

  testWidgets('el CTA principal abre la pestaña Buscar', (tester) async {
    final container = await _pumpShell(tester);

    final action = find.byKey(const ValueKey('home-search-action'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(container.read(appTabProvider), AppTab.search);
    expect(_stackIndex(tester), AppTab.search.index);
  });

  testWidgets('Catálogo de Home abre la pestaña Catálogo', (tester) async {
    final container = await _pumpShell(tester);

    final action = find.byKey(const ValueKey('home-catalog-action'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(container.read(appTabProvider), AppTab.catalog);
    expect(_stackIndex(tester), AppTab.catalog.index);
  });

  testWidgets('el carrito persistido se ve al abrir la tab Carrito', (
    tester,
  ) async {
    final product = mockProducts.first;
    final store = InMemoryCartStore([
      CartEntry(productId: product.id, quantity: 2),
    ]);
    final container = await _pumpShell(
      tester,
      overrides: [
        cartRepositoryProvider.overrideWithValue(
          PersistentCartRepository(store: store),
        ),
      ],
    );

    await _tapDestination(tester, 'Carrito');

    expect(container.read(appTabProvider), AppTab.cart);
    expect(find.text(product.name), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(ValueKey('quantity-${product.id}'))).data,
      '2',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('cart-total'))).data,
      'Q 250.00',
    );
  });

  testWidgets('IndexedStack conserva el scroll de Catálogo', (tester) async {
    await _pumpShell(tester);
    await _tapDestination(tester, 'Catálogo');

    final resultsList = find.byKey(const PageStorageKey('results-list'));
    final scrollable = find
        .descendant(of: resultsList, matching: find.byType(Scrollable))
        .first;

    expect(scrollable, findsOneWidget);

    await tester.drag(resultsList, const Offset(0, -400));
    await tester.pumpAndSettle();

    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(before, greaterThan(0));

    await _tapDestination(tester, 'Inicio');
    await _tapDestination(tester, 'Catálogo');

    final after = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(after, before);
  });
}
