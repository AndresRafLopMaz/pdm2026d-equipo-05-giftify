import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/features/addresses/data/address_book.dart';
import 'package:giftify/features/addresses/data/sqflite_address_repository.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/ownership/data/ownership_migration_service.dart';
import 'package:giftify/features/products/data/deleted_products_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;
  late AppDatabase appDatabase;
  late SharedPreferences preferences;
  late OwnershipMigrationService service;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    service = OwnershipMigrationService(
      database: appDatabase,
      preferences: preferences,
    );

    final db = await appDatabase.database;
    await db.insert(AppDatabase.usersTable, {
      'id': 1,
      'name': 'Ana',
      'email': 'ana@mail.com',
      'password_hash': 'hash',
      'password_salt': 'salt',
      'created_at': 1,
    });
    await db.insert(AppDatabase.usersTable, {
      'id': 2,
      'name': 'Beto',
      'email': 'beto@mail.com',
      'password_hash': 'hash',
      'password_salt': 'salt',
      'created_at': 2,
    });
  });

  tearDown(() async {
    await appDatabase.close();
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  Future<void> insertLegacyAddress({
    required String id,
    required String label,
    required bool isDefault,
  }) async {
    final db = await appDatabase.database;
    await db.insert(AppDatabase.deliveryAddressesTable, {
      'id': id,
      'user_id': null,
      'label': label,
      'recipient_name': 'Persona',
      'address_line': 'Dirección $id',
      'city': 'Guatemala',
      'department': 'Guatemala',
      'reference': null,
      'archived': 0,
      'is_default': isDefault ? 1 : 0,
    });
  }

  test('claim completo mueve addresses, cart y deleted al claimant', () async {
    await insertLegacyAddress(id: 'legacy-1', label: 'Casa', isDefault: true);
    await insertLegacyAddress(
      id: 'legacy-2',
      label: 'Trabajo',
      isDefault: false,
    );
    await preferences.setString(
      legacyCartStorageKey,
      jsonEncode([
        {'productId': 'gift-001', 'quantity': 2},
        {'productId': 'gift-002', 'quantity': 1},
      ]),
    );
    await preferences.setStringList(legacyDeletedProductsStorageKey, [
      'gift-003',
    ]);

    final result = await service.migrateForUser(1);

    expect(result, OwnershipMigrationResult.completed);
    expect(preferences.getInt(OwnershipMigrationService.claimantKey), 1);
    expect(preferences.getBool(OwnershipMigrationService.completedKey), isTrue);

    final db = await appDatabase.database;
    final addresses = await db.query(
      AppDatabase.deliveryAddressesTable,
      orderBy: 'id',
    );
    expect(addresses, hasLength(2));
    expect(addresses.map((row) => row['user_id']), everyElement(1));

    final cart =
        jsonDecode(preferences.getString(cartKeyForUser(1))!) as List<Object?>;
    expect(cart, hasLength(2));
    expect(preferences.getString(legacyCartStorageKey), isNull);

    final deleted = preferences.getStringList(deletedProductsKeyForUser(1));
    expect(deleted, ['gift-003']);
    expect(preferences.getStringList(legacyDeletedProductsStorageKey), isNull);

    final again = await service.migrateForUser(2);
    expect(again, OwnershipMigrationResult.completed);
    expect(preferences.getStringList(deletedProductsKeyForUser(2)), isNull);
  });

  test('B no reclama legacy mientras A es claimant pendiente', () async {
    await preferences.setInt(OwnershipMigrationService.claimantKey, 1);
    await insertLegacyAddress(id: 'legacy-1', label: 'Casa', isDefault: true);
    await preferences.setString(
      legacyCartStorageKey,
      jsonEncode([
        {'productId': 'gift-001', 'quantity': 2},
      ]),
    );

    final pending = await service.migrateForUser(2);

    expect(pending, OwnershipMigrationResult.pendingForOtherUser);
    expect(preferences.getString(legacyCartStorageKey), isNotNull);
    expect(preferences.getString(cartKeyForUser(2)), isNull);
    final db = await appDatabase.database;
    final legacy = await db.query(
      AppDatabase.deliveryAddressesTable,
      where: 'user_id IS NULL',
    );
    expect(legacy, hasLength(1));

    final completed = await service.migrateForUser(1);
    expect(completed, OwnershipMigrationResult.completed);
    expect(preferences.getString(legacyCartStorageKey), isNull);
    expect(preferences.getString(cartKeyForUser(1)), isNotNull);
  });

  test('retry de carrito no duplica cantidades', () async {
    final targetKey = cartKeyForUser(1);
    await preferences.setString(
      targetKey,
      jsonEncode([
        {'productId': 'gift-001', 'quantity': 3},
      ]),
    );
    await preferences.setString(
      legacyCartStorageKey,
      jsonEncode([
        {'productId': 'gift-001', 'quantity': 2},
        {'productId': 'gift-002', 'quantity': 1},
      ]),
    );

    await service.migrateForUser(1);

    final entries =
        (jsonDecode(preferences.getString(targetKey)!) as List<Object?>)
            .map(CartEntry.fromJson)
            .toList();

    expect(entries.firstWhere((e) => e.productId == 'gift-001').quantity, 3);
    expect(entries.firstWhere((e) => e.productId == 'gift-002').quantity, 1);
    expect(preferences.getString(legacyCartStorageKey), isNull);
  });

  test('claim resuelve label y default en conflicto', () async {
    final repository = SqfliteAddressRepository(
      database: appDatabase,
      userId: 1,
    );
    await repository.create(
      const AddressDraft(
        label: 'Casa',
        recipientName: 'Ana',
        addressLine: 'Dirección propia',
        city: 'Guatemala',
        department: 'Guatemala',
      ),
    );
    await insertLegacyAddress(id: 'legacy-1', label: 'Casa', isDefault: true);

    await service.migrateForUser(1);

    final book = await repository.loadBook();
    expect(book.active, hasLength(2));
    expect(book.active.map((address) => address.label), contains('Casa (2)'));
    expect(book.defaultAddress?.label, 'Casa');
    expect(
      book.active
          .firstWhere((address) => address.label == 'Casa (2)')
          .isDefault,
      isFalse,
    );
  });
}
