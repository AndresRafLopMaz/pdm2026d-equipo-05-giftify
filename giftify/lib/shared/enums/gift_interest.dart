enum GiftInterest {
  technology,
  gaming,
  music,
  books,
  sports,
  cooking,
  fashion,
  beauty,
  art,
  travel,
  home,
  coffee,
}

extension GiftInterestLabel on GiftInterest {
  String get label {
    return switch (this) {
      GiftInterest.technology => 'Tecnología',
      GiftInterest.gaming => 'Gaming',
      GiftInterest.music => 'Música',
      GiftInterest.books => 'Libros',
      GiftInterest.sports => 'Deportes',
      GiftInterest.cooking => 'Cocina',
      GiftInterest.fashion => 'Moda',
      GiftInterest.beauty => 'Belleza',
      GiftInterest.art => 'Arte',
      GiftInterest.travel => 'Viajes',
      GiftInterest.home => 'Hogar',
      GiftInterest.coffee => 'Café',
    };
  }
}
