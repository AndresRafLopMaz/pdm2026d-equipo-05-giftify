import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/auth_gate.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/auth/screens/register_screen.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpRegister(
    WidgetTester tester,
    AuthTestHarness harness, {
    VoidCallback? onLogin,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          theme: appTheme,
          home: RegisterScreen(onLogin: onLogin ?? () {}),
        ),
      ),
    );
  }

  Future<void> fillRegister(
    WidgetTester tester, {
    String name = 'Ana López',
    String email = 'ana@mail.com',
    String password = 'contrasena-123',
    String? confirmPassword,
  }) async {
    await tester.enterText(find.byKey(const ValueKey('register-name')), name);
    await tester.enterText(find.byKey(const ValueKey('register-email')), email);
    await tester.enterText(
      find.byKey(const ValueKey('register-password')),
      password,
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password')),
      confirmPassword ?? password,
    );
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.byKey(const ValueKey('register-submit'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
  }

  testWidgets('renderiza Register V2 sin fecha de nacimiento', (tester) async {
    await pumpRegister(tester, AuthTestHarness());

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Crear cuenta'), findsWidgets);
    expect(find.byKey(const ValueKey('register-name')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-password')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('register-confirm-password')),
      findsOneWidget,
    );
    expect(find.text('Fecha de nacimiento'), findsNothing);
    expect(find.text('¿Ya tienes cuenta? Inicia sesión'), findsOneWidget);
  });

  testWidgets('valida campos vacíos', (tester) async {
    await pumpRegister(tester, AuthTestHarness());

    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu nombre.'), findsOneWidget);
    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(find.text('Confirma tu contraseña.'), findsOneWidget);
  });

  testWidgets('valida email, longitud y confirmación', (tester) async {
    await pumpRegister(tester, AuthTestHarness());

    await fillRegister(tester, email: 'ana@', password: 'corta12');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener al menos 8 caracteres.'),
      findsOneWidget,
    );

    await fillRegister(
      tester,
      password: 'contrasena-123',
      confirmPassword: 'otra-clave-123',
    );
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
  });

  testWidgets('alterna mostrar y ocultar ambas contraseñas', (tester) async {
    await pumpRegister(tester, AuthTestHarness());
    final passwordField = find.byKey(const ValueKey('register-password'));
    final confirmField = find.byKey(
      const ValueKey('register-confirm-password'),
    );
    await tester.ensureVisible(confirmField);
    await tester.pumpAndSettle();

    EditableText editableText(Finder field) => tester.widget<EditableText>(
      find.descendant(of: field, matching: find.byType(EditableText)),
    );

    expect(editableText(passwordField).obscureText, isTrue);
    expect(editableText(confirmField).obscureText, isTrue);

    await tester.tap(
      find.descendant(of: passwordField, matching: find.byType(IconButton)),
    );
    await tester.tap(
      find.descendant(of: confirmField, matching: find.byType(IconButton)),
    );
    await tester.pump();

    expect(editableText(passwordField).obscureText, isFalse);
    expect(editableText(confirmField).obscureText, isFalse);
  });

  testWidgets('registro exitoso llega a MainShell sin stack extra', (
    tester,
  ) async {
    final harness = AuthTestHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: const MaterialApp(
          home: AuthGate(initialView: AuthView.register),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await fillRegister(tester);
    await submit(tester);
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
    expect(navigator.canPop(), isFalse);
    expect(harness.session.userId, isNotNull);
  });

  testWidgets('email duplicado muestra mensaje humano', (tester) async {
    final harness = AuthTestHarness();
    harness.repository.seedUser(name: 'Ana', email: 'ana@mail.com');
    await pumpRegister(tester, harness);

    await fillRegister(tester);
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ya existe una cuenta con este correo.'), findsOneWidget);
    expect(harness.session.userId, isNull);
  });

  testWidgets('error de almacenamiento muestra mensaje humano', (tester) async {
    final harness = AuthTestHarness();
    harness.repository.failWrites = true;
    await pumpRegister(tester, harness);

    await fillRegister(tester);
    await submit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos guardar tu cuenta. Intenta nuevamente.'),
      findsOneWidget,
    );
  });

  testWidgets('Inicia sesión invoca el cambio de vista', (tester) async {
    var opened = false;
    await pumpRegister(
      tester,
      AuthTestHarness(),
      onLogin: () {
        opened = true;
      },
    );

    await tester.tap(find.byKey(const ValueKey('register-login')));
    await tester.pump();

    expect(opened, isTrue);
  });

  testWidgets('es responsive en 320x640 sin overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRegister(tester, AuthTestHarness());

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    final submitButton = find.byKey(const ValueKey('register-submit'));
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    expect(submitButton.hitTestable(), findsOneWidget);
  });

  testWidgets('soporta text scale 2.0', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpRegister(tester, AuthTestHarness());

    final submitButton = find.byKey(const ValueKey('register-submit'));
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(submitButton.hitTestable(), findsOneWidget);
  });
}
