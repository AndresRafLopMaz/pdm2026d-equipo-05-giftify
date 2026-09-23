/// Dirección que puede utilizarse durante el proceso de check-out.
class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.addressLine,
    required this.city,
    required this.department,
    this.reference,
  });

  final String id;

  /// Nombre identificador como "Casa" o "Trabajo".
  final String label;

  final String recipientName;
  final String addressLine;
  final String city;
  final String department;

  /// Indicaciones adicionales opcionales.
  final String? reference;
}
