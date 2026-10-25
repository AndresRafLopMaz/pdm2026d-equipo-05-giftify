import '../../../shared/data/mock_products.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/gift_product.dart';
import 'cart_repository.dart';
import 'cart_store.dart';

/// Repositorio que reconstruye el carrito desde el catálogo local.
class PersistentCartRepository implements CartRepository {
  PersistentCartRepository({
    required this.store,
    List<GiftProduct> catalog = mockProducts,
  }) : _catalogById = _indexCatalog(catalog);

  static final Map<Object, Future<void>> _operations = {};

  final CartStore store;
  final Map<String, GiftProduct> _catalogById;

  static Map<String, GiftProduct> _indexCatalog(List<GiftProduct> catalog) {
    final products = <String, GiftProduct>{};
    for (final product in catalog) {
      if (products.containsKey(product.id)) {
        throw ArgumentError.value(
          product.id,
          'catalog',
          'El catálogo contiene IDs duplicados.',
        );
      }
      products[product.id] = product;
    }
    return Map<String, GiftProduct>.unmodifiable(products);
  }

  @override
  Future<List<CartItem>> loadItems() {
    return _serialize(() async => _hydrate(await store.load()));
  }

  @override
  Future<List<CartItem>> addItems(List<CartItem> incoming) {
    return _serialize(() async {
      if (incoming.isEmpty) {
        return _hydrate(await store.load());
      }

      for (final item in incoming) {
        _productFor(item.product.id);
        if (item.quantity < 1) {
          throw ArgumentError.value(item.quantity, 'quantity');
        }
      }

      final entries = List<CartEntry>.of(await store.load());
      for (final item in incoming) {
        final index = entries.indexWhere(
          (entry) => entry.productId == item.product.id,
        );
        if (index == -1) {
          entries.add(
            CartEntry(productId: item.product.id, quantity: item.quantity),
          );
        } else {
          final current = entries[index];
          entries[index] = CartEntry(
            productId: current.productId,
            quantity: current.quantity + item.quantity,
          );
        }
      }

      _validateUniqueEntries(entries);
      await store.save(entries);
      return _hydrate(entries);
    });
  }

  @override
  Future<CartItem> updateQuantity(String productId, int quantity) {
    return _serialize(() async {
      if (quantity < 1) {
        throw ArgumentError.value(quantity, 'quantity');
      }

      final entries = List<CartEntry>.of(await store.load());
      _validateUniqueEntries(entries);
      final index = entries.indexWhere((entry) => entry.productId == productId);
      if (index == -1) {
        throw StateError('El producto $productId no está en el carrito.');
      }

      entries[index] = CartEntry(productId: productId, quantity: quantity);
      await store.save(entries);
      return CartItem(product: _productFor(productId), quantity: quantity);
    });
  }

  @override
  Future<RemovedCartItem> removeItem(String productId) {
    return _serialize(() async {
      final entries = List<CartEntry>.of(await store.load());
      _validateUniqueEntries(entries);
      final index = entries.indexWhere((entry) => entry.productId == productId);
      if (index == -1) {
        throw StateError('El producto $productId no está en el carrito.');
      }

      final entry = entries.removeAt(index);
      await store.save(entries);
      return RemovedCartItem(
        item: CartItem(
          product: _productFor(entry.productId),
          quantity: entry.quantity,
        ),
        index: index,
      );
    });
  }

  @override
  Future<void> restoreItem(RemovedCartItem removed) {
    return _serialize(() async {
      final productId = removed.item.product.id;
      _productFor(productId);
      final entries = List<CartEntry>.of(await store.load());
      _validateUniqueEntries(entries);
      if (entries.any((entry) => entry.productId == productId)) {
        throw StateError('El producto $productId ya está en el carrito.');
      }

      final index = removed.index.clamp(0, entries.length);
      entries.insert(
        index,
        CartEntry(productId: productId, quantity: removed.item.quantity),
      );
      await store.save(entries);
    });
  }

  GiftProduct _productFor(String productId) {
    final product = _catalogById[productId];
    if (product == null) {
      throw StateError(
        'No existe el producto $productId en el catálogo local.',
      );
    }
    return product;
  }

  List<CartItem> _hydrate(List<CartEntry> entries) {
    _validateUniqueEntries(entries);
    return entries
        .map(
          (entry) => CartItem(
            product: _productFor(entry.productId),
            quantity: entry.quantity,
          ),
        )
        .toList(growable: false);
  }

  void _validateUniqueEntries(List<CartEntry> entries) {
    final ids = <String>{};
    for (final entry in entries) {
      if (!ids.add(entry.productId)) {
        throw StateError(
          'El carrito contiene el producto ${entry.productId} más de una vez.',
        );
      }
    }
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final key = store.synchronizationKey;
    final previous = _operations[key] ?? Future<void>.value();
    final result = previous.then((_) => action());
    _operations[key] = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }
}
