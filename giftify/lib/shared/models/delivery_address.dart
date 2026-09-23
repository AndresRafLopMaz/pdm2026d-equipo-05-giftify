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
}
