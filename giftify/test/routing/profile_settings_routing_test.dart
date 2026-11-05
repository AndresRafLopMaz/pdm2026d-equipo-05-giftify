import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/giftify_app.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';
import 'package:giftify/features/profile/screens/profile_screen.dart';
import 'package:giftify/features/settings/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  AuthTestHarness authenticatedHarness() {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana López',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;
    return harness;
  }

  Future<void> pumpApp(WidgetTester tester, AuthTestHarness harness) async {
    await tester.pumpWidget(
      ProviderScope(overrides: harness.overrides, child: const GiftifyApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Settings vuelve a Profile y Profile vuelve a MainShell', (
    tester,
  ) async {
    await pumpApp(tester, authenticatedHarness());
    expect(find.byType(MainShell), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-button')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-settings')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
  });

  testWidgets('logout desde Profile limpia el stack y no revela MainShell', (
    tester,
  ) async {
    final harness = authenticatedHarness();
    await pumpApp(tester, harness);
    await tester.tap(find.byKey(const ValueKey('profile-button')));
    await tester.pumpAndSettle();

    final logoutButton = find.byKey(const ValueKey('profile-logout-button'));
    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(MainShell), findsNothing);
    expect(harness.session.userId, isNull);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(MainShell), findsNothing);
    expect(find.text('Ruta no encontrada'), findsNothing);
  });

  testWidgets('deep link /profile sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.profile,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
  });

  testWidgets('deep link /settings sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.settings,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });

  testWidgets('deep link /profile con sesión muestra Profile', (tester) async {
    final harness = authenticatedHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.profile,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('ana@mail.com'), findsOneWidget);
  });

  testWidgets('deep link /settings con sesión muestra Settings', (
    tester,
  ) async {
    final harness = authenticatedHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.settings,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
  });
}
