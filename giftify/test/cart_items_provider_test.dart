import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/cart/data/cart_repository.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_filter_provider.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test(
    'cambia de categoría, distingue filtro vacío y no altera lo persistido',
    () async {
      final store = InMemoryCartStore([
        CartEntry(productId: mockProducts[0].id, quantity: 2),
        CartEntry(productId: mockProducts[1].id, quantity: 1),
        CartEntry(productId: mockProducts[5].id, quantity: 3),
      ]);
      final repository = PersistentCartRepository(store: store);
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final initial = await container.read(cartItemsProvider.future);
      expect(initial.visibleItems, hasLength(3));
      expect(initial.total, 780);

      container
          .read(cartFilterProvider.notifier)
          .setCategory(mockProducts[1].category);
      final foods = await container.read(cartItemsProvider.future);
      expect(foods.visibleItems.map((item) => item.product.id), [
        mockProducts[1].id,
        mockProducts[5].id,
      ]);
      expect(foods.allItems, hasLength(3));
      expect(foods.total, 780);
      expect(foods.hasNoVisibleItems, isFalse);
      expect(foods.isEmpty, isFalse);

      container
          .read(cartFilterProvider.notifier)
          .setCategory('Categoría inexistente');
      final withoutMatches = await container.read(cartItemsProvider.future);
      expect(withoutMatches.visibleItems, isEmpty);
      expect(withoutMatches.hasNoVisibleItems, isTrue);
      expect(withoutMatches.isEmpty, isFalse);
      expect(withoutMatches.total, 780);

      container
          .read(cartFilterProvider.notifier)
          .setCategory(mockProducts[0].category);
      final jewelry = await container.read(cartItemsProvider.future);
      expect(jewelry.visibleItems.single.product.id, mockProducts[0].id);
      expect(jewelry.total, 780);

      final persisted = await repository.loadItems();
      expect(persisted.map((item) => item.product.id), [
        mockProducts[0].id,
        mockProducts[1].id,
        mockProducts[5].id,
      ]);
      expect(persisted.map((item) => item.quantity), [2, 1, 3]);
    },
  );

  test(
    'la carga inicial se fusiona con lo persistido y suma cantidades',
    () async {
      final store = InMemoryCartStore([
        CartEntry(productId: mockProducts[0].id, quantity: 1),
      ]);
      final repository = PersistentCartRepository(store: store);
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      await container.read(cartItemsProvider.future);

      await container.read(cartItemsProvider.notifier).addIncoming([
        CartItem(product: mockProducts[0]),
        CartItem(product: mockProducts[1], quantity: 2),
      ]);

      final snapshot = container.read(cartItemsProvider).requireValue;
      expect(snapshot.allItems.map((item) => item.product.id), [
        mockProducts[0].id,
        mockProducts[1].id,
      ]);
      expect(snapshot.allItems.map((item) => item.quantity), [2, 2]);

      final persisted = await repository.loadItems();
      expect(persisted.map((item) => item.quantity), [2, 2]);
    },
  );

  test(
    'eliminar, deshacer y cantidades persisten al recrear el estado',
    () async {
      SharedPreferences.setMockInitialValues({});
      final firstRepository = PersistentCartRepository(
        store: SharedPreferencesCartStore(),
      );
      final first = _containerWith(firstRepository);
      addTearDown(first.dispose);
      await first.read(cartItemsProvider.future);
      await first.read(cartItemsProvider.notifier).addIncoming([
        CartItem(product: mockProducts[0], quantity: 2),
        CartItem(product: mockProducts[1]),
      ]);

      final removal = await first
          .read(cartItemsProvider.notifier)
          .deleteFromRepository(mockProducts[0].id);
      first.read(cartItemsProvider.notifier).removeLocal(removal);
      expect(first.read(cartItemsProvider).requireValue.isEmpty, isFalse);

      final secondRepository = PersistentCartRepository(
        store: SharedPreferencesCartStore(),
      );
      final second = _containerWith(secondRepository);
      addTearDown(second.dispose);
      final afterDelete = await second.read(cartItemsProvider.future);
      expect(afterDelete.allItems.map((item) => item.product.id), [
        mockProducts[1].id,
      ]);
      expect(afterDelete.allItems.single.quantity, 1);

      await second.read(cartItemsProvider.notifier).restore(removal);
      final afterRestore = second.read(cartItemsProvider).requireValue;
      expect(afterRestore.allItems.map((item) => item.product.id), [
        mockProducts[0].id,
        mockProducts[1].id,
      ]);
      expect(afterRestore.allItems.map((item) => item.quantity), [2, 1]);

      final thirdRepository = PersistentCartRepository(
        store: SharedPreferencesCartStore(),
      );
      final third = _containerWith(thirdRepository);
      addTearDown(third.dispose);
      final reopened = await third.read(cartItemsProvider.future);
      expect(reopened.allItems.map((item) => item.product.id), [
        mockProducts[0].id,
        mockProducts[1].id,
      ]);
      expect(reopened.allItems.map((item) => item.quantity), [2, 1]);
      expect(reopened.total, 345);
    },
  );

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
