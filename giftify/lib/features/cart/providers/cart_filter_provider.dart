import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cart_filter.dart';

class CartFilterNotifier extends Notifier<CartFilter> {
  @override
  CartFilter build() => const CartFilter();

  void setCategory(String? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
  }

  void clear() {
    state = const CartFilter();
  }
}

final cartFilterProvider =
    NotifierProvider.autoDispose<CartFilterNotifier, CartFilter>(
      CartFilterNotifier.new,
    );
