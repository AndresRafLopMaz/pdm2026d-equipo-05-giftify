import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/features/addresses/screens/address_list_screen.dart';
import 'package:giftify/features/home/screens/home_screen.dart';

import 'helpers/fake_address_repository.dart';

Future<ProviderContainer> _pumpHomeScreen(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const HomeScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ),
  );

  return container;
}

void main() {
  testWidgets('renderiza Home y su CTA principal', (tester) async {
    await _pumpHomeScreen(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Giftify'), findsOneWidget);
    expect(find.text('Encuentra el regalo ideal'), findsOneWidget);
    expect(find.text('Buscar un regalo'), findsOneWidget);
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Carrito'), findsOneWidget);
    expect(find.text('Mis direcciones'), findsOneWidget);
  });

  testWidgets('el CTA navega de Home a Search mediante el provider', (
    tester,
  ) async {
    final container = await _pumpHomeScreen(tester);

    await tester.tap(find.byKey(const ValueKey('home-search-action')));
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.search);
  });

  testWidgets('Catálogo cambia a la pestaña Catálogo mediante el provider', (
    tester,
  ) async {
    final container = await _pumpHomeScreen(tester);

    await tester.tap(find.byKey(const ValueKey('home-catalog-action')));
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.catalog);
  });

  testWidgets('Carrito cambia a la pestaña Carrito mediante el provider', (
    tester,
  ) async {
    final container = await _pumpHomeScreen(tester);

    await tester.tap(find.byKey(const ValueKey('home-cart-action')));
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.cart);
  });

  testWidgets('Home no desborda en pantalla movil de 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpHomeScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('Mis direcciones navega al CRUD de direcciones', (tester) async {
    final repository = FakeAddressRepository();

    await _pumpHomeScreen(
      tester,
      overrides: [addressRepositoryProvider.overrideWithValue(repository)],
    );

    final addresses = find.byKey(const ValueKey('home-addresses-action'));
    await tester.ensureVisible(addresses);
    await tester.pumpAndSettle();
    await tester.tap(addresses);
    await tester.pumpAndSettle();

    expect(find.byType(AddressListScreen), findsOneWidget);
  });
}
