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

  Future<DeliveryAddress> createAddress(AddressDraft draft) {
    return ref.read(addressRepositoryProvider).create(draft);
  }

  Future<DeliveryAddress> updateAddress(String id, AddressDraft draft) {
    return ref.read(addressRepositoryProvider).update(id, draft);
  }

  Future<void> deleteAddress(String id) {
    return ref.read(addressRepositoryProvider).delete(id);
  }

  Future<void> archiveAddress(String id) {
    return ref.read(addressRepositoryProvider).archive(id);
  }

  Future<void> restoreAddress(String id) {
    return ref.read(addressRepositoryProvider).restore(id);
  }

  Future<void> setDefaultAddress(String id) {
    return ref.read(addressRepositoryProvider).setDefault(id);
  }
}

final addressesProvider = AsyncNotifierProvider<AddressesNotifier, AddressBook>(
  AddressesNotifier.new,
  retry: (retryCount, error) => null,
);
