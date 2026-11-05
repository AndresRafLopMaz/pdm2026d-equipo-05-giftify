import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/features/payments/data/payment_method_errors.dart';
import 'package:giftify/features/payments/data/sqflite_payment_method_repository.dart';
import 'package:giftify/shared/enums/payment_brand.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;
  late AppDatabase appDatabase;
  late SqflitePaymentMethodRepository repository;
  final now = DateTime(2026, 11, 5);

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

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

    repository = SqflitePaymentMethodRepository(
      database: appDatabase,
      userId: 1,
      now: now,
    );
  });

  tearDown(() async {
    await appDatabase.close();
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  Future<dynamic> createVisa({String last4 = '4242', bool isDefault = false}) {
    return repository.create(
      holderName: 'Ana',
      brand: PaymentBrand.visa,
      last4: last4,
      expiryMonth: 8,
      expiryYear: 2030,
      isDefault: isDefault,
    );
  }

  test('primer método queda predeterminado y lista ordenada', () async {
    final visa = await createVisa();
    final mastercard = await repository.create(
      holderName: 'Ana',
      brand: PaymentBrand.mastercard,
      last4: '4444',
      expiryMonth: 9,
      expiryYear: 2031,
    );

    final methods = await repository.list();
    expect(methods.map((method) => method.id), [visa.id, mastercard.id]);
    expect(visa.isDefault, isTrue);
    expect(mastercard.isDefault, isFalse);
  });

  test('setDefault solo afecta al usuario actual', () async {
    final visa = await createVisa();
    final mastercard = await repository.create(
      holderName: 'Ana',
      brand: PaymentBrand.mastercard,
      last4: '4444',
      expiryMonth: 9,
      expiryYear: 2031,
    );

    await repository.setDefault(mastercard.id);

    final methods = await repository.list();
    expect(methods.first.id, mastercard.id);
    expect(methods.first.isDefault, isTrue);
    expect(methods.last.isDefault, isFalse);
    expect(visa.id, isNot(methods.first.id));
  });

  test('eliminar un método no default no altera el default', () async {
    final visa = await createVisa();
    final mastercard = await repository.create(
      holderName: 'Ana',
      brand: PaymentBrand.mastercard,
      last4: '4444',
      expiryMonth: 9,
      expiryYear: 2031,
    );

    await repository.delete(mastercard.id);

    final methods = await repository.list();
    expect(methods.single.id, visa.id);
    expect(methods.single.isDefault, isTrue);
  });

  test('eliminar el default promueve otro método', () async {
    final visa = await createVisa();
    final mastercard = await repository.create(
      holderName: 'Ana',
      brand: PaymentBrand.mastercard,
      last4: '4444',
      expiryMonth: 9,
      expiryYear: 2031,
    );
    await repository.setDefault(mastercard.id);

    await repository.delete(mastercard.id);

    final methods = await repository.list();
    expect(methods.single.id, visa.id);
    expect(methods.single.isDefault, isTrue);
  });

  test('delete y setDefault no cruzan usuarios', () async {
    final repository2 = SqflitePaymentMethodRepository(
      database: appDatabase,
      userId: 2,
      now: now,
    );
    final visa = await createVisa();
    final otra = await repository2.create(
      holderName: 'Beto',
      brand: PaymentBrand.mastercard,
      last4: '4444',
      expiryMonth: 9,
      expiryYear: 2031,
    );

    await expectLater(
      repository.delete(otra.id),
      throwsA(isA<PaymentMethodNotFoundException>()),
    );
    await expectLater(
      repository.setDefault(otra.id),
      throwsA(isA<PaymentMethodNotFoundException>()),
    );

    expect((await repository.list()).single.id, visa.id);
    expect((await repository2.list()).single.id, otra.id);
  });

  test('mismo last4 entre usuarios está permitido', () async {
    final repository2 = SqflitePaymentMethodRepository(
      database: appDatabase,
      userId: 2,
      now: now,
    );
    await createVisa();
    await repository2.create(
      holderName: 'Beto',
      brand: PaymentBrand.visa,
      last4: '4242',
      expiryMonth: 8,
      expiryYear: 2030,
    );

    expect((await repository.list()).single.last4, '4242');
    expect((await repository2.list()).single.last4, '4242');
  });

  test('valida holder, last4, mes y vencimiento', () async {
    await expectLater(
      repository.create(
        holderName: ' ',
        brand: PaymentBrand.visa,
        last4: '4242',
        expiryMonth: 8,
        expiryYear: 2030,
      ),
      throwsA(isA<InvalidPaymentMethodException>()),
    );
    await expectLater(
      repository.create(
        holderName: 'Ana',
        brand: PaymentBrand.visa,
        last4: '42A2',
        expiryMonth: 8,
        expiryYear: 2030,
      ),
      throwsA(isA<InvalidPaymentMethodException>()),
    );
    await expectLater(
      repository.create(
        holderName: 'Ana',
        brand: PaymentBrand.visa,
        last4: '4242',
        expiryMonth: 13,
        expiryYear: 2030,
      ),
      throwsA(isA<InvalidPaymentMethodException>()),
    );
    await expectLater(
      repository.create(
        holderName: 'Ana',
        brand: PaymentBrand.visa,
        last4: '4242',
        expiryMonth: 10,
        expiryYear: 2026,
      ),
      throwsA(isA<InvalidPaymentMethodException>()),
    );
  });

  test('un id inexistente lanza dominio', () async {
    await expectLater(
      repository.delete('pay-missing'),
      throwsA(isA<PaymentMethodNotFoundException>()),
    );
    await expectLater(
      repository.setDefault('pay-missing'),
      throwsA(isA<PaymentMethodNotFoundException>()),
    );
  });

  test('guarda solo campos permitidos y no PAN/CVV', () async {
    final method = await createVisa();
    final db = await appDatabase.database;
    final row = (await db.query(
      AppDatabase.paymentMethodsTable,
      where: 'id = ?',
      whereArgs: [method.id],
    )).single;

    expect(row.keys.toSet(), {
      'id',
      'user_id',
      'holder_name',
      'brand',
      'last4',
      'expiry_month',
      'expiry_year',
      'is_default',
    });
    expect(row.values.join(' ').toLowerCase(), isNot(contains('cvv')));
    expect(row['last4'], '4242');
  });

  test('ON DELETE CASCADE elimina métodos del usuario', () async {
    await createVisa();
    final db = await appDatabase.database;

    await db.delete(AppDatabase.usersTable, where: 'id = ?', whereArgs: [1]);

    expect(await repository.list(), isEmpty);
  });
}
