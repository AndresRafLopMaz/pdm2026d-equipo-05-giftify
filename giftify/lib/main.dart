import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/giftify_app.dart';
import 'features/settings/data/theme_preference_store.dart';
import 'features/settings/providers/theme_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final themeStore = SharedPreferencesThemePreferenceStore(preferences);
  final initialThemeMode = await themeStore.read();

  runApp(
    ProviderScope(
      overrides: [
        themePreferenceStoreProvider.overrideWithValue(themeStore),
        initialThemeModeProvider.overrideWithValue(initialThemeMode),
      ],
      child: const GiftifyApp(),
    ),
  );
}
