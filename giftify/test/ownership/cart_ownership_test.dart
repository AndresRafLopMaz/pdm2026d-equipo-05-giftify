import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/auth/providers/current_user_provider.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ownership_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'A y B conservan carritos independientes y clear no toca al otro',
    () async {
      final repositoryA = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 1),
      );
      final repositoryB = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 2),
      );

      await repositoryA.addItems([
        CartItem(product: mockProducts[0], quantity: 2),
      ]);
      await repositoryB.addItems([
        CartItem(product: mockProducts[1], quantity: 1),
      ]);

      expect(
        (await repositoryA.loadItems()).single.product.id,
        mockProducts[0].id,
      );
      expect(
        (await repositoryB.loadItems()).single.product.id,
        mockProducts[1].id,
      );

      await repositoryA.clearItems();
      expect(await repositoryA.loadItems(), isEmpty);
      expect(
        (await repositoryB.loadItems()).single.product.id,
        mockProducts[1].id,
      );

      final reopenedA = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 1),
      );
      final reopenedB = PersistentCartRepository(
        store: SharedPreferencesCartStore(userId: 2),
      );
      expect(await reopenedA.loadItems(), isEmpty);
      expect(
        (await reopenedB.loadItems()).single.product.id,
        mockProducts[1].id,
      );
    },
  );

  test('cartItemsProvider se reconstruye al cambiar currentUserId', () async {
    SharedPreferences.setMockInitialValues({
      cartKeyForUser(1): '[{"productId":"${mockProducts[0].id}","quantity":2}]',
      cartKeyForUser(2): '[{"productId":"${mockProducts[1].id}","quantity":1}]',
    });

    int? currentUserId = 1;
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith((ref) => currentUserId),
        ownershipNotNeededOverride,
      ],
    );
    addTearDown(container.dispose);
    container.listen(cartItemsProvider, (_, _) {});

    final first = await container.read(cartItemsProvider.future);
    expect(first.allItems.single.product.id, mockProducts[0].id);

    currentUserId = 2;
    container.invalidate(currentUserIdProvider);
    final second = await container.read(cartItemsProvider.future);
    expect(second.allItems.single.product.id, mockProducts[1].id);
    expect(
      second.allItems.any((item) => item.product.id == mockProducts[0].id),
      isFalse,
    );
  });
}
