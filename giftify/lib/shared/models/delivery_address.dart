/// Dirección utilizada durante el proceso de check-out.
class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.addressLine,
    required this.city,
    required this.department,
    this.reference,
    this.isDefault = false,
    this.isArchived = false,
  });

  final String id;

  /// Nombre identificador: Casa, Trabajo, etc.
  final String label;

  final String recipientName;
  final String addressLine;
  final String city;
  final String department;

  /// Información complementaria para localizar la dirección.
  final String? reference;

  final bool isDefault;
  final bool isArchived;

  DeliveryAddress copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? addressLine,
    String? city,
    String? department,
    String? reference,
    bool? isDefault,
    bool? isArchived,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      department: department ?? this.department,
      reference: reference ?? this.reference,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
