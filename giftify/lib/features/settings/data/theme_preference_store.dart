import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePersistenceException implements Exception {
  const ThemePersistenceException();
}

abstract class ThemePreferenceStore {
  Future<ThemeMode> read();

  Future<void> save(ThemeMode mode);
}

class SharedPreferencesThemePreferenceStore implements ThemePreferenceStore {
  SharedPreferencesThemePreferenceStore([this._preferences]);

  static const String storageKey = 'giftify.theme_mode';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ?? await SharedPreferences.getInstance();
  }

  @override
  Future<ThemeMode> read() async {
    try {
      final preferences = await _prefs;
      return switch (preferences.getString(storageKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      return ThemeMode.system;
    }
  }

  @override
  Future<void> save(ThemeMode mode) async {
    final preferences = await _prefs;
    final saved = await preferences.setString(storageKey, mode.name);
    if (!saved) {
      throw const ThemePersistenceException();
    }
  }
}
