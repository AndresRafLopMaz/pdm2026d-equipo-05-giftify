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

  test(
    'migra v1 a v3 conservando direcciones y agrega columnas, índices y users',
    () async {
      final v1Database = await databaseFactoryFfi.openDatabase(
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

      await v1Database.insert(AppDatabase.deliveryAddressesTable, {
        'id': 'addr-v1-001',
        'label': 'Casa',
        'recipient_name': 'María López',
        'address_line': '5a avenida 10-20, zona 1',
        'city': 'Guatemala',
        'department': 'Guatemala',
        'reference': 'Portón verde',
      });
      await v1Database.close();

      final appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      addTearDown(appDatabase.close);

      final db = await appDatabase.database;

      final migratedRows = await db.query(AppDatabase.deliveryAddressesTable);
      expect(migratedRows, hasLength(1));

      final migrated = migratedRows.single;
      expect(migrated['id'], 'addr-v1-001');
      expect(migrated['label'], 'Casa');
      expect(migrated['recipient_name'], 'María López');
      expect(migrated['address_line'], '5a avenida 10-20, zona 1');
      expect(migrated['city'], 'Guatemala');
      expect(migrated['department'], 'Guatemala');
      expect(migrated['reference'], 'Portón verde');
      expect(migrated['archived'], 0);
      expect(migrated['is_default'], 0);
      expect(await db.getVersion(), AppDatabase.version);

      final columns = await db.rawQuery(
        'PRAGMA table_info(${AppDatabase.deliveryAddressesTable})',
      );
      final columnNames = columns.map((row) => row['name']).toSet();
      expect(
        columnNames,
        containsAll(<String>{
          'id',
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
          AppDatabase.labelNocaseIndex,
          AppDatabase.singleDefaultIndex,
          AppDatabase.archivedIndex,
        }),
      );

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      expect(
        tables.map((row) => row['name']),
        contains(AppDatabase.usersTable),
      );

      final userIndexes = await db.rawQuery(
        'PRAGMA index_list(${AppDatabase.usersTable})',
      );
      expect(
        userIndexes.map((row) => row['name']),
        contains(AppDatabase.usersEmailIndex),
      );

      await db.insert(AppDatabase.deliveryAddressesTable, {
        'id': 'addr-v2-002',
        'label': 'Trabajo',
        'recipient_name': 'María López',
        'address_line': '12 calle 3-45, zona 10',
        'city': 'Guatemala',
        'department': 'Guatemala',
        'reference': null,
      });

      await db.update(
        AppDatabase.deliveryAddressesTable,
        {'recipient_name': 'María López Actualizada'},
        where: 'id = ?',
        whereArgs: ['addr-v1-001'],
      );

      await db.update(
        AppDatabase.deliveryAddressesTable,
        {'archived': 1},
        where: 'id = ?',
        whereArgs: ['addr-v2-002'],
      );

      final crudRows = await db.query(
        AppDatabase.deliveryAddressesTable,
        orderBy: 'id',
      );
      expect(crudRows, hasLength(2));
      expect(crudRows.first['id'], 'addr-v1-001');
      expect(crudRows.first['recipient_name'], 'María López Actualizada');
      expect(crudRows.first['archived'], 0);
      expect(crudRows.last['id'], 'addr-v2-002');
      expect(crudRows.last['archived'], 1);

      await expectLater(
        db.insert(AppDatabase.deliveryAddressesTable, {
          'id': 'addr-v2-003',
          'label': 'casa',
          'recipient_name': 'Otra Persona',
          'address_line': 'Otra dirección',
          'city': 'Guatemala',
          'department': 'Guatemala',
          'reference': null,
        }),
        throwsA(isA<DatabaseException>()),
      );

      await db.update(
        AppDatabase.deliveryAddressesTable,
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: ['addr-v1-001'],
      );

      await expectLater(
        db.update(
          AppDatabase.deliveryAddressesTable,
          {'is_default': 1},
          where: 'id = ?',
          whereArgs: ['addr-v2-002'],
        ),
        throwsA(isA<DatabaseException>()),
      );

      await appDatabase.close();

      final reopened = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      addTearDown(reopened.close);

      final reopenedDatabase = await reopened.database;
      final reopenedRows = await reopenedDatabase.query(
        AppDatabase.deliveryAddressesTable,
        orderBy: 'id',
      );
      expect(reopenedRows, hasLength(2));
      expect(reopenedRows.first['id'], 'addr-v1-001');
      expect(reopenedRows.first['recipient_name'], 'María López Actualizada');
      expect(reopenedRows.first['is_default'], 1);
      expect(reopenedRows.last['archived'], 1);
      expect(await reopenedDatabase.getVersion(), AppDatabase.version);
    },
  );

  test('onCreate crea el esquema v3 completo', () async {
    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);

    final db = await appDatabase.database;
    expect(await db.getVersion(), AppDatabase.version);

    final columns = await db.rawQuery(
      'PRAGMA table_info(${AppDatabase.deliveryAddressesTable})',
    );
    final columnNames = columns.map((row) => row['name']).toSet();
    expect(columnNames, containsAll(<String>{'archived', 'is_default'}));

    final indexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.deliveryAddressesTable})',
    );
    final indexNames = indexes.map((row) => row['name']).toSet();
    expect(
      indexNames,
      containsAll(<String>{
        AppDatabase.labelNocaseIndex,
        AppDatabase.singleDefaultIndex,
        AppDatabase.archivedIndex,
      }),
    );

    await db.insert(AppDatabase.deliveryAddressesTable, {
      'id': 'addr-v2-001',
      'label': 'Casa',
      'recipient_name': 'María López',
      'address_line': '5a avenida 10-20, zona 1',
      'city': 'Guatemala',
      'department': 'Guatemala',
      'reference': 'Portón verde',
    });

    final row = (await db.query(AppDatabase.deliveryAddressesTable)).single;
    expect(row['archived'], 0);
    expect(row['is_default'], 0);
  });
}
