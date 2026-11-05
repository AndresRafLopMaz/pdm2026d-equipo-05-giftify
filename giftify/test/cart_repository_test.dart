import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PersistentCartRepository', () {
    test('incorpora productos y suma cantidades del mismo ID', () async {
      final repository = PersistentCartRepository(store: InMemoryCartStore());
      final product = mockProducts.first;

      await repository.addItems([CartItem(product: product)]);
      final items = await repository.addItems([
        CartItem(product: product, quantity: 2),
      ]);

      expect(items, hasLength(1));
      expect(items.single.product, same(product));
      expect(items.single.quantity, 3);
    });

    test('serializa incorporaciones concurrentes sin perder datos', () async {
      final store = InMemoryCartStore();
      final firstRepository = PersistentCartRepository(store: store);
      final secondRepository = PersistentCartRepository(store: store);
      final product = mockProducts.first;

      await Future.wait([
        firstRepository.addItems([CartItem(product: product)]),
        secondRepository.addItems([CartItem(product: product)]),
      ]);

      final items = await firstRepository.loadItems();
      expect(items.single.quantity, 2);
    });

    test('actualiza la cantidad persistida', () async {
      final store = InMemoryCartStore();
      final repository = PersistentCartRepository(store: store);
      final product = mockProducts.first;
      await repository.addItems([CartItem(product: product)]);

      final updated = await repository.updateQuantity(product.id, 4);
      final reopened = PersistentCartRepository(store: store);

      expect(updated.quantity, 4);
      expect((await reopened.loadItems()).single.quantity, 4);
    });

    test('elimina y restaura mismos datos en su posición original', () async {
      final store = InMemoryCartStore();
      final repository = PersistentCartRepository(store: store);
      await repository.addItems([
        CartItem(product: mockProducts[0]),
        CartItem(product: mockProducts[1], quantity: 3),
      ]);

      final removal = await repository.removeItem(mockProducts[0].id);
      expect(removal.item.product, same(mockProducts[0]));
      expect(removal.item.quantity, 1);
      expect(removal.index, 0);
      expect(await repository.loadItems(), hasLength(1));

      await repository.restoreItem(removal);
      final reopened = PersistentCartRepository(store: store);
      final restored = await reopened.loadItems();
      expect(restored.map((item) => item.product.id), [
        mockProducts[0].id,
        mockProducts[1].id,
      ]);
      expect(restored.first.quantity, 1);
    });

    test(
      'persiste exclusivamente IDs y cantidades en SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        final repository = PersistentCartRepository(
          store: SharedPreferencesCartStore(userId: 1),
        );
        await repository.addItems([
          CartItem(product: mockProducts[1], quantity: 2),
        ]);

        final preferences = await SharedPreferences.getInstance();
        final raw = preferences.getString(cartKeyForUser(1))!;
        expect(raw, contains('"productId":"${mockProducts[1].id}"'));
        expect(raw, contains('"quantity":2'));
        expect(raw, isNot(contains(mockProducts[1].name)));

        final reopened = PersistentCartRepository(
          store: SharedPreferencesCartStore(userId: 1),
        );
        final items = await reopened.loadItems();
        expect(items.single.product, same(mockProducts[1]));
        expect(items.single.quantity, 2);
      },
    );

    test('omite un ID obsoleto y sanea la persistencia', () async {
      final store = InMemoryCartStore([
        const CartEntry(productId: 'gift-inexistente', quantity: 1),
        CartEntry(productId: mockProducts.first.id, quantity: 2),
      ]);
      final repository = PersistentCartRepository(store: store);

      final items = await repository.loadItems();

      expect(items.single.product.id, mockProducts.first.id);
      expect(items.single.quantity, 2);
      expect((await store.load()).single.productId, mockProducts.first.id);
    });

    test('un fallo de escritura no altera los datos guardados', () async {
      final store = _FailingSaveCartStore([
        CartEntry(productId: mockProducts.first.id, quantity: 1),
      ]);
      final repository = PersistentCartRepository(store: store);

      await expectLater(
        repository.updateQuantity(mockProducts.first.id, 2),
        throwsStateError,
      );
      expect((await repository.loadItems()).single.quantity, 1);
    });

    test('valida cantidad mínima y productos existentes', () async {
      final repository = PersistentCartRepository(store: InMemoryCartStore());

      await expectLater(
        repository.updateQuantity(mockProducts.first.id, 0),
        throwsArgumentError,
      );
      await expectLater(
        repository.removeItem(mockProducts.first.id),
        throwsStateError,
      );
    });
  });

  group('PersistentCartRepository recupera almacenamiento corrupto', () {
    test(
      'JSON corrupto se trata como carrito vacío y limpia la clave',
      () async {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(cartKeyForUser(1), '{corrupto');

        final repository = PersistentCartRepository(
          store: SharedPreferencesCartStore(userId: 1),
        );

        expect(await repository.loadItems(), isEmpty);
        expect(preferences.containsKey(cartKeyForUser(1)), isFalse);
      },
    );

    test('estructura que no es lista se descarta sin crash', () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(cartKeyForUser(1), '{"productId":"x"}');

      final repository = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 1),
      );

      expect(await repository.loadItems(), isEmpty);
      expect(preferences.containsKey(cartKeyForUser(1)), isFalse);
    });

    test('entradas corruptas no impiden conservar las válidas', () async {
      final preferences = await SharedPreferences.getInstance();
      final validId = mockProducts.first.id;
      await preferences.setString(
        cartKeyForUser(1),
        jsonEncode([
          {'productId': validId, 'quantity': 2},
          {'productId': 'gift-inexistente', 'quantity': 1},
          {'productId': '', 'quantity': 1},
          {'productId': mockProducts[1].id, 'quantity': 0},
          {'productId': mockProducts[1].id, 'quantity': 1},
        ]),
      );

      final repository = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 1),
      );

      final items = await repository.loadItems();
      expect(items.map((item) => item.product.id), [
        validId,
        mockProducts[1].id,
      ]);
      expect(
        (await SharedPreferences.getInstance()).getString(cartKeyForUser(1)),
        isNotNull,
      );

      final reopened = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 1),
      );
      expect((await reopened.loadItems()).map((item) => item.product.id), [
        validId,
        mockProducts[1].id,
      ]);
    });

    test('todas las entradas inválidas vacían la clave', () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        cartKeyForUser(1),
        jsonEncode([
          {'productId': '', 'quantity': 1},
          {'productId': mockProducts.first.id, 'quantity': 0},
          {'otro': true},
        ]),
      );

      final repository = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 1),
      );

      expect(await repository.loadItems(), isEmpty);
      expect(preferences.containsKey(cartKeyForUser(1)), isFalse);
    });
  });
}

class _FailingSaveCartStore extends CartStore {
  _FailingSaveCartStore(this.entries);

  final List<CartEntry> entries;

  @override
  Future<List<CartEntry>> load() async => List<CartEntry>.of(entries);

  @override
  Future<void> save(List<CartEntry> entries) {
    throw StateError('Fallo de escritura');
  }
}
