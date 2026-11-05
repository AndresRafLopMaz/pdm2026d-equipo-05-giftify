enum GiftRecipient { partner, family, friend, coworker, child, other }

extension GiftRecipientLabel on GiftRecipient {
  String get label {
    return switch (this) {
      GiftRecipient.partner => 'Pareja',
      GiftRecipient.family => 'Familia',
      GiftRecipient.friend => 'Amigo/a',
      GiftRecipient.coworker => 'Compañero/a',
      GiftRecipient.child => 'Niño/a',
      GiftRecipient.other => 'Otra persona',
    };
  }
}
