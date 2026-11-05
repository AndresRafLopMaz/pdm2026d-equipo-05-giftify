import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/features/addresses/screens/address_form_screen.dart';
import 'package:giftify/features/addresses/screens/address_list_screen.dart';
import 'package:giftify/shared/models/delivery_address.dart';

import 'helpers/fake_address_repository.dart';

DeliveryAddress _address(
  String id,
  String label, {
  bool isDefault = false,
  bool isArchived = false,
  String recipient = 'María López',
  String addressLine = '5a avenida 10-20, zona 1',
  String city = 'Guatemala',
  String department = 'Guatemala',
  String? reference,
}) {
  return DeliveryAddress(
    id: id,
    label: label,
    recipientName: recipient,
    addressLine: addressLine,
    city: city,
    department: department,
    reference: reference,
    isDefault: isDefault,
    isArchived: isArchived,
  );
}

Future<void> _pumpList(
  WidgetTester tester,
  FakeAddressRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [addressRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: AddressListScreen()),
    ),
  );
}

Future<void> _fillForm(
  WidgetTester tester, {
  String label = 'Casa',
  String recipient = 'María López',
  String addressLine = '5a avenida 10-20, zona 1',
  String city = 'Guatemala',
  String department = 'Guatemala',
}) async {
  await tester.enterText(
    find.byKey(const ValueKey('address-label-field')),
    label,
  );
  await tester.enterText(
    find.byKey(const ValueKey('address-recipient-field')),
    recipient,
  );
  await tester.enterText(
    find.byKey(const ValueKey('address-line-field')),
    addressLine,
  );
  await tester.enterText(
    find.byKey(const ValueKey('address-city-field')),
    city,
  );
  await tester.enterText(
    find.byKey(const ValueKey('address-department-field')),
    department,
  );
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final submit = find.byKey(const ValueKey('address-submit-button'));
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(ValueKey('address-menu-$id')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lista, abre el formulario lleno, edita y conserva el id', (
    tester,
  ) async {
    final repository = FakeAddressRepository(
      initial: [_address('addr-casa', 'Casa', isDefault: true)],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('address-card-addr-casa')));
    await tester.pumpAndSettle();

    expect(find.byType(AddressFormScreen), findsOneWidget);
    expect(find.text('Editar dirección'), findsOneWidget);

    final labelField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('address-label-field')),
    );
    expect(labelField.controller!.text, 'Casa');

    await tester.enterText(
      find.byKey(const ValueKey('address-label-field')),
      'Casa de mamá',
    );
    await tester.enterText(
      find.byKey(const ValueKey('address-line-field')),
      'Nueva dirección 123',
    );
    await _tapSubmit(tester);

    expect(find.byType(AddressFormScreen), findsNothing);
    expect(find.text('Casa de mamá'), findsOneWidget);
    expect(find.text('Nueva dirección 123'), findsOneWidget);
    expect(repository.addresses.single.id, 'addr-casa');
    expect(repository.addresses.single.label, 'Casa de mamá');
    expect(repository.loadCount, greaterThanOrEqualTo(2));
  });

  testWidgets('crear agrega la dirección y la primera queda principal', (
    tester,
  ) async {
    final repository = FakeAddressRepository();

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('No tienes direcciones guardadas.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-address-button')));
    await tester.pumpAndSettle();

    expect(find.text('Nueva dirección'), findsOneWidget);
    await _fillForm(tester);
    await _tapSubmit(tester);

    expect(repository.addresses, hasLength(1));
    expect(repository.addresses.single.label, 'Casa');
    expect(repository.addresses.single.isDefault, isTrue);
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);
  });

  testWidgets('un duplicado muestra el mensaje humano y no crea otra', (
    tester,
  ) async {
    final repository = FakeAddressRepository(
      initial: [_address('addr-casa', 'Casa', isDefault: true)],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-address-button')));
    await tester.pumpAndSettle();

    await _fillForm(tester, label: 'casa');
    await _tapSubmit(tester);

    expect(
      find.textContaining('Ya existe una dirección con ese nombre.'),
      findsOneWidget,
    );
    expect(find.byType(AddressFormScreen), findsOneWidget);
    expect(repository.addresses, hasLength(1));
  });

  testWidgets('eliminar la principal muestra el bloqueo y permite archivarla', (
    tester,
  ) async {
    final repository = FakeAddressRepository(
      initial: [_address('addr-casa', 'Casa', isDefault: true)],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    await _openMenu(tester, 'addr-casa');
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Dirección en uso'), findsOneWidget);
    expect(
      find.textContaining(
        'No puedes eliminar la dirección principal porque está en uso.',
      ),
      findsOneWidget,
    );
    expect(repository.addresses, hasLength(1));

    await tester.tap(find.byKey(const ValueKey('in-use-archive')));
    await tester.pumpAndSettle();

    expect(repository.addresses.single.isArchived, isTrue);
    expect(repository.addresses.single.isDefault, isFalse);

    await tester.tap(find.byKey(const ValueKey('addresses-tab-archived')));
    await tester.pumpAndSettle();
    expect(find.text('Casa'), findsOneWidget);
  });

  testWidgets('archiva y restaura una dirección no principal', (tester) async {
    final repository = FakeAddressRepository(
      initial: [
        _address('addr-casa', 'Casa', isDefault: true),
        _address('addr-trabajo', 'Trabajo'),
      ],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    await _openMenu(tester, 'addr-trabajo');
    await tester.tap(find.text('Archivar'));
    await tester.pumpAndSettle();

    expect(
      repository.addresses
          .firstWhere((address) => address.id == 'addr-trabajo')
          .isArchived,
      isTrue,
    );
    expect(find.text('Trabajo'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('addresses-tab-archived')));
    await tester.pumpAndSettle();
    expect(find.text('Trabajo'), findsOneWidget);

    await _openMenu(tester, 'addr-trabajo');
    await tester.tap(find.text('Restaurar'));
    await tester.pumpAndSettle();

    expect(
      repository.addresses
          .firstWhere((address) => address.id == 'addr-trabajo')
          .isArchived,
      isFalse,
    );
    expect(find.text('No tienes direcciones archivadas.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('addresses-tab-active')));
    await tester.pumpAndSettle();
    expect(find.text('Trabajo'), findsOneWidget);
  });

  testWidgets('elimina una activa no principal', (tester) async {
    final repository = FakeAddressRepository(
      initial: [
        _address('addr-casa', 'Casa', isDefault: true),
        _address('addr-trabajo', 'Trabajo'),
      ],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    await _openMenu(tester, 'addr-trabajo');
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(repository.addresses, hasLength(1));
    expect(repository.addresses.single.id, 'addr-casa');
    expect(find.text('Trabajo'), findsNothing);
    expect(find.text('Dirección eliminada.'), findsOneWidget);
  });

  testWidgets('elimina definitivamente una dirección archivada', (
    tester,
  ) async {
    final repository = FakeAddressRepository(
      initial: [
        _address('addr-casa', 'Casa', isDefault: true),
        _address('addr-anterior', 'Anterior', isArchived: true),
      ],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('addresses-tab-archived')));
    await tester.pumpAndSettle();

    await _openMenu(tester, 'addr-anterior');
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(repository.addresses, hasLength(1));
    expect(repository.addresses.single.id, 'addr-casa');
    expect(find.text('No tienes direcciones archivadas.'), findsOneWidget);
    expect(find.text('Dirección eliminada.'), findsOneWidget);
  });

  testWidgets('la lista no desborda en pantalla móvil de 320x640', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeAddressRepository(
      initial: [_address('addr-casa', 'Casa', isDefault: true)],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Casa'), findsOneWidget);
  });

  testWidgets('cambia la dirección principal desde la tarjeta', (tester) async {
    final repository = FakeAddressRepository(
      initial: [
        _address('addr-casa', 'Casa', isDefault: true),
        _address('addr-trabajo', 'Trabajo'),
      ],
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    await _openMenu(tester, 'addr-trabajo');
    await tester.tap(find.text('Usar como principal'));
    await tester.pumpAndSettle();

    final trabajo = repository.addresses.firstWhere(
      (address) => address.id == 'addr-trabajo',
    );
    final casa = repository.addresses.firstWhere(
      (address) => address.id == 'addr-casa',
    );
    expect(trabajo.isDefault, isTrue);
    expect(casa.isDefault, isFalse);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('address-card-addr-trabajo')),
        matching: find.text('Principal'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('muestra loading mientras carga', (tester) async {
    final gate = Completer<void>();
    final repository = FakeAddressRepository(
      initial: [_address('addr-casa', 'Casa', isDefault: true)],
    )..loadGate = gate;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [addressRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: AddressListScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('addresses-loading')), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text('Casa'), findsOneWidget);
  });

  testWidgets('muestra error y Reintentar recarga las direcciones', (
    tester,
  ) async {
    final repository = FakeAddressRepository(
      initial: [_address('addr-casa', 'Casa', isDefault: true)],
      loadError: Exception('fallo simulado'),
    );

    await _pumpList(tester, repository);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('addresses-error')), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(repository.loadCount, 1);

    repository.loadError = null;
    await tester.tap(find.byKey(const ValueKey('retry-addresses')));
    await tester.pumpAndSettle();

    expect(find.text('Casa'), findsOneWidget);
    expect(repository.loadCount, 2);
  });
}
