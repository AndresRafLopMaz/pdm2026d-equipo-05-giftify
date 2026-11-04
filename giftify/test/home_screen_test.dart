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
    expect(find.text('ENCUENTRA TU REGALO PERFECTO'), findsOneWidget);
    expect(find.text('Encontrar tu regalo'), findsOneWidget);
  });

  testWidgets('el CTA navega de Home a Search mediante el provider', (
    tester,
  ) async {
    final container = await _pumpHomeScreen(tester);

    final cta = find.text('Encontrar tu regalo');
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.search);
  });

  testWidgets('Ver todo cambia a la pestaña Catálogo mediante el provider', (
    tester,
  ) async {
    final container = await _pumpHomeScreen(tester);

    final verTodo = find.text('Ver todo');
    await tester.ensureVisible(verTodo);
    await tester.pumpAndSettle();
    await tester.tap(verTodo);
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.catalog);
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

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mis direcciones'));
    await tester.pumpAndSettle();

    expect(find.byType(AddressListScreen), findsOneWidget);
  });
}
