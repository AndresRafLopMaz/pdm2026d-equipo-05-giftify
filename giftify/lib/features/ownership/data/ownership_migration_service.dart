import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../cart/data/cart_store.dart';
import '../../products/data/deleted_products_store.dart';

enum OwnershipMigrationResult { notNeeded, completed, pendingForOtherUser }

class OwnershipMigrationException implements Exception {
  const OwnershipMigrationException();
}

class OwnershipMigrationService {
  OwnershipMigrationService({AppDatabase? database, this.preferences})
    : _database = database ?? AppDatabase.instance;

  static const String completedKey = 'giftify.ownership_migration_v1_completed';
  static const String claimantKey =
      'giftify.ownership_migration_v1_claimant_user_id';

  final AppDatabase _database;
  final SharedPreferences? preferences;

  Future<SharedPreferences> get _prefs async {
    return preferences ?? await SharedPreferences.getInstance();
  }

  Future<OwnershipMigrationResult> migrateForUser(int userId) async {
    final preferences = await _prefs;
    if (preferences.getBool(completedKey) ?? false) {
      return OwnershipMigrationResult.completed;
    }

    var claimant = preferences.getInt(claimantKey);
    if (claimant == null) {
      claimant = userId;
      final saved = await preferences.setInt(claimantKey, userId);
      if (!saved) {
        throw const OwnershipMigrationException();
      }
    }

    if (claimant != userId) {
      return OwnershipMigrationResult.pendingForOtherUser;
    }

    await _claimAddresses(userId);
    await _claimCart(userId, preferences);
    await _claimDeletedProducts(userId, preferences);

    final completed = await preferences.setBool(completedKey, true);
    if (!completed) {
      throw const OwnershipMigrationException();
    }

    return OwnershipMigrationResult.completed;
  }

  Future<void> _claimAddresses(int userId) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      final legacyRows = await txn.query(
        AppDatabase.deliveryAddressesTable,
        where: 'user_id IS NULL',
        orderBy: 'id ASC',
      );
      if (legacyRows.isEmpty) {
        return;
      }

      final existingLabels = await txn.query(
        AppDatabase.deliveryAddressesTable,
        columns: const ['label'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      final usedLabels = existingLabels
          .map((row) => (row['label']! as String).toLowerCase())
          .toSet();

      final defaultRows = await txn.query(
        AppDatabase.deliveryAddressesTable,
        columns: const ['id'],
        where: 'user_id = ? AND is_default = 1 AND archived = 0',
        whereArgs: [userId],
        limit: 1,
      );
      var hasDefault = defaultRows.isNotEmpty;

      for (final row in legacyRows) {
        final id = row['id']! as String;
        final rawLabel = (row['label'] as String? ?? '').trim();
        final baseLabel = rawLabel.isEmpty ? 'Dirección heredada' : rawLabel;
        final label = _uniqueLabel(baseLabel, usedLabels);
        usedLabels.add(label.toLowerCase());

        final legacyDefault =
            (row['is_default'] as int? ?? 0) == 1 &&
            (row['archived'] as int? ?? 0) == 0;
        final keepDefault = legacyDefault && !hasDefault;
        if (keepDefault) {
          hasDefault = true;
        }

        await txn.update(
          AppDatabase.deliveryAddressesTable,
          {
            'user_id': userId,
            'label': label,
            'is_default': keepDefault ? 1 : 0,
          },
          where: 'id = ? AND user_id IS NULL',
          whereArgs: [id],
        );
      }
    });
  }

  String _uniqueLabel(String baseLabel, Set<String> usedLabels) {
    var candidate = baseLabel;
    var suffix = 2;

    while (usedLabels.contains(candidate.toLowerCase())) {
      candidate = '$baseLabel ($suffix)';
      suffix += 1;
    }

    return candidate;
  }

  Future<void> _claimCart(int userId, SharedPreferences preferences) async {
    final legacy = preferences.getString(legacyCartStorageKey);
    if (legacy == null) {
      return;
    }

    final targetKey = cartKeyForUser(userId);
    final target = _decodeCart(preferences.getString(targetKey));
    final merged = _mergeCart(target, _decodeCart(legacy));

    final saved = await preferences.setString(
      targetKey,
      jsonEncode(merged.map((entry) => entry.toJson()).toList()),
    );
    if (!saved) {
      throw const OwnershipMigrationException();
    }

    final removed = await preferences.remove(legacyCartStorageKey);
    if (!removed) {
      throw const OwnershipMigrationException();
    }
  }

  List<CartEntry> _decodeCart(String? encoded) {
    if (encoded == null) {
      return const [];
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List<Object?>) {
        return const [];
      }

      final entries = <CartEntry>[];
      for (final item in decoded) {
        try {
          entries.add(CartEntry.fromJson(item));
        } on FormatException {
          continue;
        }
      }
      return entries;
    } catch (_) {
      return const [];
    }
  }

  List<CartEntry> _mergeCart(List<CartEntry> target, List<CartEntry> legacy) {
    final byProduct = <String, CartEntry>{};

    void mergeEntry(CartEntry entry) {
      final existing = byProduct[entry.productId];
      if (existing == null || entry.quantity > existing.quantity) {
        byProduct[entry.productId] = entry;
      }
    }

    for (final entry in target) {
      mergeEntry(entry);
    }
    for (final entry in legacy) {
      mergeEntry(entry);
    }

    return byProduct.values.toList(growable: false);
  }

  Future<void> _claimDeletedProducts(
    int userId,
    SharedPreferences preferences,
  ) async {
    final legacy = preferences.getStringList(legacyDeletedProductsStorageKey);
    if (legacy == null) {
      return;
    }

    final targetKey = deletedProductsKeyForUser(userId);
    final merged = <String>{
      ...?preferences.getStringList(targetKey),
      ...legacy,
    };

    final saved = await preferences.setStringList(
      targetKey,
      merged.toList()..sort(),
    );
    if (!saved) {
      throw const OwnershipMigrationException();
    }

    final removed = await preferences.remove(legacyDeletedProductsStorageKey);
    if (!removed) {
      throw const OwnershipMigrationException();
    }
  }
}
