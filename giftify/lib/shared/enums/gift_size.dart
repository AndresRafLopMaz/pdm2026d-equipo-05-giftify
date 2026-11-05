enum GiftSize { small, medium, large }

extension GiftSizeLabel on GiftSize {
  String get label {
    return switch (this) {
      GiftSize.small => 'Pequeño',
      GiftSize.medium => 'Mediano',
      GiftSize.large => 'Grande',
    };
  }
}
