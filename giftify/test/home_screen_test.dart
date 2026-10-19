import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/features/home/screens/home_screen.dart';
import 'package:giftify/features/search/screens/gift_search_screen.dart';

Future<void> _pumpHomeScreen(
  WidgetTester tester, {
  ValueChanged<RouteSettings>? onRoute,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        onRoute?.call(settings);

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const GiftSearchScreen(),
        );
      },
    ),
  );
}

void main() {
  testWidgets('renderiza Home y su CTA principal', (tester) async {
    await _pumpHomeScreen(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('ENCUENTRA TU REGALO PERFECTO'), findsOneWidget);
    expect(find.text('Encontrar tu regalo'), findsOneWidget);
  });

  testWidgets('el CTA navega de Home a Search', (tester) async {
    RouteSettings? capturedSettings;
    await _pumpHomeScreen(
      tester,
      onRoute: (settings) => capturedSettings = settings,
    );

    final cta = find.text('Encontrar tu regalo');
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(capturedSettings?.name, AppRoutes.search);
    expect(find.byType(GiftSearchScreen), findsOneWidget);
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
