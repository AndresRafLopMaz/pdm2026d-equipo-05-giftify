import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/features/search/screens/gift_search_screen.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

Finder _textField(String label) => find.widgetWithText(TextFormField, label);

Finder _dropdownField(String label) =>
    find.widgetWithText(DropdownButtonFormField<String>, label);

Future<void> _pumpSearchScreen(
  WidgetTester tester, {
  ValueChanged<RouteSettings>? onResults,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const GiftSearchScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.productResults) {
          onResults?.call(settings);
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(body: Text('Destino de prueba')),
        );
      },
    ),
  );
}

Future<void> _selectDropdown(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = _dropdownField(label);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

Future<void> _fillRequiredFields(
  WidgetTester tester, {
  required String budget,
  String occasion = 'Cumpleaños',
  String recipient = 'Amigo/a',
}) async {
  await _selectDropdown(tester, 'Ocasión *', occasion);
  await _selectDropdown(tester, 'Destinatario *', recipient);
  await tester.enterText(_textField('Presupuesto máximo *'), budget);
}

Future<void> _submit(WidgetTester tester) async {
  final button = find.text('Buscar regalos');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renderiza los seis campos y el CTA de busqueda', (tester) async {
    await _pumpSearchScreen(tester);

    expect(_dropdownField('Ocasión *'), findsOneWidget);
    expect(_dropdownField('Destinatario *'), findsOneWidget);
    expect(_textField('Presupuesto máximo *'), findsOneWidget);
    expect(_textField('Fecha (opcional)'), findsOneWidget);
    expect(_dropdownField('Tipo de regalo (opcional)'), findsOneWidget);
    expect(_dropdownField('Tamaño (opcional)'), findsOneWidget);
    expect(find.text('Buscar regalos'), findsOneWidget);
  });

  testWidgets('el formulario vacio muestra validaciones y no navega', (
    tester,
  ) async {
    RouteSettings? capturedSettings;
    await _pumpSearchScreen(
      tester,
      onResults: (settings) => capturedSettings = settings,
    );

    await _submit(tester);

    expect(find.text('Selecciona una ocasión.'), findsOneWidget);
    expect(find.text('Selecciona un destinatario.'), findsOneWidget);
    expect(find.text('Ingresa un presupuesto.'), findsOneWidget);
    expect(capturedSettings, isNull);
  });

  for (final testCase in const [
    (value: 'abc', error: 'Ingresa un monto válido.'),
    (value: '0', error: 'El presupuesto debe ser mayor que 0.'),
    (value: '-10', error: 'El presupuesto debe ser mayor que 0.'),
  ]) {
    testWidgets('rechaza el presupuesto ${testCase.value}', (tester) async {
      RouteSettings? capturedSettings;
      await _pumpSearchScreen(
        tester,
        onResults: (settings) => capturedSettings = settings,
      );
      await _fillRequiredFields(tester, budget: testCase.value);

      await _submit(tester);

      expect(find.text(testCase.error), findsOneWidget);
      expect(capturedSettings, isNull);
    });
  }

  testWidgets('acepta presupuesto con punto y fecha opcional null', (
    tester,
  ) async {
    RouteSettings? capturedSettings;
    await _pumpSearchScreen(
      tester,
      onResults: (settings) => capturedSettings = settings,
    );
    await _fillRequiredFields(tester, budget: '250.00');

    await _submit(tester);

    final criteria = capturedSettings?.arguments as GiftSearchCriteria;
    expect(capturedSettings?.name, AppRoutes.productResults);
    expect(criteria.maxBudget, 250.0);
    expect(criteria.eventDate, isNull);
  });

  testWidgets('acepta presupuesto con coma', (tester) async {
    RouteSettings? capturedSettings;
    await _pumpSearchScreen(
      tester,
      onResults: (settings) => capturedSettings = settings,
    );
    await _fillRequiredFields(tester, budget: '250,00');

    await _submit(tester);

    final criteria = capturedSettings?.arguments as GiftSearchCriteria;
    expect(capturedSettings?.name, AppRoutes.productResults);
    expect(criteria.maxBudget, 250.0);
  });

  testWidgets('construye los seis campos y los envia a Results', (
    tester,
  ) async {
    RouteSettings? capturedSettings;
    await _pumpSearchScreen(
      tester,
      onResults: (settings) => capturedSettings = settings,
    );
    await _fillRequiredFields(
      tester,
      budget: '325.50',
      occasion: 'Aniversario',
      recipient: 'Familiar',
    );
    await _selectDropdown(tester, 'Tipo de regalo (opcional)', 'Tecnología');
    await _selectDropdown(tester, 'Tamaño (opcional)', 'Mediano');

    final today = DateTime.now();
    final dateField = _textField('Fecha (opcional)');
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seleccionar'));
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(capturedSettings?.name, AppRoutes.productResults);
    expect(capturedSettings?.arguments, isA<GiftSearchCriteria>());

    final criteria = capturedSettings!.arguments! as GiftSearchCriteria;
    expect(criteria.occasion, 'Aniversario');
    expect(criteria.recipient, 'Familiar');
    expect(criteria.maxBudget, 325.5);
    expect(criteria.eventDate, DateTime(today.year, today.month, today.day));
    expect(criteria.giftType, 'Tecnología');
    expect(criteria.size, 'Mediano');
  });

  testWidgets('Search usa columna y no desborda en 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpSearchScreen(tester);

    final occasionCenter = tester.getCenter(_dropdownField('Ocasión *'));
    final recipientCenter = tester.getCenter(_dropdownField('Destinatario *'));
    expect(recipientCenter.dy, greaterThan(occasionCenter.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search usa filas y no desborda con ancho mayor a 620', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpSearchScreen(tester);

    final occasionCenter = tester.getCenter(_dropdownField('Ocasión *'));
    final recipientCenter = tester.getCenter(_dropdownField('Destinatario *'));
    expect(recipientCenter.dy, occasionCenter.dy);
    expect(recipientCenter.dx, greaterThan(occasionCenter.dx));
    expect(tester.takeException(), isNull);
  });
}
