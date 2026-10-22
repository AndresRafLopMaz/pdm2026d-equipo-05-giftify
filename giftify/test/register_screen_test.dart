import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/features/auth/screens/register_screen.dart';
import 'package:giftify/features/home/screens/home_screen.dart';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _pumpRegisterScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        initialRoute: AppRoutes.register,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillValidData(WidgetTester tester) async {
  await tester.enterText(_field('Nombre'), 'Diego Barrios');
  await tester.enterText(_field('Correo electrónico'), 'diego@correo.com');
  await tester.enterText(_field('Contraseña'), 'contrasena123');
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final Finder submit = find.text('Regístrate');
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
}

Future<void> _selectBirthDate(WidgetTester tester) async {
  final Finder dateField = _field('Fecha de nacimiento');
  await tester.ensureVisible(dateField);
  await tester.pumpAndSettle();
  await tester.tap(dateField);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Aceptar'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  testWidgets('renderiza el formulario de registro', (tester) async {
    await _pumpRegisterScreen(tester);

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Crea Una\nNueva Cuenta'), findsOneWidget);
    expect(_field('Nombre'), findsOneWidget);
    expect(_field('Correo electrónico'), findsOneWidget);
    expect(_field('Contraseña'), findsOneWidget);
    expect(_field('Fecha de nacimiento'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
    expect(find.text('¿Ya tienes una cuenta?'), findsOneWidget);
    expect(find.text('Inicia sesión aquí'), findsOneWidget);
  });

  testWidgets('el formulario vacío muestra validaciones y no navega', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu nombre.'), findsOneWidget);
    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(find.text('Selecciona tu fecha de nacimiento.'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('un correo inválido muestra error de formato', (tester) async {
    await _pumpRegisterScreen(tester);

    await tester.enterText(_field('Nombre'), 'Diego Barrios');
    await tester.enterText(_field('Correo electrónico'), 'diego@');
    await tester.enterText(_field('Contraseña'), 'contrasena123');

    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('una contraseña corta muestra error de longitud', (tester) async {
    await _pumpRegisterScreen(tester);

    await tester.enterText(_field('Nombre'), 'Diego Barrios');
    await tester.enterText(_field('Correo electrónico'), 'diego@correo.com');
    await tester.enterText(_field('Contraseña'), 'corta12');

    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('La contraseña debe tener al menos 8 caracteres.'),
      findsOneWidget,
    );
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('el botón alterna mostrar y ocultar la contraseña', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    final Finder passwordField = _field('Contraseña');
    await tester.ensureVisible(passwordField);
    await tester.pumpAndSettle();

    EditableText editableText() => tester.widget<EditableText>(
      find.descendant(of: passwordField, matching: find.byType(EditableText)),
    );

    expect(editableText().obscureText, isTrue);

    final Finder toggle = find.descendant(
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

  testWidgets('el campo de fecha abre el selector de fecha', (tester) async {
    await _pumpRegisterScreen(tester);

    final Finder dateField = _field('Fecha de nacimiento');
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('un registro válido muestra envío y navega a HomeScreen', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    await _fillValidData(tester);
    await _selectBirthDate(tester);

    await _tapSubmit(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final FilledButton button = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    expect(button.onPressed, isNull);
    expect(find.byType(HomeScreen), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });

  testWidgets('el enlace de inicio de sesión muestra un SnackBar', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester);

    await tester.tap(find.text('Inicia sesión aquí'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Inicio de sesión disponible próximamente.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'se adapta a 320x640 sin overflow y mantiene accesibles el formulario '
    'y el botón',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpRegisterScreen(tester);

      // Ausencia de overflow o excepciones en el primer render.
      expect(tester.takeException(), isNull);

      // La fila de inicio de sesión se mantiene dentro del formulario.
      expect(find.text('¿Ya tienes una cuenta?'), findsOneWidget);
      expect(find.text('Inicia sesión aquí'), findsOneWidget);

      final Rect formRect = tester.getRect(find.byType(Form));
      final Rect labelRect = tester.getRect(
        find.text('¿Ya tienes una cuenta?'),
      );
      final Rect linkRect = tester.getRect(find.text('Inicia sesión aquí'));

      expect(labelRect.left, greaterThanOrEqualTo(formRect.left));
      expect(labelRect.right, lessThanOrEqualTo(formRect.right));
      expect(linkRect.left, greaterThanOrEqualTo(formRect.left));
      expect(linkRect.right, lessThanOrEqualTo(formRect.right));

      // El formulario permanece dentro del contenedor desplazable.
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(_field('Nombre'), findsOneWidget);
      expect(_field('Correo electrónico'), findsOneWidget);
      expect(_field('Contraseña'), findsOneWidget);
      expect(_field('Fecha de nacimiento'), findsOneWidget);

      // El botón de registro sigue accesible mediante scroll.
      final Finder submit = find.text('Regístrate');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(submit.hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.byType(FilledButton)).bottom,
        lessThanOrEqualTo(640),
      );
    },
  );
}
