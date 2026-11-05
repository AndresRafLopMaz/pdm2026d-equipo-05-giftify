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

  Future<void> expectScopedAddressSchema(Database db) async {
    expect(await db.getVersion(), AppDatabase.version);
    expect(
      (await db.rawQuery('PRAGMA foreign_keys')).single['foreign_keys'],
      1,
    );

    final columns = await db.rawQuery(
      'PRAGMA table_info(${AppDatabase.deliveryAddressesTable})',
    );
    expect(
      columns.map((row) => row['name']),
      containsAll(<String>{
        'id',
        'user_id',
        'label',
        'recipient_name',
        'address_line',
        'city',
        'department',
        'reference',
        'archived',
        'is_default',
      }),
    );

    final indexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.deliveryAddressesTable})',
    );
    final indexNames = indexes.map((row) => row['name']).toSet();
    expect(
      indexNames,
      containsAll(<String>{
        AppDatabase.userLabelIndex,
        AppDatabase.userDefaultIndex,
        AppDatabase.userArchivedIndex,
      }),
    );
    expect(indexNames, isNot(contains('idx_delivery_addresses_label_nocase')));
    expect(
      indexNames,
      isNot(contains('idx_delivery_addresses_single_default')),
    );
  }

  test(
    'migra v1 a v4 conservando direcciones y creando schema scoped',
    () async {
      final v1 = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
            CREATE TABLE ${AppDatabase.deliveryAddressesTable} (
              id TEXT PRIMARY KEY,
              label TEXT NOT NULL UNIQUE,
              recipient_name TEXT NOT NULL,
              address_line TEXT NOT NULL,
              city TEXT NOT NULL,
              department TEXT NOT NULL,
              reference TEXT
            )
          ''');
          },
        ),
      );

      await v1.insert(AppDatabase.deliveryAddressesTable, {
        'id': 'addr-v1-001',
        'label': 'Casa',
        'recipient_name': 'María López',
        'address_line': '5a avenida 10-20, zona 1',
        'city': 'Guatemala',
        'department': 'Guatemala',
        'reference': 'Portón verde',
      });
      await v1.close();

      final appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      addTearDown(appDatabase.close);
      final db = await appDatabase.database;

      await expectScopedAddressSchema(db);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final tableNames = tables.map((row) => row['name']).toSet();
      expect(tableNames, contains(AppDatabase.usersTable));
      expect(tableNames, isNot(contains('payment_methods')));

      final rows = await db.query(AppDatabase.deliveryAddressesTable);
      expect(rows, hasLength(1));
      expect(rows.single['id'], 'addr-v1-001');
      expect(rows.single['label'], 'Casa');
      expect(rows.single['user_id'], isNull);
      expect(rows.single['archived'], 0);
      expect(rows.single['is_default'], 0);
    },
  );

  test('fresh v4 crea users, addresses scoped e índices', () async {
    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    await expectScopedAddressSchema(db);

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    expect(
      tables.map((row) => row['name']),
      containsAll(<String>{
        AppDatabase.usersTable,
        AppDatabase.deliveryAddressesTable,
      }),
    );
    expect(
      tables.map((row) => row['name']),
      isNot(contains('payment_methods')),
    );
  });
}
