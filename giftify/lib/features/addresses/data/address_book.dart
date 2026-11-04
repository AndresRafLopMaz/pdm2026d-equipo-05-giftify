import '../../../shared/models/delivery_address.dart';

class AddressDraft {
  const AddressDraft({
    required this.label,
    required this.recipientName,
    required this.addressLine,
    required this.city,
    required this.department,
    this.reference,
    this.isDefault = false,
  });

  final String label;
  final String recipientName;
  final String addressLine;
  final String city;
  final String department;
  final String? reference;
  final bool isDefault;
}

class AddressBook {
  AddressBook({
    required List<DeliveryAddress> addresses,
    String? defaultAddressId,
  }) : addresses = List<DeliveryAddress>.unmodifiable(_sorted(addresses)),
       defaultAddressId = defaultAddressId ?? _findDefaultId(addresses);

  factory AddressBook.empty() => AddressBook(addresses: const []);

  final List<DeliveryAddress> addresses;
  final String? defaultAddressId;

  List<DeliveryAddress> get active =>
      List<DeliveryAddress>.unmodifiable(addresses.where((a) => !a.isArchived));

  List<DeliveryAddress> get archived =>
      List<DeliveryAddress>.unmodifiable(addresses.where((a) => a.isArchived));

  bool get isEmpty => addresses.isEmpty;

  DeliveryAddress? get defaultAddress {
    for (final address in addresses) {
      if (address.id == defaultAddressId) {
        return address;
      }
    }
    return null;
  }

  static List<DeliveryAddress> _sorted(List<DeliveryAddress> addresses) {
    final sorted = List<DeliveryAddress>.of(addresses);
    sorted.sort((a, b) {
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
    return sorted;
  }

  static String? _findDefaultId(List<DeliveryAddress> addresses) {
    for (final address in addresses) {
      if (address.isDefault && !address.isArchived) {
        return address.id;
      }
    }
    return null;
  }
}
