import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/addresses/data/address_book.dart';
import 'package:giftify/features/addresses/data/address_repository.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/shared/models/delivery_address.dart';

import 'helpers/fake_address_repository.dart';

const _casa = DeliveryAddress(
  id: 'addr-casa',
  label: 'Casa',
  recipientName: 'María López',
  addressLine: '5a avenida 10-20, zona 1',
  city: 'Guatemala',
  department: 'Guatemala',
  isDefault: true,
);

const _anterior = DeliveryAddress(
  id: 'addr-anterior',
  label: 'Anterior',
  recipientName: 'María López',
  addressLine: '10a calle 2-30, zona 3',
  city: 'Mixco',
  department: 'Guatemala',
  isArchived: true,
);

AddressDraft _draft(String label) {
  return AddressDraft(
    label: label,
    recipientName: 'María López',
    addressLine: '5a avenida 10-20, zona 1',
    city: 'Guatemala',
    department: 'Guatemala',
  );
}

void main() {
  test('expone loading y luego data', () async {
    final gate = Completer<void>();
    final repository = FakeAddressRepository(initial: const [_casa])
      ..loadGate = gate;
    final container = _containerWith(repository);
    addTearDown(container.dispose);

    expect(container.read(addressesProvider).isLoading, isTrue);

    gate.complete();
    final book = await container.read(addressesProvider.future);

    expect(book.active.single.id, _casa.id);
    expect(container.read(addressesProvider).hasValue, isTrue);
  });

  test('separa direcciones activas y archivadas', () async {
    final repository = FakeAddressRepository(initial: const [_casa, _anterior]);
    final container = _containerWith(repository);
    addTearDown(container.dispose);

    final book = await container.read(addressesProvider.future);

    expect(book.active.single.id, _casa.id);
    expect(book.archived.single.id, _anterior.id);
    expect(book.defaultAddressId, _casa.id);
  });

  test(
    'expone error sin retry automático y permite reintento manual',
    () async {
      final repository = FakeAddressRepository(
        loadError: StateError('Fallo de lectura'),
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await expectLater(
        container.read(addressesProvider.future),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(addressesProvider).hasError, isTrue);
      expect(repository.loadCount, 1);

      repository.loadError = null;
      container.invalidate(addressesProvider);
      final book = await container.read(addressesProvider.future);

      expect(book.isEmpty, isTrue);
      expect(repository.loadCount, 2);
    },
  );

  test('cada mutación exitosa invalida y recarga el repository', () async {
    final repository = FakeAddressRepository();
    final container = _containerWith(repository);
    addTearDown(container.dispose);
    await container.read(addressesProvider.future);
    expect(repository.loadCount, 1);

    final notifier = container.read(addressesProvider.notifier);
    final casa = await notifier.createAddress(_draft('Casa'));
    expect(repository.loadCount, 2);

    final trabajo = await notifier.createAddress(_draft('Trabajo'));
    expect(repository.loadCount, 3);

    await notifier.updateAddress(trabajo.id, _draft('Oficina'));
    expect(repository.loadCount, 4);

    await notifier.setDefaultAddress(trabajo.id);
    expect(repository.loadCount, 5);

    await notifier.archiveAddress(casa.id);
    expect(repository.loadCount, 6);

    await notifier.restoreAddress(casa.id);
    expect(repository.loadCount, 7);

    await notifier.archiveAddress(casa.id);
    await notifier.deleteAddress(casa.id);
    expect(repository.loadCount, 9);

    final book = container.read(addressesProvider).requireValue;
    expect(book.addresses.single.id, trabajo.id);
    expect(book.addresses.single.label, 'Oficina');
  });

  test('una mutación fallida conserva los datos cargados', () async {
    final repository = FakeAddressRepository(initial: const [_casa]);
    final container = _containerWith(repository);
    addTearDown(container.dispose);
    final initial = await container.read(addressesProvider.future);

    await expectLater(
      container.read(addressesProvider.notifier).createAddress(_draft('casa')),
      throwsA(isA<DuplicateAddressLabelException>()),
    );

    final current = container.read(addressesProvider).requireValue;
    expect(current.addresses, initial.addresses);
    expect(current.addresses.single.id, _casa.id);
    expect(repository.loadCount, 1);
  });
}

ProviderContainer _containerWith(AddressRepository repository) {
  final container = ProviderContainer(
    overrides: [addressRepositoryProvider.overrideWithValue(repository)],
  );
  container.listen(addressesProvider, (_, _) {});
  return container;
}
