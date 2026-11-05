enum GiftAgeRange { kids, teens, youngAdult, adult, mature, senior }

extension GiftAgeRangeLabel on GiftAgeRange {
  String get label {
    return switch (this) {
      GiftAgeRange.kids => '0–12',
      GiftAgeRange.teens => '13–17',
      GiftAgeRange.youngAdult => '18–25',
      GiftAgeRange.adult => '26–35',
      GiftAgeRange.mature => '36–50',
      GiftAgeRange.senior => '51+',
    };
  }
}
