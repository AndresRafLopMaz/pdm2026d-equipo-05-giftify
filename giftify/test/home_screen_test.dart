import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/core/theme/app_theme.dart';
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
        theme: appTheme,
        home: const HomeScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ),
  );

  return container;
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  testWidgets('renderiza Home como dashboard de descubrimiento', (
    tester,
  ) async {
    await _pumpHomeScreen(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Giftify'), findsOneWidget);
    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('¿A quién quieres sorprender?'), findsOneWidget);
    expect(find.text('Buscar el regalo ideal'), findsOneWidget);
    expect(find.text('Explora'), findsOneWidget);
    expect(find.text('Cumpleaños'), findsOneWidget);
    expect(find.text('Pareja'), findsOneWidget);
    expect(find.text('Familia'), findsOneWidget);
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Mi carrito'), findsOneWidget);
    expect(find.text('Direcciones'), findsOneWidget);
    expect(find.text('Ideas para regalar'), findsOneWidget);
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

    final action = find.byKey(const ValueKey('home-catalog-action'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.catalog);
  });

  testWidgets('Carrito cambia a la pestaña Carrito mediante el provider', (
    tester,
  ) async {
    final container = await _pumpHomeScreen(tester);

    final action = find.byKey(const ValueKey('home-cart-action'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.cart);
  });

  testWidgets('el banner editorial lleva al Catálogo', (tester) async {
    final container = await _pumpHomeScreen(tester);

    final action = find.byKey(const ValueKey('home-editorial-catalog-action'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pump();

    expect(container.read(appTabProvider), AppTab.catalog);
  });

  testWidgets('las categorías son editoriales y no interactivas', (
    tester,
  ) async {
    await _pumpHomeScreen(tester);

    for (final category in [
      'Cumpleaños',
      'Pareja',
      'Familia',
      'Amigos',
      'Tecnología',
      'Experiencias',
    ]) {
      final label = find.text(category);
      expect(label, findsOneWidget);
      expect(
        find.ancestor(of: label, matching: find.byType(InkWell)),
        findsNothing,
      );
      expect(
        find.ancestor(of: label, matching: find.byType(FilterChip)),
        findsNothing,
      );
      expect(
        find.ancestor(of: label, matching: find.byType(GestureDetector)),
        findsNothing,
      );
    }
  });

  testWidgets('los accesos rápidos son botones semánticos reales', (
    tester,
  ) async {
    await _pumpHomeScreen(tester);

    expect(
      find.bySemanticsLabel('Catálogo. Explora todos los regalos'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Mi carrito. Revisa lo que guardaste'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Direcciones. Administra tus entregas'),
      findsOneWidget,
    );
  });

  testWidgets('no muestra nombre falso ni funciones futuras', (tester) async {
    await _pumpHomeScreen(tester);

    expect(find.text('Hola'), findsOneWidget);

    for (final name in ['Andrés', 'Catherine', 'Diego', 'Brayan']) {
      expect(find.textContaining(name), findsNothing);
    }

    for (final futureText in [
      'Perfil',
      'Settings',
      'Configuración',
      'Métodos de pago',
      'Cerrar sesión',
    ]) {
      expect(find.text(futureText), findsNothing);
    }
  });

  testWidgets('Home no desborda en pantalla movil de 320x640', (tester) async {
    _setViewport(tester, const Size(320, 640));

    await _pumpHomeScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  for (final size in const [Size(390, 844), Size(412, 915), Size(800, 800)]) {
    testWidgets('Home no desborda en ${size.width}x${size.height}', (
      tester,
    ) async {
      _setViewport(tester, size);

      await _pumpHomeScreen(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  }

  testWidgets('Home soporta text scale 1.3', (tester) async {
    _setViewport(tester, const Size(390, 844));
    _setTextScale(tester, 1.3);

    await _pumpHomeScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('¿A quién quieres sorprender?'), findsOneWidget);
  });

  testWidgets('Home soporta text scale 2.0 en 320x640', (tester) async {
    _setViewport(tester, const Size(320, 640));
    _setTextScale(tester, 2.0);

    await _pumpHomeScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
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
