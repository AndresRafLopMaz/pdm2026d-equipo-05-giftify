import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/addresses/data/address_book.dart';
import 'package:giftify/features/addresses/data/address_repository.dart';
import 'package:giftify/features/addresses/screens/address_form_screen.dart';
import 'package:giftify/shared/models/delivery_address.dart';

const _labelKey = ValueKey('address-label-field');
const _recipientKey = ValueKey('address-recipient-field');
const _addressLineKey = ValueKey('address-line-field');
const _cityKey = ValueKey('address-city-field');
const _departmentKey = ValueKey('address-department-field');
const _referenceKey = ValueKey('address-reference-field');
const _defaultSwitchKey = ValueKey('address-default-switch');
const _submitKey = ValueKey('address-submit-button');

Future<void> _pumpForm(
  WidgetTester tester, {
  DeliveryAddress? initialAddress,
  required Future<void> Function(AddressDraft draft) onSubmit,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AddressFormScreen(
        initialAddress: initialAddress,
        onSubmit: onSubmit,
      ),
    ),
  );
}

Future<void> _fillRequired(
  WidgetTester tester, {
  String label = 'Casa',
  String recipient = 'María López',
  String addressLine = '5a avenida 10-20, zona 1',
  String city = 'Guatemala',
  String department = 'Guatemala',
  String reference = '',
}) async {
  await tester.enterText(find.byKey(_labelKey), label);
  await tester.enterText(find.byKey(_recipientKey), recipient);
  await tester.enterText(find.byKey(_addressLineKey), addressLine);
  await tester.enterText(find.byKey(_cityKey), city);
  await tester.enterText(find.byKey(_departmentKey), department);
  await tester.enterText(find.byKey(_referenceKey), reference);
}

void main() {
  testWidgets('crear valida los campos y envía datos recortados', (
    tester,
  ) async {
    AddressDraft? submitted;
    await _pumpForm(
      tester,
      onSubmit: (draft) async {
        submitted = draft;
      },
    );

    expect(find.text('Nueva dirección'), findsOneWidget);
    expect(find.text('Guardar dirección'), findsOneWidget);

    await tester.ensureVisible(find.byKey(_submitKey));
    await tester.tap(find.byKey(_submitKey));
    await tester.pump();

    expect(
      find.text('Ingresa un nombre para identificar la dirección.'),
      findsOneWidget,
    );
    expect(find.text('Ingresa el nombre del destinatario.'), findsOneWidget);
    expect(find.text('Ingresa la dirección.'), findsOneWidget);
    expect(find.text('Ingresa la ciudad.'), findsOneWidget);
    expect(find.text('Ingresa el departamento.'), findsOneWidget);

    await _fillRequired(tester, label: '  Casa  ', reference: '   ');
    await tester.ensureVisible(find.byKey(_submitKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_submitKey));
    await tester.pumpAndSettle();

    expect(submitted, isNotNull);
    expect(submitted!.label, 'Casa');
    expect(submitted!.recipientName, 'María López');
    expect(submitted!.addressLine, '5a avenida 10-20, zona 1');
    expect(submitted!.city, 'Guatemala');
    expect(submitted!.department, 'Guatemala');
    expect(submitted!.reference, '');
    expect(submitted!.isDefault, isFalse);
    expect(find.byType(AddressFormScreen), findsNothing);
  });

  testWidgets('editar abre lleno, conserva la principal y guarda cambios', (
    tester,
  ) async {
    const initial = DeliveryAddress(
      id: 'addr-casa',
      label: 'Casa',
      recipientName: 'María López',
      addressLine: '5a avenida 10-20, zona 1',
      city: 'Guatemala',
      department: 'Guatemala',
      reference: 'Portón verde',
      isDefault: true,
    );

    AddressDraft? submitted;
    await _pumpForm(
      tester,
      initialAddress: initial,
      onSubmit: (draft) async {
        submitted = draft;
      },
    );

    expect(find.text('Editar dirección'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);

    final labelField = tester.widget<TextFormField>(find.byKey(_labelKey));
    final cityField = tester.widget<TextFormField>(find.byKey(_cityKey));
    expect(labelField.controller!.text, 'Casa');
    expect(cityField.controller!.text, 'Guatemala');

    final defaultSwitch = tester.widget<SwitchListTile>(
      find.byKey(_defaultSwitchKey),
    );
    expect(defaultSwitch.value, isTrue);
    expect(defaultSwitch.onChanged, isNull);
    expect(find.text('Esta es la dirección principal.'), findsOneWidget);

    await tester.enterText(find.byKey(_labelKey), 'Casa de mamá');
    await tester.enterText(find.byKey(_cityKey), 'Mixco');
    await tester.ensureVisible(find.byKey(_submitKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_submitKey));
    await tester.pumpAndSettle();

    expect(submitted!.label, 'Casa de mamá');
    expect(submitted!.city, 'Mixco');
    expect(submitted!.isDefault, isTrue);
    expect(find.byType(AddressFormScreen), findsNothing);
  });

  testWidgets('permite marcar como principal una dirección nueva', (
    tester,
  ) async {
    AddressDraft? submitted;
    await _pumpForm(
      tester,
      onSubmit: (draft) async {
        submitted = draft;
      },
    );

    await _fillRequired(tester);
    await tester.ensureVisible(find.byKey(_defaultSwitchKey));
    await tester.tap(find.byKey(_defaultSwitchKey));
    await tester.pump();

    await tester.ensureVisible(find.byKey(_submitKey));
    await tester.tap(find.byKey(_submitKey));
    await tester.pumpAndSettle();

    expect(submitted!.isDefault, isTrue);
  });

  testWidgets('muestra el mensaje humano cuando la etiqueta está duplicada', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      onSubmit: (_) async {
        throw const DuplicateAddressLabelException();
      },
    );

    await _fillRequired(tester, label: 'casa');
    await tester.ensureVisible(find.byKey(_submitKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_submitKey));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Ya existe una dirección con ese nombre.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Usa otro nombre para identificarla.'),
      findsOneWidget,
    );
    expect(find.byType(AddressFormScreen), findsOneWidget);
  });

  testWidgets('AddressForm es responsive y soporta text scale', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final size in const [Size(320, 640), Size(390, 844), Size(800, 800)]) {
      for (final scale in const [1.3, 2.0]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;

        await _pumpForm(tester, onSubmit: (_) async {});
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byKey(_submitKey), findsOneWidget);
      }
    }
  });

  testWidgets('una archivada no puede marcarse como principal', (tester) async {
    const initial = DeliveryAddress(
      id: 'addr-archivada',
      label: 'Anterior',
      recipientName: 'María López',
      addressLine: '5a avenida 10-20, zona 1',
      city: 'Guatemala',
      department: 'Guatemala',
      isArchived: true,
    );

    await _pumpForm(tester, initialAddress: initial, onSubmit: (_) async {});

    final defaultSwitch = tester.widget<SwitchListTile>(
      find.byKey(_defaultSwitchKey),
    );
    expect(defaultSwitch.value, isFalse);
    expect(defaultSwitch.onChanged, isNull);
    expect(find.text('Restaura la dirección para usarla.'), findsOneWidget);
  });
}
