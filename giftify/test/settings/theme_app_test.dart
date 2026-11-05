import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/giftify_app.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';
import 'package:giftify/features/settings/data/theme_preference_store.dart';
import 'package:giftify/features/settings/providers/theme_controller.dart';
import 'package:giftify/features/settings/providers/theme_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_harness.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeThemeStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = _FakeThemeStore();
  });

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    required ThemeMode initial,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferenceStoreProvider.overrideWithValue(store),
          initialThemeModeProvider.overrideWithValue(initial),
        ],
        child: const GiftifyApp(),
      ),
    );
    await tester.pumpAndSettle();

    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Brightness currentBrightness(WidgetTester tester) {
    return Theme.of(tester.element(find.byType(Scaffold).first)).brightness;
  }

  testWidgets('initial light renderiza Light Theme', (tester) async {
    await pumpApp(tester, initial: ThemeMode.light);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(currentBrightness(tester), Brightness.light);
  });

  testWidgets('initial dark renderiza Dark Theme', (tester) async {
    await pumpApp(tester, initial: ThemeMode.dark);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(currentBrightness(tester), Brightness.dark);
  });

  testWidgets('system sigue platform dark y light', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await pumpApp(tester, initial: ThemeMode.system);
    expect(currentBrightness(tester), Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(currentBrightness(tester), Brightness.light);
  });

  testWidgets('ThemeController actualiza MaterialApp inmediatamente', (
    tester,
  ) async {
    final container = await pumpApp(tester, initial: ThemeMode.light);

    await container
        .read(themeControllerProvider.notifier)
        .setMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(currentBrightness(tester), Brightness.dark);
  });

  testWidgets('logout conserva dark en Login', (tester) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    store.mode = ThemeMode.dark;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          themePreferenceStoreProvider.overrideWithValue(store),
          initialThemeModeProvider.overrideWithValue(ThemeMode.dark),
        ],
        child: const GiftifyApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('profile-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile-logout-button')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(currentBrightness(tester), Brightness.dark);
    expect(store.mode, ThemeMode.dark);
  });
}
