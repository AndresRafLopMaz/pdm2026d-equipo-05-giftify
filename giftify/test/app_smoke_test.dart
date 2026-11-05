import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/giftify_app.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Giftify inicia en Login sin sesión', (tester) async {
    final harness = AuthTestHarness();
    await tester.pumpWidget(
      ProviderScope(overrides: harness.overrides, child: const GiftifyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('el stack inicial no contiene una ruta desconocida', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    await tester.pumpWidget(
      ProviderScope(overrides: harness.overrides, child: const GiftifyApp()),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(navigator.canPop(), isFalse);
    expect(find.text('Ruta no encontrada'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(find.text('Ruta no encontrada'), findsNothing);
  });

  testWidgets('con sesión válida inicia en MainShell sin ruta desconocida', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
    );
    harness.session.userId = user.id;

    await tester.pumpWidget(
      ProviderScope(overrides: harness.overrides, child: const GiftifyApp()),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(find.byType(MainShell), findsOneWidget);
    expect(navigator.canPop(), isFalse);
    expect(find.text('Ruta no encontrada'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Ruta no encontrada'), findsNothing);
  });

  testWidgets('una ruta realmente desconocida conserva el fallback', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          initialRoute: '/ruta-inexistente',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ruta no encontrada'), findsOneWidget);
  });
}
