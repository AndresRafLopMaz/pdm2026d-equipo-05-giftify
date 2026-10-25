import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/cart/data/cart_repository.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_filter_provider.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

void main() {
  test('carga allItems y calcula total y categorías', () async {
    final store = InMemoryCartStore([
      CartEntry(productId: mockProducts[0].id, quantity: 2),
      CartEntry(productId: mockProducts[1].id, quantity: 1),
    ]);
    final container = _containerWith(PersistentCartRepository(store: store));
    addTearDown(container.dispose);

    final snapshot = await container.read(cartItemsProvider.future);

    expect(snapshot.allItems, hasLength(2));
    expect(snapshot.visibleItems, hasLength(2));
    expect(snapshot.total, 345);
    expect(snapshot.categories, {'Joyería', 'Alimentos'});
  });

  test('observa filtro sin alterar allItems, total ni cantidades', () async {
    final store = InMemoryCartStore([
      CartEntry(productId: mockProducts[0].id, quantity: 2),
      CartEntry(productId: mockProducts[1].id, quantity: 1),
    ]);
    final container = _containerWith(PersistentCartRepository(store: store));
    addTearDown(container.dispose);
    await container.read(cartItemsProvider.future);

    container
        .read(cartFilterProvider.notifier)
        .setCategory(mockProducts[1].category);
    final filtered = await container.read(cartItemsProvider.future);

    expect(filtered.allItems, hasLength(2));
    expect(filtered.visibleItems.single.product.id, mockProducts[1].id);
    expect(filtered.total, 345);
    expect(filtered.allItems.first.quantity, 2);
  });

  test('incorpora una vez, actualiza cantidad y persiste', () async {
    final store = InMemoryCartStore();
    final repository = PersistentCartRepository(store: store);
    final container = _containerWith(repository);
    addTearDown(container.dispose);
    await container.read(cartItemsProvider.future);

    await container.read(cartItemsProvider.notifier).addIncoming([
      CartItem(product: mockProducts.first),
    ]);
    await container
        .read(cartItemsProvider.notifier)
        .changeQuantity(mockProducts.first.id, 3);

    final snapshot = container.read(cartItemsProvider).requireValue;
    expect(snapshot.allItems.single.quantity, 3);
    expect((await repository.loadItems()).single.quantity, 3);
  });

  test('delete local y restore mantienen mismos datos persistidos', () async {
    final store = InMemoryCartStore([
      CartEntry(productId: mockProducts.first.id, quantity: 2),
    ]);
    final repository = PersistentCartRepository(store: store);
    final container = _containerWith(repository);
    addTearDown(container.dispose);
    await container.read(cartItemsProvider.future);

    final notifier = container.read(cartItemsProvider.notifier);
    final removal = await notifier.deleteFromRepository(mockProducts.first.id);
    notifier.removeLocal(removal);
    expect(container.read(cartItemsProvider).requireValue.isEmpty, isTrue);

    await notifier.restore(removal);
    final restored = container.read(cartItemsProvider).requireValue;
    expect(restored.allItems.single.product.id, mockProducts.first.id);
    expect(restored.allItems.single.quantity, 2);
    expect((await repository.loadItems()).single.quantity, 2);
  });

  test('expone error y permite reintento manual', () async {
    final store = _ToggleLoadCartStore();
    final repository = PersistentCartRepository(store: store);
    final container = _containerWith(repository);
    addTearDown(container.dispose);

    await expectLater(
      container.read(cartItemsProvider.future),
      throwsStateError,
    );
    expect(container.read(cartItemsProvider).hasError, isTrue);

    store.shouldFail = false;
    container.invalidate(cartItemsProvider);
    final snapshot = await container.read(cartItemsProvider.future);
    expect(snapshot.isEmpty, isTrue);
  });
}

ProviderContainer _containerWith(CartRepository repository) {
  final container = ProviderContainer(
    overrides: [cartRepositoryProvider.overrideWithValue(repository)],
  );
  container.listen(cartItemsProvider, (_, _) {});
  return container;
}

class _ToggleLoadCartStore extends CartStore {
  bool shouldFail = true;

  @override
  Future<List<CartEntry>> load() async {
    if (shouldFail) {
      throw StateError('Fallo de lectura');
    }
    return const [];
  }

  @override
  Future<void> save(List<CartEntry> entries) async {}
}
