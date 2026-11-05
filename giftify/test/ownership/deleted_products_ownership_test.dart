import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/auth/providers/current_user_provider.dart';
import 'package:giftify/features/products/data/deleted_products_store.dart';
import 'package:giftify/features/products/data/mock_product_repository.dart';
import 'package:giftify/features/products/providers/products_provider.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ownership_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('A elimina un producto y B sigue viéndolo', () async {
    final repositoryA = MockProductRepository(
      deletedStore: SharedPreferencesDeletedProductsStore(userId: 1),
      delay: Duration.zero,
    );
    final repositoryB = MockProductRepository(
      deletedStore: SharedPreferencesDeletedProductsStore(userId: 2),
      delay: Duration.zero,
    );
    final target = (await repositoryA.fetchProducts()).first;

    final deletion = await repositoryA.deleteProduct(target.id);

    expect(
      (await repositoryA.fetchProducts()).any((p) => p.id == target.id),
      isFalse,
    );
    expect(
      (await repositoryB.fetchProducts()).any((p) => p.id == target.id),
      isTrue,
    );

    await repositoryA.restoreProduct(deletion);

    expect(
      (await repositoryA.fetchProducts()).any((p) => p.id == target.id),
      isTrue,
    );
  });

  test('los namespaces de eliminados son independientes', () async {
    final storeA = SharedPreferencesDeletedProductsStore(userId: 1);
    final storeB = SharedPreferencesDeletedProductsStore(userId: 2);

    await storeA.add('gift-001');
    await storeB.add('gift-002');

    expect(await storeA.load(), {'gift-001'});
    expect(await storeB.load(), {'gift-002'});

    await storeA.remove('gift-001');
    expect(await storeA.load(), isEmpty);
    expect(await storeB.load(), {'gift-002'});
  });

  test('productsProvider reacciona al cambio de usuario', () async {
    SharedPreferences.setMockInitialValues({
      deletedProductsKeyForUser(1): [mockProducts[0].id],
    });

    int? currentUserId = 1;
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith((ref) => currentUserId),
        ownershipNotNeededOverride,
      ],
    );
    addTearDown(container.dispose);
    container.listen(productsProvider(null), (_, _) {});

    final first = await container.read(productsProvider(null).future);
    expect(first.any((product) => product.id == mockProducts[0].id), isFalse);

    currentUserId = 2;
    container.invalidate(currentUserIdProvider);
    final second = await container.read(productsProvider(null).future);
    expect(second.any((product) => product.id == mockProducts[0].id), isTrue);
  });
}
