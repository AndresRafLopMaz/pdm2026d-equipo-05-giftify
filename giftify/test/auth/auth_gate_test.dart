import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/auth_gate.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';
import 'package:giftify/features/auth/screens/register_screen.dart';
import 'package:giftify/features/profile/screens/profile_screen.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpGate(
    WidgetTester tester,
    AuthTestHarness harness, {
    AuthView initialView = AuthView.login,
    Widget? authenticatedChild,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          home: AuthGate(
            initialView: initialView,
            authenticatedChild: authenticatedChild,
          ),
        ),
      ),
    );
  }

  testWidgets('muestra loading mientras restaura la sesión', (tester) async {
    final harness = AuthTestHarness();
    final completer = Completer<int?>();
    harness.session.readOverride = completer.future;

    await pumpGate(tester, harness);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('auth-loading-indicator')),
      findsOneWidget,
    );

    completer.complete(null);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('sin sesión muestra Login', (tester) async {
    final harness = AuthTestHarness();

    await pumpGate(tester, harness);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('con sesión válida muestra MainShell', (tester) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;

    await pumpGate(tester, harness);
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('muestra error de restauración y permite reintentar', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    harness.session.failRead = true;

    await pumpGate(tester, harness);
    await tester.pumpAndSettle();

    expect(find.text('No pudimos restaurar tu sesión.'), findsOneWidget);

    harness.session.failRead = false;
    await tester.tap(find.byKey(const ValueKey('auth-retry-button')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('AuthGate puede iniciar en Register', (tester) async {
    final harness = AuthTestHarness();

    await pumpGate(tester, harness, initialView: AuthView.register);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('logout desde Profile muestra Login y Back no revela MainShell', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;

    await pumpGate(tester, harness, authenticatedChild: const ProfileScreen());
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-logout-button')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(harness.session.userId, isNull);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(find.text('Ruta no encontrada'), findsNothing);
  });
}
