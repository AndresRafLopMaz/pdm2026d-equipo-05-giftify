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
            CREATE UNIQUE INDEX ${AppDatabase.labelNocaseIndex}
            ON ${AppDatabase.deliveryAddressesTable}(label COLLATE NOCASE)
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX ${AppDatabase.singleDefaultIndex}
            ON ${AppDatabase.deliveryAddressesTable}(is_default)
            WHERE is_default = 1
          ''');
          await db.execute('''
            CREATE INDEX ${AppDatabase.archivedIndex}
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

  test('migra v2 a v3 conservando direcciones y crea users', () async {
    await createV2Database();

    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    expect(await db.getVersion(), 3);

    final addresses = await db.query(AppDatabase.deliveryAddressesTable);
    expect(addresses, hasLength(1));
    expect(addresses.single['id'], 'addr-v2-001');
    expect(addresses.single['recipient_name'], 'María López');
    expect(addresses.single['is_default'], 1);

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    expect(tables.map((row) => row['name']), contains(AppDatabase.usersTable));

    final addressIndexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.deliveryAddressesTable})',
    );
    expect(
      addressIndexes.map((row) => row['name']),
      containsAll(<String>{
        AppDatabase.labelNocaseIndex,
        AppDatabase.singleDefaultIndex,
        AppDatabase.archivedIndex,
      }),
    );

    final userIndexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.usersTable})',
    );
    expect(
      userIndexes.map((row) => row['name']),
      contains(AppDatabase.usersEmailIndex),
    );
  });

  test('fresh v3 crea direcciones, users e índices', () async {
    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    expect(await db.getVersion(), 3);

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final names = tables.map((row) => row['name']).toSet();
    expect(names, contains(AppDatabase.deliveryAddressesTable));
    expect(names, contains(AppDatabase.usersTable));

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

    final addressIndexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.deliveryAddressesTable})',
    );
    expect(
      addressIndexes.map((row) => row['name']),
      containsAll(<String>{
        AppDatabase.labelNocaseIndex,
        AppDatabase.singleDefaultIndex,
        AppDatabase.archivedIndex,
      }),
    );

    final userIndexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.usersTable})',
    );
    expect(
      userIndexes.map((row) => row['name']),
      contains(AppDatabase.usersEmailIndex),
    );
  });

  test('users.email es único sin distinguir mayúsculas', () async {
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
}
