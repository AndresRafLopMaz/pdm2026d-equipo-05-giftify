import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/auth_gate.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpLogin(
    WidgetTester tester,
    AuthTestHarness harness, {
    VoidCallback? onCreateAccount,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          theme: appTheme,
          home: LoginScreen(onCreateAccount: onCreateAccount ?? () {}),
        ),
      ),
    );
  }

  Future<void> fillLogin(
    WidgetTester tester, {
    String email = 'ana@mail.com',
    String password = 'contrasena-123',
  }) async {
    await tester.enterText(find.byKey(const ValueKey('login-email')), email);
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      password,
    );
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.byKey(const ValueKey('login-submit'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
  }

  testWidgets('renderiza Login', (tester) async {
    await pumpLogin(tester, AuthTestHarness());

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-password')), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Crear cuenta'), findsOneWidget);
    expect(find.text('Olvidé mi contraseña'), findsNothing);
  });

  testWidgets('valida campos vacíos', (tester) async {
    await pumpLogin(tester, AuthTestHarness());

    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('valida formato de correo', (tester) async {
    await pumpLogin(tester, AuthTestHarness());

    await fillLogin(tester, email: 'ana@');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
  });

  testWidgets('alterna mostrar y ocultar contraseña', (tester) async {
    await pumpLogin(tester, AuthTestHarness());
    final passwordField = find.byKey(const ValueKey('login-password'));
    await tester.ensureVisible(passwordField);
    await tester.pumpAndSettle();

    EditableText editableText() => tester.widget<EditableText>(
      find.descendant(of: passwordField, matching: find.byType(EditableText)),
    );

    expect(editableText().obscureText, isTrue);

    final toggle = find.descendant(
      of: passwordField,
      matching: find.byType(IconButton),
    );
    await tester.tap(toggle);
    await tester.pump();
    expect(editableText().obscureText, isFalse);

    await tester.tap(toggle);
    await tester.pump();
    expect(editableText().obscureText, isTrue);
  });

  testWidgets('login exitoso llega a MainShell sin stack extra', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    await harness.seedUserWithPassword(
      name: 'Ana',
      email: 'ana@mail.com',
      password: 'contrasena-123',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(theme: appTheme, home: const AuthGate()),
      ),
    );
    await tester.pumpAndSettle();
    await fillLogin(tester);
    await submit(tester);
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(find.byType(MainShell), findsOneWidget);
    expect(navigator.canPop(), isFalse);
    expect(harness.session.userId, isNotNull);
  });

  testWidgets('credenciales incorrectas muestran error genérico', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    await harness.seedUserWithPassword(
      name: 'Ana',
      email: 'ana@mail.com',
      password: 'contrasena-123',
    );
    await pumpLogin(tester, harness);

    await fillLogin(tester, password: 'incorrecta');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(harness.session.userId, isNull);
  });

  testWidgets('error de almacenamiento muestra mensaje humano', (tester) async {
    final harness = AuthTestHarness();
    await harness.seedUserWithPassword(
      name: 'Ana',
      email: 'ana@mail.com',
      password: 'contrasena-123',
    );
    harness.session.failWrite = true;
    await pumpLogin(tester, harness);

    await fillLogin(tester);
    await submit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos iniciar sesión. Intenta nuevamente.'),
      findsOneWidget,
    );
  });

  testWidgets('Crear cuenta invoca el cambio de vista', (tester) async {
    var opened = false;
    await pumpLogin(
      tester,
      AuthTestHarness(),
      onCreateAccount: () {
        opened = true;
      },
    );

    await tester.tap(find.byKey(const ValueKey('login-create-account')));
    await tester.pump();

    expect(opened, isTrue);
  });

  testWidgets('es responsive en 320x640 sin overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpLogin(tester, AuthTestHarness());

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    final submitButton = find.byKey(const ValueKey('login-submit'));
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    expect(submitButton.hitTestable(), findsOneWidget);
  });

  testWidgets('soporta text scale 2.0', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpLogin(tester, AuthTestHarness());

    final submitButton = find.byKey(const ValueKey('login-submit'));
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(submitButton.hitTestable(), findsOneWidget);
  });
}
