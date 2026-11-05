import '../../../shared/models/delivery_address.dart';
import 'address_book.dart';

abstract class AddressRepository {
  Future<AddressBook> loadBook();

  Future<DeliveryAddress> create(AddressDraft draft);

  Future<DeliveryAddress> update(String id, AddressDraft draft);

  Future<void> delete(String id);

  Future<void> archive(String id);

  Future<void> restore(String id);

  Future<void> setDefault(String id);
}

class AddressException implements Exception {
  const AddressException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DuplicateAddressLabelException extends AddressException {
  const DuplicateAddressLabelException()
    : super(
        'Ya existe una dirección con ese nombre.\n'
        'Usa otro nombre para identificarla.',
      );
}

class AddressInUseException extends AddressException {
  const AddressInUseException()
    : super('No puedes eliminar la dirección principal.');
}

class AddressNotFoundException extends AddressException {
  const AddressNotFoundException()
    : super('No encontramos la dirección solicitada.');
}

class AddressValidationException extends AddressException {
  const AddressValidationException(super.message);
}
