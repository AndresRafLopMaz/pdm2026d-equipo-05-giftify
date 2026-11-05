enum GiftCategory {
  technology,
  jewelry,
  food,
  accessories,
  home,
  books,
  gaming,
  beauty,
  crafts,
  experiences,
}

extension GiftCategoryLabel on GiftCategory {
  String get label {
    return switch (this) {
      GiftCategory.technology => 'Tecnología',
      GiftCategory.jewelry => 'Joyería',
      GiftCategory.food => 'Alimentos',
      GiftCategory.accessories => 'Accesorios',
      GiftCategory.home => 'Hogar',
      GiftCategory.books => 'Libros',
      GiftCategory.gaming => 'Gaming',
      GiftCategory.beauty => 'Belleza',
      GiftCategory.crafts => 'Artesanías',
      GiftCategory.experiences => 'Experiencias',
    };
  }
}
