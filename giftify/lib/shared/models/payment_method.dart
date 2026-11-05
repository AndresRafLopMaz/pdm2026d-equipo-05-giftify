import '../enums/payment_brand.dart';

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.holderName,
    required this.brand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  final String id;
  final int userId;
  final String holderName;
  final PaymentBrand brand;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  String get expiryLabel {
    final month = expiryMonth.toString().padLeft(2, '0');
    final year = (expiryYear % 100).toString().padLeft(2, '0');
    return '$month/$year';
  }

  String get maskedNumber => '•••• $last4';
}
