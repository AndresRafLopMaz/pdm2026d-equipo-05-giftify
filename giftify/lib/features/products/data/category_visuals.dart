import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/enums/gift_category.dart';

abstract final class CategoryVisuals {
  /// Se activará cuando existan los 10 WebP locales con licencia documentada.
  static const bool localAssetsAvailable = false;

  static String assetPathFor(GiftCategory category) {
    return switch (category) {
      GiftCategory.technology => 'assets/images/categories/technology.webp',
      GiftCategory.jewelry => 'assets/images/categories/jewelry.webp',
      GiftCategory.food => 'assets/images/categories/food.webp',
      GiftCategory.accessories => 'assets/images/categories/accessories.webp',
      GiftCategory.home => 'assets/images/categories/home.webp',
      GiftCategory.books => 'assets/images/categories/books.webp',
      GiftCategory.gaming => 'assets/images/categories/gaming.webp',
      GiftCategory.beauty => 'assets/images/categories/beauty.webp',
      GiftCategory.crafts => 'assets/images/categories/crafts.webp',
      GiftCategory.experiences => 'assets/images/categories/experiences.webp',
    };
  }

  static String? bundledAssetFor(GiftCategory category) {
    return localAssetsAvailable ? assetPathFor(category) : null;
  }

  static IconData iconFor(GiftCategory category) {
    return switch (category) {
      GiftCategory.technology => Icons.devices_rounded,
      GiftCategory.jewelry => Icons.diamond_rounded,
      GiftCategory.food => Icons.restaurant_rounded,
      GiftCategory.accessories => Icons.watch_rounded,
      GiftCategory.home => Icons.home_rounded,
      GiftCategory.books => Icons.menu_book_rounded,
      GiftCategory.gaming => Icons.sports_esports_rounded,
      GiftCategory.beauty => Icons.spa_rounded,
      GiftCategory.crafts => Icons.palette_rounded,
      GiftCategory.experiences => Icons.local_activity_rounded,
    };
  }

  static ({Color background, Color foreground}) colorsFor(
    BuildContext context,
    GiftCategory category,
  ) {
    final giftify = GiftifyColors.of(context);
    final colors = Theme.of(context).colorScheme;

    return switch (category) {
      GiftCategory.technology => (
        background: giftify.secondarySoft,
        foreground: giftify.secondaryStrong,
      ),
      GiftCategory.jewelry => (
        background: giftify.blushSoft,
        foreground: giftify.blushStrong,
      ),
      GiftCategory.food => (
        background: giftify.warmSoft,
        foreground: giftify.warmStrong,
      ),
      GiftCategory.accessories => (
        background: colors.primaryContainer,
        foreground: colors.primary,
      ),
      GiftCategory.home => (
        background: giftify.successSoft,
        foreground: giftify.successStrong,
      ),
      GiftCategory.books => (
        background: giftify.warmSoft,
        foreground: giftify.warmStrong,
      ),
      GiftCategory.gaming => (
        background: giftify.secondarySoft,
        foreground: giftify.secondaryStrong,
      ),
      GiftCategory.beauty => (
        background: giftify.blushSoft,
        foreground: giftify.blushStrong,
      ),
      GiftCategory.crafts => (
        background: giftify.warmSoft,
        foreground: giftify.warmStrong,
      ),
      GiftCategory.experiences => (
        background: colors.primaryContainer,
        foreground: colors.primary,
      ),
    };
  }
}
