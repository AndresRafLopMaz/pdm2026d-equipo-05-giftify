import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/app/coming_soon_screen.dart';
import 'package:giftify/app/main_shell.dart';

Future<ProviderContainer> _pumpShell(WidgetTester tester) async {
  final container = ProviderContainer();
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

  testWidgets('cada NavigationDestination cambia la pestaña', (tester) async {
    final container = await _pumpShell(tester);

    await _tapDestination(tester, 'Buscar');
    expect(container.read(appTabProvider), AppTab.search);
    expect(_stackIndex(tester), AppTab.search.index);

    await _tapDestination(tester, 'Catálogo');
    expect(container.read(appTabProvider), AppTab.catalog);
    expect(_stackIndex(tester), AppTab.catalog.index);

    await _tapDestination(tester, 'Próximamente');
    expect(container.read(appTabProvider), AppTab.comingSoon);
    expect(_stackIndex(tester), AppTab.comingSoon.index);
    expect(find.byType(ComingSoonScreen), findsOneWidget);

    await _tapDestination(tester, 'Inicio');
    expect(container.read(appTabProvider), AppTab.home);
    expect(_stackIndex(tester), AppTab.home.index);
  });

  testWidgets('el CTA principal abre la pestaña Buscar', (tester) async {
    final container = await _pumpShell(tester);

    final cta = find.text('Encontrar tu regalo');
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(container.read(appTabProvider), AppTab.search);
    expect(_stackIndex(tester), AppTab.search.index);
  });

  testWidgets('Ver todo abre la pestaña Catálogo', (tester) async {
    final container = await _pumpShell(tester);

    final verTodo = find.text('Ver todo');
    await tester.ensureVisible(verTodo);
    await tester.pumpAndSettle();
    await tester.tap(verTodo);
    await tester.pumpAndSettle();

    expect(container.read(appTabProvider), AppTab.catalog);
    expect(_stackIndex(tester), AppTab.catalog.index);
  });

  testWidgets('IndexedStack conserva el scroll al cambiar de pestaña', (
    tester,
  ) async {
    await _pumpShell(tester);

    final homeScroll = find.byKey(const PageStorageKey('home-scroll'));
    final scrollable = find
        .descendant(of: homeScroll, matching: find.byType(Scrollable))
        .first;

    expect(scrollable, findsOneWidget);

    await tester.drag(homeScroll, const Offset(0, -400));
    await tester.pumpAndSettle();

    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(before, greaterThan(0));

    await _tapDestination(tester, 'Buscar');
    await _tapDestination(tester, 'Inicio');

    final after = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(after, before);
  });

  testWidgets('Próximamente muestra una pantalla real', (tester) async {
    await _pumpShell(tester);

    await _tapDestination(tester, 'Próximamente');

    expect(find.byType(ComingSoonScreen), findsOneWidget);
    expect(
      find.text('Estamos trabajando en esta sección de Giftify.'),
      findsOneWidget,
    );
  });
}
