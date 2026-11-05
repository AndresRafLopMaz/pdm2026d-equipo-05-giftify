enum GiftOccasion {
  birthday,
  anniversary,
  graduation,
  christmas,
  valentines,
  mothersDay,
  fathersDay,
  friendship,
  thankYou,
  farewell,
  special,
}

extension GiftOccasionLabel on GiftOccasion {
  String get label {
    return switch (this) {
      GiftOccasion.birthday => 'Cumpleaños',
      GiftOccasion.anniversary => 'Aniversario',
      GiftOccasion.graduation => 'Graduación',
      GiftOccasion.christmas => 'Navidad',
      GiftOccasion.valentines => 'San Valentín',
      GiftOccasion.mothersDay => 'Día de la Madre',
      GiftOccasion.fathersDay => 'Día del Padre',
      GiftOccasion.friendship => 'Amistad',
      GiftOccasion.thankYou => 'Agradecimiento',
      GiftOccasion.farewell => 'Despedida',
      GiftOccasion.special => 'Ocasión especial',
    };
  }
}
