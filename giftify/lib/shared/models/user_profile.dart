import 'delivery_address.dart';

/// Información general del usuario.
///
/// No contiene contraseña ni datos completos de tarjetas.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.birthDate,
    this.addresses = const [],
  });

  final String id;
  final String name;
  final String email;
  final DateTime birthDate;

  final List<DeliveryAddress> addresses;
}
