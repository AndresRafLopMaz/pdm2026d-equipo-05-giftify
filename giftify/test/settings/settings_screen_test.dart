import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/settings/data/theme_preference_store.dart';
import 'package:giftify/features/settings/providers/theme_providers.dart';
import 'package:giftify/features/settings/screens/settings_screen.dart';

class _FakeThemeStore implements ThemePreferenceStore {
  ThemeMode mode = ThemeMode.system;
  bool failSave = false;

  @override
  Future<ThemeMode> read() async => mode;

  @override
  Future<void> save(ThemeMode mode) async {
    if (failSave) {
      throw const ThemePersistenceException();
    }
    this.mode = mode;
  }
}

void main() {
  late _FakeThemeStore store;

  setUp(() {
    store = _FakeThemeStore();
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    ThemeMode initial = ThemeMode.system,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferenceStoreProvider.overrideWithValue(store),
          initialThemeModeProvider.overrideWithValue(initial),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ThemeMode selectedMode(WidgetTester tester) {
    return tester
        .widget<RadioGroup<ThemeMode>>(find.byType(RadioGroup<ThemeMode>))
        .groupValue!;
  }

  testWidgets('muestra Apariencia y por defecto Sistema', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);
    expect(selectedMode(tester), ThemeMode.system);
  });

  testWidgets('selecciona Claro y persiste', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.byKey(const ValueKey('theme-option-light')));
    await tester.pumpAndSettle();

    expect(selectedMode(tester), ThemeMode.light);
    expect(store.mode, ThemeMode.light);
  });

  testWidgets('selecciona Oscuro y Sistema', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.byKey(const ValueKey('theme-option-dark')));
    await tester.pumpAndSettle();
    expect(selectedMode(tester), ThemeMode.dark);
    expect(store.mode, ThemeMode.dark);

    await tester.tap(find.byKey(const ValueKey('theme-option-system')));
    await tester.pumpAndSettle();
    expect(selectedMode(tester), ThemeMode.system);
    expect(store.mode, ThemeMode.system);
  });

  testWidgets('revierte y muestra SnackBar si falla la persistencia', (
    tester,
  ) async {
    store.failSave = true;
    await pumpSettings(tester, initial: ThemeMode.light);

    await tester.tap(find.byKey(const ValueKey('theme-option-dark')));
    await tester.pumpAndSettle();

    expect(selectedMode(tester), ThemeMode.light);
    expect(
      find.text('No pudimos guardar tu preferencia de apariencia.'),
      findsOneWidget,
    );
  });

  testWidgets('las opciones exponen semántica', (tester) async {
    final semantics = tester.ensureSemantics();

    await pumpSettings(tester);

    expect(find.bySemanticsLabel(RegExp('Sistema')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Claro')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Oscuro')), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('es responsive en 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSettings(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-option-dark')), findsOneWidget);
  });

  testWidgets('soporta text scale 2.0', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpSettings(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Sistema'), findsOneWidget);
  });
}
