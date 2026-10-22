import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_filter.dart';
import '../../../shared/enums/gift_availability.dart';

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setCategory(String? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
  }

  void setAvailability(GiftAvailability? availability) {
    state = state.copyWith(
      availability: availability,
      clearAvailability: availability == null,
    );
  }

  void clear() {
    state = const ProductFilter();
  }
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
      ProductFilterNotifier.new,
    );
