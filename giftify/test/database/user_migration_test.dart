import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
  });

  tearDown(() async {
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  Future<void> createV2Database() async {
    final v2 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppDatabase.deliveryAddressesTable} (
              id TEXT PRIMARY KEY,
              label TEXT NOT NULL UNIQUE,
              recipient_name TEXT NOT NULL,
              address_line TEXT NOT NULL,
              city TEXT NOT NULL,
              department TEXT NOT NULL,
              reference TEXT,
              archived INTEGER NOT NULL DEFAULT 0,
              is_default INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX idx_delivery_addresses_label_nocase
            ON ${AppDatabase.deliveryAddressesTable}(label COLLATE NOCASE)
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX idx_delivery_addresses_single_default
            ON ${AppDatabase.deliveryAddressesTable}(is_default)
            WHERE is_default = 1
          ''');
          await db.execute('''
            CREATE INDEX idx_delivery_addresses_archived
            ON ${AppDatabase.deliveryAddressesTable}(archived)
          ''');
        },
      ),
    );

    await v2.insert(AppDatabase.deliveryAddressesTable, {
      'id': 'addr-v2-001',
      'label': 'Casa',
      'recipient_name': 'María López',
      'address_line': '5a avenida 10-20, zona 1',
      'city': 'Guatemala',
      'department': 'Guatemala',
      'reference': 'Portón verde',
      'archived': 0,
      'is_default': 1,
    });
    await v2.close();
  }

  Future<void> createV3Database() async {
    final v3 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppDatabase.deliveryAddressesTable} (
              id TEXT PRIMARY KEY,
              label TEXT NOT NULL UNIQUE,
              recipient_name TEXT NOT NULL,
              address_line TEXT NOT NULL,
              city TEXT NOT NULL,
              department TEXT NOT NULL,
              reference TEXT,
              archived INTEGER NOT NULL DEFAULT 0,
              is_default INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX idx_delivery_addresses_label_nocase
            ON ${AppDatabase.deliveryAddressesTable}(label COLLATE NOCASE)
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX idx_delivery_addresses_single_default
            ON ${AppDatabase.deliveryAddressesTable}(is_default)
            WHERE is_default = 1
          ''');
          await db.execute('''
            CREATE INDEX idx_delivery_addresses_archived
            ON ${AppDatabase.deliveryAddressesTable}(archived)
          ''');
          await db.execute('''
            CREATE TABLE ${AppDatabase.usersTable} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              email TEXT NOT NULL,
              password_hash TEXT NOT NULL,
              password_salt TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX ${AppDatabase.usersEmailIndex}
            ON ${AppDatabase.usersTable}(email COLLATE NOCASE)
          ''');
        },
      ),
    );

    await v3.insert(AppDatabase.usersTable, {
      'id': 1,
      'name': 'Ana',
      'email': 'ana@mail.com',
      'password_hash': 'hash',
      'password_salt': 'salt',
      'created_at': 1,
    });
    await v3.insert(AppDatabase.deliveryAddressesTable, {
      'id': 'addr-v3-001',
      'label': 'Casa',
      'recipient_name': 'María López',
      'address_line': '5a avenida 10-20, zona 1',
      'city': 'Guatemala',
      'department': 'Guatemala',
      'reference': null,
      'archived': 0,
      'is_default': 1,
    });
    await v3.close();
  }

  test('migra v2 a v4 preservando direcciones y agregando users', () async {
    await createV2Database();

    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    expect(await db.getVersion(), 4);
    expect(
      (await db.rawQuery('PRAGMA foreign_keys')).single['foreign_keys'],
      1,
    );

    final users = await db.query(AppDatabase.usersTable);
    expect(users, isEmpty);

    final addresses = await db.query(AppDatabase.deliveryAddressesTable);
    expect(addresses, hasLength(1));
    expect(addresses.single['id'], 'addr-v2-001');
    expect(addresses.single['user_id'], isNull);

    final indexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.deliveryAddressesTable})',
    );
    expect(
      indexes.map((row) => row['name']),
      containsAll(<String>{
        AppDatabase.userLabelIndex,
        AppDatabase.userDefaultIndex,
        AppDatabase.userArchivedIndex,
      }),
    );
    expect(
      indexes.map((row) => row['name']),
      isNot(contains('idx_delivery_addresses_label_nocase')),
    );
    expect(
      indexes.map((row) => row['name']),
      isNot(contains('idx_delivery_addresses_single_default')),
    );
  });

  test('migra v3 a v4 conservando users y addresses', () async {
    await createV3Database();

    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    expect(await db.getVersion(), 4);

    final users = await db.query(AppDatabase.usersTable);
    expect(users, hasLength(1));
    expect(users.single['email'], 'ana@mail.com');

    final addresses = await db.query(AppDatabase.deliveryAddressesTable);
    expect(addresses, hasLength(1));
    expect(addresses.single['id'], 'addr-v3-001');
    expect(addresses.single['user_id'], isNull);
    expect(addresses.single['is_default'], 1);
  });

  test('fresh v4 crea users, addresses scoped e índices', () async {
    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    expect(await db.getVersion(), 4);
    expect(
      (await db.rawQuery('PRAGMA foreign_keys')).single['foreign_keys'],
      1,
    );

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final names = tables.map((row) => row['name']).toSet();
    expect(names, contains(AppDatabase.usersTable));
    expect(names, contains(AppDatabase.deliveryAddressesTable));
    expect(names, isNot(contains('payment_methods')));

    final userColumns = await db.rawQuery(
      'PRAGMA table_info(${AppDatabase.usersTable})',
    );
    expect(
      userColumns.map((row) => row['name']),
      containsAll(<String>{
        'id',
        'name',
        'email',
        'password_hash',
        'password_salt',
        'created_at',
      }),
    );

    final addressColumns = await db.rawQuery(
      'PRAGMA table_info(${AppDatabase.deliveryAddressesTable})',
    );
    expect(
      addressColumns.map((row) => row['name']),
      containsAll(<String>{'id', 'user_id', 'label', 'archived', 'is_default'}),
    );
  });

  test('users.email sigue siendo único sin distinguir mayúsculas', () async {
    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    await db.insert(AppDatabase.usersTable, {
      'name': 'Ana',
      'email': 'ana@mail.com',
      'password_hash': 'hash',
      'password_salt': 'salt',
      'created_at': 1,
    });

    await expectLater(
      db.insert(AppDatabase.usersTable, {
        'name': 'Otra',
        'email': 'ANA@MAIL.COM',
        'password_hash': 'hash',
        'password_salt': 'salt',
        'created_at': 2,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('ON DELETE CASCADE elimina direcciones al borrar el usuario', () async {
    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    final userId = await db.insert(AppDatabase.usersTable, {
      'name': 'Ana',
      'email': 'cascade@mail.com',
      'password_hash': 'hash',
      'password_salt': 'salt',
      'created_at': 1,
    });
    await db.insert(AppDatabase.deliveryAddressesTable, {
      'id': 'addr-cascade',
      'user_id': userId,
      'label': 'Casa',
      'recipient_name': 'Ana',
      'address_line': 'Dirección',
      'city': 'Guatemala',
      'department': 'Guatemala',
      'archived': 0,
      'is_default': 1,
    });

    await db.delete(
      AppDatabase.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
    );

    expect(
      await db.query(
        AppDatabase.deliveryAddressesTable,
        where: 'id = ?',
        whereArgs: ['addr-cascade'],
      ),
      isEmpty,
    );
  });
}
