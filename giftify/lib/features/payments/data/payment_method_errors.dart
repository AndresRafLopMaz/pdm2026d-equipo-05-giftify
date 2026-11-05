class PaymentMethodException implements Exception {
  const PaymentMethodException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PaymentMethodNotFoundException extends PaymentMethodException {
  const PaymentMethodNotFoundException()
    : super('No encontramos el método de pago solicitado.');
}

class PaymentMethodStorageException extends PaymentMethodException {
  const PaymentMethodStorageException()
    : super('No pudimos guardar el método de pago. Intenta nuevamente.');
}

class InvalidPaymentMethodException extends PaymentMethodException {
  const InvalidPaymentMethodException(super.message);
}
