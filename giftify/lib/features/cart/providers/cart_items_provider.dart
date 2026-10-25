import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/cart_item.dart';
import '../data/cart_filter.dart';
import '../data/cart_repository.dart';
import '../data/cart_store.dart';
import '../data/persistent_cart_repository.dart';
import 'cart_filter_provider.dart';

/// Estado completo del carrito y su subconjunto visible.
class CartSnapshot {
  CartSnapshot({required List<CartItem> allItems, required this.filter})
    : allItems = List<CartItem>.unmodifiable(allItems),
      visibleItems = applyCartFilter(allItems, filter),
      categories = Set<String>.unmodifiable(
        allItems.map((item) => item.product.category).toSet(),
      );

  final List<CartItem> allItems;
  final List<CartItem> visibleItems;
  final Set<String> categories;
  final CartFilter filter;

  double get total => allItems.fold(0, (total, item) => total + item.subtotal);

  bool get isEmpty => allItems.isEmpty;

  bool get hasNoVisibleItems => allItems.isNotEmpty && visibleItems.isEmpty;
}

/// Repositorio persistente usado por la aplicación.
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return PersistentCartRepository(store: SharedPreferencesCartStore());
});

class CartItemsNotifier extends AsyncNotifier<CartSnapshot> {
  @override
  Future<CartSnapshot> build() async {
    final filter = ref.watch(cartFilterProvider);
    final repository = ref.watch(cartRepositoryProvider);
    final items = await repository.loadItems();
    return CartSnapshot(allItems: items, filter: filter);
  }

  Future<void> addIncoming(List<CartItem> items) async {
    if (items.isEmpty) {
      return;
    }

    final allItems = await ref.read(cartRepositoryProvider).addItems(items);
    _setItems(allItems);
  }

  Future<void> changeQuantity(String productId, int quantity) async {
    final updated = await ref
        .read(cartRepositoryProvider)
        .updateQuantity(productId, quantity);
    final current = state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }

    final allItems = current.allItems
        .map((item) => item.product.id == productId ? updated : item)
        .toList(growable: false);
    _setItems(allItems);
  }

  Future<RemovedCartItem> deleteFromRepository(String productId) {
    return ref.read(cartRepositoryProvider).removeItem(productId);
  }

  void removeLocal(RemovedCartItem removed) {
    final current = state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }

    _setItems(
      current.allItems
          .where((item) => item.product.id != removed.item.product.id)
          .toList(growable: false),
    );
  }

  Future<void> restore(RemovedCartItem removed) async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.restoreItem(removed);
    _setItems(await repository.loadItems());
  }

  void _setItems(List<CartItem> allItems) {
    state = AsyncData(
      CartSnapshot(allItems: allItems, filter: ref.read(cartFilterProvider)),
    );
  }
}

final cartItemsProvider =
    AsyncNotifierProvider.autoDispose<CartItemsNotifier, CartSnapshot>(
      CartItemsNotifier.new,
      retry: (retryCount, error) => null,
    );
