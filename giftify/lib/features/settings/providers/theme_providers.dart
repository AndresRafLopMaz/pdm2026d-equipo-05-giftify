import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_preference_store.dart';

final themePreferenceStoreProvider = Provider<ThemePreferenceStore>((ref) {
  return SharedPreferencesThemePreferenceStore();
});

final initialThemeModeProvider = Provider<ThemeMode>((ref) {
  return ThemeMode.system;
});
