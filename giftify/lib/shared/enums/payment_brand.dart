enum PaymentBrand {
  visa,
  mastercard,
  amex,
  other;

  String get label {
    return switch (this) {
      PaymentBrand.visa => 'Visa',
      PaymentBrand.mastercard => 'Mastercard',
      PaymentBrand.amex => 'American Express',
      PaymentBrand.other => 'Otra',
    };
  }
}
