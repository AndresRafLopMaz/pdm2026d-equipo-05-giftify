import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia local de los IDs de productos eliminados.
abstract class DeletedProductsStore {
  Future<Set<String>> load();

  Future<void> add(String productId);

  Future<void> remove(String productId);
}

/// Implementación en memoria para pruebas y para el repositorio por defecto.
class InMemoryDeletedProductsStore implements DeletedProductsStore {
  final Set<String> _ids = {};

  @override
  Future<Set<String>> load() async => Set<String>.unmodifiable(_ids);

  @override
  Future<void> add(String productId) async {
    _ids.add(productId);
  }

  @override
  Future<void> remove(String productId) async {
    _ids.remove(productId);
  }
}

/// Implementación persistente usada por la aplicación.
class SharedPreferencesDeletedProductsStore implements DeletedProductsStore {
  static const String _key = 'giftify.deleted_product_ids';

  @override
  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? <String>{};
  }

  @override
  Future<void> add(String productId) async {
    final ids = await load();
    ids.add(productId);
    await _save(ids);
  }

  @override
  Future<void> remove(String productId) async {
    final ids = await load();
    ids.remove(productId);
    await _save(ids);
  }

  Future<void> _save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList()..sort());
  }
}
