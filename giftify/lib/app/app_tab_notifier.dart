import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_tab.dart';

/// Estado de la pestaña principal seleccionada.
class AppTabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) {
    state = tab;
  }
}

final appTabProvider = NotifierProvider<AppTabNotifier, AppTab>(
  AppTabNotifier.new,
);
