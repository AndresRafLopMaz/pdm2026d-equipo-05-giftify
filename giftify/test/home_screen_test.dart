import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/features/home/screens/home_screen.dart';

Future<ProviderContainer> _pumpHomeScreen(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomeScreen()),
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
}
