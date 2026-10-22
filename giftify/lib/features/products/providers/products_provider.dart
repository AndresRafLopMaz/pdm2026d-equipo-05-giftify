import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/gift_product.dart';
import '../../../shared/models/gift_search_criteria.dart';
import '../data/deleted_products_store.dart';
import '../data/mock_product_repository.dart';
import '../data/product_filter.dart';
import '../data/product_repository.dart';
import '../utils/product_filters.dart';
import 'product_filter_provider.dart';

/// Repositorio local persistente usado por la aplicación.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository(
    deletedStore: SharedPreferencesDeletedProductsStore(),
  );
});

/// Listado de productos filtrado por criterios y por [ProductFilter].
///
/// El provider observa el filtro, por lo que cambiar el filtro vuelve a
/// ejecutar `fetchProducts()` automáticamente.
class ProductsNotifier extends AsyncNotifier<List<GiftProduct>> {
  ProductsNotifier(this.criteria);

  final GiftSearchCriteria? criteria;

  @override
  Future<List<GiftProduct>> build() async {
    final filter = ref.watch(productFilterProvider);
    final repository = ref.watch(productRepositoryProvider);
    final products = await repository.fetchProducts();
    final byCriteria = filterAndPrioritizeProducts(products, criteria);

    return applyProductFilter(byCriteria, filter);
  }

  Future<DeletedProduct> deleteFromRepository(String id) {
    return ref.read(productRepositoryProvider).deleteProduct(id);
  }

  void removeLocal(DeletedProduct deletion) {
    final current = state.asData?.value;

    if (current == null) {
      return;
    }

    state = AsyncData(
      current
          .where((product) => product.id != deletion.product.id)
          .toList(growable: false),
    );
  }

  Future<void> restore(DeletedProduct deletion) async {
    await ref.read(productRepositoryProvider).restoreProduct(deletion);
    ref.invalidateSelf();
  }
}

final productsProvider = AsyncNotifierProvider.autoDispose
    .family<ProductsNotifier, List<GiftProduct>, GiftSearchCriteria?>(
      ProductsNotifier.new,
      retry: (retryCount, error) => null,
    );
