import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/delivery_address.dart';
import '../data/address_book.dart';
import '../data/address_repository.dart';
import '../data/sqflite_address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return SqfliteAddressRepository();
});

class AddressesNotifier extends AsyncNotifier<AddressBook> {
  @override
  Future<AddressBook> build() {
    return ref.watch(addressRepositoryProvider).loadBook();
  }

  Future<DeliveryAddress> createAddress(AddressDraft draft) async {
    final address = await ref.read(addressRepositoryProvider).create(draft);
    await _refresh();
    return address;
  }

  Future<DeliveryAddress> updateAddress(String id, AddressDraft draft) async {
    final address = await ref.read(addressRepositoryProvider).update(id, draft);
    await _refresh();
    return address;
  }

  Future<void> deleteAddress(String id) async {
    await ref.read(addressRepositoryProvider).delete(id);
    await _refresh();
  }

  Future<void> archiveAddress(String id) async {
    await ref.read(addressRepositoryProvider).archive(id);
    await _refresh();
  }

  Future<void> restoreAddress(String id) async {
    await ref.read(addressRepositoryProvider).restore(id);
    await _refresh();
  }

  Future<void> setDefaultAddress(String id) async {
    await ref.read(addressRepositoryProvider).setDefault(id);
    await _refresh();
  }

  Future<void> _refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final addressesProvider = AsyncNotifierProvider<AddressesNotifier, AddressBook>(
  AddressesNotifier.new,
  retry: (retryCount, error) => null,
);
