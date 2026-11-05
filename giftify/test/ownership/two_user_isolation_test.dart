import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/features/addresses/data/address_book.dart';
import 'package:giftify/features/addresses/data/sqflite_address_repository.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/products/data/deleted_products_store.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;
  late AppDatabase appDatabase;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    final db = await appDatabase.database;
    for (final idAndEmail in [(1, 'ana@mail.com'), (2, 'beto@mail.com')]) {
      await db.insert(AppDatabase.usersTable, {
        'id': idAndEmail.$1,
        'name': 'User ${idAndEmail.$1}',
        'email': idAndEmail.$2,
        'password_hash': 'hash',
        'password_salt': 'salt',
        'created_at': idAndEmail.$1,
      });
    }
  });

  tearDown(() async {
    await appDatabase.close();
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  test('A y B no comparten addresses, cart ni deleted products', () async {
    final addressA = SqfliteAddressRepository(database: appDatabase, userId: 1);
    final addressB = SqfliteAddressRepository(database: appDatabase, userId: 2);
    await addressA.create(
      const AddressDraft(
        label: 'Casa',
        recipientName: 'Ana',
        addressLine: 'Dirección A',
        city: 'Guatemala',
        department: 'Guatemala',
      ),
    );
    await addressB.create(
      const AddressDraft(
        label: 'Casa',
        recipientName: 'Beto',
        addressLine: 'Dirección B',
        city: 'Guatemala',
        department: 'Guatemala',
      ),
    );

    final cartA = PersistentCartRepository(
      store: SharedPreferencesCartStore(userId: 1),
    );
    final cartB = PersistentCartRepository(
      store: SharedPreferencesCartStore(userId: 2),
    );
    await cartA.addItems([CartItem(product: mockProducts[0], quantity: 2)]);
    await cartB.addItems([CartItem(product: mockProducts[1], quantity: 1)]);

    final deletedA = SharedPreferencesDeletedProductsStore(userId: 1);
    final deletedB = SharedPreferencesDeletedProductsStore(userId: 2);
    await deletedA.add('gift-001');
    await deletedB.add('gift-002');

    expect((await addressA.loadBook()).active.single.recipientName, 'Ana');
    expect((await addressB.loadBook()).active.single.recipientName, 'Beto');
    expect((await cartA.loadItems()).single.product.id, mockProducts[0].id);
    expect((await cartB.loadItems()).single.product.id, mockProducts[1].id);
    expect(await deletedA.load(), {'gift-001'});
    expect(await deletedB.load(), {'gift-002'});
  });
}
