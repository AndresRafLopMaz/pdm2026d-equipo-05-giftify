import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/settings/data/theme_preference_store.dart';
import 'package:giftify/features/settings/providers/theme_controller.dart';
import 'package:giftify/features/settings/providers/theme_providers.dart';

class _FakeThemeStore implements ThemePreferenceStore {
  ThemeMode mode = ThemeMode.system;
  bool failSave = false;
  int saves = 0;

  @override
  Future<ThemeMode> read() async => mode;

  @override
  Future<void> save(ThemeMode mode) async {
    if (failSave) {
      throw const ThemePersistenceException();
    }
    saves += 1;
    this.mode = mode;
  }
}

void main() {
  late _FakeThemeStore store;

  ProviderContainer containerFor(ThemeMode initial) {
    final container = ProviderContainer(
      overrides: [
        themePreferenceStoreProvider.overrideWithValue(store),
        initialThemeModeProvider.overrideWithValue(initial),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    store = _FakeThemeStore();
  });

  test('inicia con la preferencia precargada', () {
    final container = containerFor(ThemeMode.dark);

    expect(container.read(themeControllerProvider), ThemeMode.dark);
  });

  test('cambia y persiste light, dark y system', () async {
    final container = containerFor(ThemeMode.system);
    final controller = container.read(themeControllerProvider.notifier);

    await controller.setMode(ThemeMode.light);
    expect(container.read(themeControllerProvider), ThemeMode.light);
    expect(store.mode, ThemeMode.light);

    await controller.setMode(ThemeMode.dark);
    expect(container.read(themeControllerProvider), ThemeMode.dark);
    expect(store.mode, ThemeMode.dark);

    await controller.setMode(ThemeMode.system);
    expect(container.read(themeControllerProvider), ThemeMode.system);
    expect(store.mode, ThemeMode.system);
    expect(store.saves, 3);
  });

  test('revierte el estado si falla la persistencia', () async {
    final container = containerFor(ThemeMode.light);
    final controller = container.read(themeControllerProvider.notifier);
    store.failSave = true;

    await expectLater(
      controller.setMode(ThemeMode.dark),
      throwsA(isA<ThemePersistenceException>()),
    );

    expect(container.read(themeControllerProvider), ThemeMode.light);
  });
}
