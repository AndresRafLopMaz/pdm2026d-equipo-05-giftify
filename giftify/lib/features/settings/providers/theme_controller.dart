import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_providers.dart';

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.read(initialThemeModeProvider);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) {
      return;
    }

    final previous = state;
    state = mode;

    try {
      await ref.read(themePreferenceStoreProvider).save(mode);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
