import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/settings/data/theme_preference_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('sin valor devuelve system', () async {
    final store = SharedPreferencesThemePreferenceStore();

    expect(await store.read(), ThemeMode.system);
  });

  test('lee system, light y dark', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesThemePreferenceStore(preferences);

    for (final mode in ThemeMode.values) {
      await preferences.setString(
        SharedPreferencesThemePreferenceStore.storageKey,
        mode.name,
      );
      expect(await store.read(), mode);
    }
  });

  test('valor corrupto devuelve system', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      SharedPreferencesThemePreferenceStore.storageKey,
      'sepia',
    );

    final store = SharedPreferencesThemePreferenceStore(preferences);

    expect(await store.read(), ThemeMode.system);
  });

  test('save persiste y recrear store conserva el valor', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesThemePreferenceStore(preferences);

    await store.save(ThemeMode.dark);

    final reopened = SharedPreferencesThemePreferenceStore(preferences);
    expect(await reopened.read(), ThemeMode.dark);
    expect(
      preferences.getString(SharedPreferencesThemePreferenceStore.storageKey),
      'dark',
    );
  });

  test('quitar la sesión no elimina la preferencia de tema', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesThemePreferenceStore(preferences);
    await store.save(ThemeMode.light);
    await preferences.setString('giftify.session_user_id', '1');

    await preferences.remove('giftify.session_user_id');

    expect(await store.read(), ThemeMode.light);
  });
}
