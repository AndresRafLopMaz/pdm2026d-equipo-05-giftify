import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Datos mínimos necesarios para reconstruir un elemento del carrito.
class CartEntry {
  const CartEntry({required this.productId, required this.quantity});

  factory CartEntry.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('La entrada del carrito no es válida.');
    }

    final productId = json['productId'];
    final quantity = json['quantity'];
    if (productId is! String ||
        productId.trim().isEmpty ||
        quantity is! int ||
        quantity < 1) {
      throw const FormatException('La entrada del carrito está incompleta.');
    }

    return CartEntry(productId: productId, quantity: quantity);
  }

  final String productId;
  final int quantity;

  Map<String, Object> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}

/// Almacenamiento de las entradas persistidas del carrito.
abstract class CartStore {
  /// Identifica el recurso compartido que debe serializar sus escrituras.
  Object get synchronizationKey => this;

  Future<List<CartEntry>> load();

  Future<void> save(List<CartEntry> entries);
}

/// Implementación en memoria para pruebas.
class InMemoryCartStore extends CartStore {
  InMemoryCartStore([List<CartEntry> initialEntries = const []])
    : _entries = List<CartEntry>.of(initialEntries);

  List<CartEntry> _entries;

  @override
  Future<List<CartEntry>> load() async =>
      List<CartEntry>.unmodifiable(_entries);

  @override
  Future<void> save(List<CartEntry> entries) async {
    _entries = List<CartEntry>.of(entries);
  }
}

/// Persistencia local basada exclusivamente en `productId` y `quantity`.
class SharedPreferencesCartStore extends CartStore {
  static const String storageKey = 'giftify.cart_entries';

  @override
  Object get synchronizationKey => storageKey;

  @override
  Future<List<CartEntry>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(storageKey);
    if (encoded == null) {
      return const [];
    }

    final decoded = jsonDecode(encoded);
    if (decoded is! List<Object?>) {
      throw const FormatException('El carrito persistido no es una lista.');
    }

    return decoded.map(CartEntry.fromJson).toList(growable: false);
  }

  @override
  Future<void> save(List<CartEntry> entries) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    final saved = await preferences.setString(storageKey, encoded);
    if (!saved) {
      throw StateError('No se pudo guardar el carrito.');
    }
  }
}
