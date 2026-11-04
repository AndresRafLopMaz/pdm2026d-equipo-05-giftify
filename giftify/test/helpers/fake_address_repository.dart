import 'dart:async';

import 'package:giftify/features/addresses/data/address_book.dart';
import 'package:giftify/features/addresses/data/address_repository.dart';
import 'package:giftify/shared/models/delivery_address.dart';

class FakeAddressRepository implements AddressRepository {
  FakeAddressRepository({
    List<DeliveryAddress> initial = const [],
    this.loadError,
  }) : _addresses = List<DeliveryAddress>.of(initial);

  final List<DeliveryAddress> _addresses;
  Object? loadError;
  Completer<void>? loadGate;
  int loadCount = 0;
  int _sequence = 0;

  List<DeliveryAddress> get addresses =>
      List<DeliveryAddress>.unmodifiable(_addresses);

  @override
  Future<AddressBook> loadBook() async {
    loadCount += 1;
    final gate = loadGate;
    if (gate != null) {
      await gate.future;
    }
    final error = loadError;
    if (error != null) {
      throw error;
    }
    return AddressBook(addresses: _addresses);
  }

  @override
  Future<DeliveryAddress> create(AddressDraft draft) async {
    final normalized = _normalize(draft);
    _ensureUnique(normalized.label);

    final makeDefault = normalized.isDefault || !_hasDefault;
    if (makeDefault) {
      _clearDefault();
    }

    _sequence += 1;
    final address = DeliveryAddress(
      id: 'fake-$_sequence',
      label: normalized.label,
      recipientName: normalized.recipientName,
      addressLine: normalized.addressLine,
      city: normalized.city,
      department: normalized.department,
      reference: normalized.reference,
      isDefault: makeDefault,
    );
    _addresses.add(address);
    return address;
  }

  @override
  Future<DeliveryAddress> update(String id, AddressDraft draft) async {
    final index = _indexOf(id);
    final existing = _addresses[index];
    final normalized = _normalize(draft);
    _ensureUnique(normalized.label, exceptId: id);

    if (existing.isArchived && normalized.isDefault) {
      throw const AddressValidationException(
        'Restaura la dirección antes de usarla como principal.',
      );
    }

    final makeDefault = normalized.isDefault || existing.isDefault;
    if (makeDefault && !existing.isDefault) {
      _clearDefault();
    }

    final updated = DeliveryAddress(
      id: existing.id,
      label: normalized.label,
      recipientName: normalized.recipientName,
      addressLine: normalized.addressLine,
      city: normalized.city,
      department: normalized.department,
      reference: normalized.reference,
      isDefault: makeDefault,
      isArchived: existing.isArchived,
    );
    _addresses[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final index = _indexOf(id);
    if (_addresses[index].isDefault) {
      throw const AddressInUseException();
    }
    _addresses.removeAt(index);
  }

  @override
  Future<void> archive(String id) async {
    final index = _indexOf(id);
    final existing = _addresses[index];
    if (existing.isArchived) {
      return;
    }

    final wasDefault = existing.isDefault;
    _addresses[index] = existing.copyWith(isArchived: true, isDefault: false);

    if (!wasDefault) {
      return;
    }

    final candidates =
        _addresses.where((address) => !address.isArchived).toList()..sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );

    if (candidates.isNotEmpty) {
      final nextIndex = _indexOf(candidates.first.id);
      _addresses[nextIndex] = _addresses[nextIndex].copyWith(isDefault: true);
    }
  }

  @override
  Future<void> restore(String id) async {
    final index = _indexOf(id);
    final existing = _addresses[index];
    if (!existing.isArchived) {
      return;
    }

    final hasDefault = _hasDefault;
    _addresses[index] = existing.copyWith(
      isArchived: false,
      isDefault: !hasDefault,
    );
  }

  @override
  Future<void> setDefault(String id) async {
    final index = _indexOf(id);
    final existing = _addresses[index];
    if (existing.isArchived) {
      throw const AddressValidationException(
        'No puedes usar como principal una dirección archivada.',
      );
    }
    if (existing.isDefault) {
      return;
    }

    _clearDefault();
    _addresses[index] = existing.copyWith(isDefault: true);
  }

  bool get _hasDefault =>
      _addresses.any((address) => address.isDefault && !address.isArchived);

  void _clearDefault() {
    for (var index = 0; index < _addresses.length; index += 1) {
      if (_addresses[index].isDefault) {
        _addresses[index] = _addresses[index].copyWith(isDefault: false);
      }
    }
  }

  int _indexOf(String id) {
    final index = _addresses.indexWhere((address) => address.id == id);
    if (index == -1) {
      throw const AddressNotFoundException();
    }
    return index;
  }

  void _ensureUnique(String label, {String? exceptId}) {
    final normalized = label.toLowerCase();
    final duplicated = _addresses.any(
      (address) =>
          address.id != exceptId && address.label.toLowerCase() == normalized,
    );
    if (duplicated) {
      throw const DuplicateAddressLabelException();
    }
  }

  AddressDraft _normalize(AddressDraft draft) {
    final label = draft.label.trim().replaceAll(RegExp(r'\s+'), ' ');
    final recipientName = draft.recipientName.trim();
    final addressLine = draft.addressLine.trim();
    final city = draft.city.trim();
    final department = draft.department.trim();
    final reference = draft.reference?.trim();

    if (label.isEmpty) {
      throw const AddressValidationException(
        'Ingresa un nombre para identificar la dirección.',
      );
    }
    if (recipientName.isEmpty) {
      throw const AddressValidationException(
        'Ingresa el nombre del destinatario.',
      );
    }
    if (addressLine.isEmpty) {
      throw const AddressValidationException('Ingresa la dirección.');
    }
    if (city.isEmpty) {
      throw const AddressValidationException('Ingresa la ciudad.');
    }
    if (department.isEmpty) {
      throw const AddressValidationException('Ingresa el departamento.');
    }

    return AddressDraft(
      label: label,
      recipientName: recipientName,
      addressLine: addressLine,
      city: city,
      department: department,
      reference: reference == null || reference.isEmpty ? null : reference,
      isDefault: draft.isDefault,
    );
  }
}
