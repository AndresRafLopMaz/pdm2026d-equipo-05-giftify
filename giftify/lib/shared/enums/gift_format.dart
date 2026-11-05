enum GiftFormat { physical, experience }

extension GiftFormatLabel on GiftFormat {
  String get label {
    return switch (this) {
      GiftFormat.physical => 'Físico',
      GiftFormat.experience => 'Experiencia',
    };
  }
}
