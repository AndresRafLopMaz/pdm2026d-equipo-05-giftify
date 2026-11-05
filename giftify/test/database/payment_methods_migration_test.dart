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

  Future<void> createV4Database() async {
    final v4 = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
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
          await db.execute('''
            CREATE TABLE ${AppDatabase.deliveryAddressesTable} (
              id TEXT PRIMARY KEY,
              user_id INTEGER
                REFERENCES ${AppDatabase.usersTable}(id) ON DELETE CASCADE,
              label TEXT NOT NULL,
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
            CREATE UNIQUE INDEX ${AppDatabase.userLabelIndex}
            ON ${AppDatabase.deliveryAddressesTable}(user_id, label COLLATE NOCASE)
            WHERE user_id IS NOT NULL
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX ${AppDatabase.userDefaultIndex}
            ON ${AppDatabase.deliveryAddressesTable}(user_id)
            WHERE is_default = 1 AND user_id IS NOT NULL
          ''');
          await db.execute('''
            CREATE INDEX ${AppDatabase.userArchivedIndex}
            ON ${AppDatabase.deliveryAddressesTable}(user_id, archived)
          ''');
        },
      ),
    );
    await v4.insert(AppDatabase.usersTable, {
      'id': 1,
      'name': 'Ana',
      'email': 'ana@mail.com',
      'password_hash': 'hash',
      'password_salt': 'salt',
      'created_at': 1,
    });
    await v4.insert(AppDatabase.deliveryAddressesTable, {
      'id': 'addr-v4-001',
      'user_id': 1,
      'label': 'Casa',
      'recipient_name': 'Ana',
      'address_line': 'Dirección',
      'city': 'Guatemala',
      'department': 'Guatemala',
      'reference': null,
      'archived': 0,
      'is_default': 1,
    });
    await v4.close();
  }

  test('migra v4 a v5 y preserva users y addresses', () async {
    await createV4Database();

    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    expect(await db.getVersion(), 5);
    expect(
      (await db.rawQuery('PRAGMA foreign_keys')).single['foreign_keys'],
      1,
    );

    expect(await db.query(AppDatabase.usersTable), hasLength(1));
    final addresses = await db.query(AppDatabase.deliveryAddressesTable);
    expect(addresses, hasLength(1));
    expect(addresses.single['id'], 'addr-v4-001');

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    expect(
      tables.map((row) => row['name']),
      contains(AppDatabase.paymentMethodsTable),
    );

    final columns = await db.rawQuery(
      'PRAGMA table_info(${AppDatabase.paymentMethodsTable})',
    );
    expect(
      columns.map((row) => row['name']),
      containsAll(<String>{
        'id',
        'user_id',
        'holder_name',
        'brand',
        'last4',
        'expiry_month',
        'expiry_year',
        'is_default',
      }),
    );

    final indexes = await db.rawQuery(
      'PRAGMA index_list(${AppDatabase.paymentMethodsTable})',
    );
    final indexNames = indexes.map((row) => row['name']);
    expect(
      indexNames,
      containsAll(<String>{
        AppDatabase.paymentMethodsUserIndex,
        AppDatabase.paymentMethodsDefaultIndex,
      }),
    );
  });

  test('fresh v5 crea payment_methods con constraints válidos', () async {
    final appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(appDatabase.close);
    final db = await appDatabase.database;

    expect(await db.getVersion(), 5);
    expect(
      (await db.rawQuery('PRAGMA foreign_keys')).single['foreign_keys'],
      1,
    );

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

    await db.insert(AppDatabase.paymentMethodsTable, {
      'id': 'pay-1',
      'user_id': 1,
      'holder_name': 'Ana',
      'brand': 'visa',
      'last4': '4242',
      'expiry_month': 8,
      'expiry_year': 2030,
      'is_default': 1,
    });
    await db.insert(AppDatabase.paymentMethodsTable, {
      'id': 'pay-2',
      'user_id': 2,
      'holder_name': 'Beto',
      'brand': 'mastercard',
      'last4': '4444',
      'expiry_month': 9,
      'expiry_year': 2031,
      'is_default': 1,
    });

    await expectLater(
      db.insert(AppDatabase.paymentMethodsTable, {
        'id': 'pay-invalid-brand',
        'user_id': 1,
        'holder_name': 'Ana',
        'brand': 'discover',
        'last4': '1111',
        'expiry_month': 8,
        'expiry_year': 2030,
        'is_default': 0,
      }),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      db.insert(AppDatabase.paymentMethodsTable, {
        'id': 'pay-invalid-last4',
        'user_id': 1,
        'holder_name': 'Ana',
        'brand': 'visa',
        'last4': '42A2',
        'expiry_month': 8,
        'expiry_year': 2030,
        'is_default': 0,
      }),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      db.insert(AppDatabase.paymentMethodsTable, {
        'id': 'pay-invalid-month',
        'user_id': 1,
        'holder_name': 'Ana',
        'brand': 'visa',
        'last4': '1111',
        'expiry_month': 13,
        'expiry_year': 2030,
        'is_default': 0,
      }),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      db.insert(AppDatabase.paymentMethodsTable, {
        'id': 'pay-invalid-default',
        'user_id': 1,
        'holder_name': 'Ana',
        'brand': 'visa',
        'last4': '1111',
        'expiry_month': 8,
        'expiry_year': 2030,
        'is_default': 2,
      }),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      db.insert(AppDatabase.paymentMethodsTable, {
        'id': 'pay-invalid-user',
        'user_id': 999,
        'holder_name': 'Ana',
        'brand': 'visa',
        'last4': '1111',
        'expiry_month': 8,
        'expiry_year': 2030,
        'is_default': 0,
      }),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      db.insert(AppDatabase.paymentMethodsTable, {
        'id': 'pay-duplicate-default',
        'user_id': 1,
        'holder_name': 'Ana',
        'brand': 'amex',
        'last4': '1111',
        'expiry_month': 8,
        'expiry_year': 2030,
        'is_default': 1,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });
}
