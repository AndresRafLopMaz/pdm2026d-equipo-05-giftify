import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_tab.dart';
import 'package:giftify/app/app_tab_notifier.dart';
import 'package:giftify/app/giftify_app.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/features/auth/providers/auth_controller.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';
import 'package:giftify/features/products/providers/product_filter_provider.dart';
import 'package:giftify/features/search/models/search_prefill.dart';
import 'package:giftify/features/search/providers/search_prefill_provider.dart';
import 'package:giftify/features/settings/providers/theme_controller.dart';
import 'package:giftify/shared/enums/gift_category.dart';
import 'package:giftify/shared/enums/gift_occasion.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('logout reinicia tab, filtros y prefill sin borrar el tema', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GiftifyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);

    container.read(appTabProvider.notifier).select(AppTab.cart);
    container
        .read(productFilterProvider.notifier)
        .setCategory(GiftCategory.jewelry);
    container
        .read(searchPrefillProvider.notifier)
        .set(const SearchPrefill(occasion: GiftOccasion.birthday));
    await container
        .read(themeControllerProvider.notifier)
        .setMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    await container.read(authControllerProvider.notifier).logout();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(container.read(appTabProvider), AppTab.home);
    expect(container.read(productFilterProvider).isEmpty, isTrue);
    expect(container.read(searchPrefillProvider), isNull);
    expect(container.read(themeControllerProvider), ThemeMode.dark);

    await harness.seedUserWithPassword(
      name: 'Beto',
      email: 'beto@mail.com',
      password: 'password123',
    );
    await container
        .read(authControllerProvider.notifier)
        .login(email: 'beto@mail.com', password: 'password123');
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(container.read(appTabProvider), AppTab.home);
  });
}
