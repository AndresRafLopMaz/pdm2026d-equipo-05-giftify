import '../../../shared/enums/payment_brand.dart';

/// Resumen inmutable de una compra simulada.
///
/// No contiene identificadores de usuario, direcciones ni datos de tarjeta.
class CheckoutSuccessData {
  const CheckoutSuccessData({
    required this.totalUnits,
    required this.total,
    required this.addressLabel,
    required this.recipientName,
    required this.paymentBrand,
    required this.paymentLast4,
  });

  final int totalUnits;
  final double total;
  final String addressLabel;
  final String recipientName;
  final PaymentBrand paymentBrand;
  final String paymentLast4;
}
