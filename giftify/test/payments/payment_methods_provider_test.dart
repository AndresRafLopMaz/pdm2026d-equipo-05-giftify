import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/core/database/database_providers.dart';
import 'package:giftify/features/auth/providers/current_user_provider.dart';
import 'package:giftify/features/payments/data/sqflite_payment_method_repository.dart';
import 'package:giftify/features/payments/providers/payment_methods_provider.dart';
import 'package:giftify/shared/enums/payment_brand.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helper.dart';
import '../helpers/ownership_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;
  late AppDatabase appDatabase;
  final now = DateTime(2026, 11, 5);

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);

    final db = await appDatabase.database;
    for (final user in [(1, 'ana@mail.com'), (2, 'beto@mail.com')]) {
      await db.insert(AppDatabase.usersTable, {
        'id': user.$1,
        'name': 'User ${user.$1}',
        'email': user.$2,
        'password_hash': 'hash',
        'password_salt': 'salt',
        'created_at': user.$1,
      });
    }

    await SqflitePaymentMethodRepository(
      database: appDatabase,
      userId: 1,
      now: now,
    ).create(
      holderName: 'Ana',
      brand: PaymentBrand.visa,
      last4: '4242',
      expiryMonth: 8,
      expiryYear: 2030,
    );
    await SqflitePaymentMethodRepository(
      database: appDatabase,
      userId: 2,
      now: now,
    ).create(
      holderName: 'Beto',
      brand: PaymentBrand.mastercard,
      last4: '4444',
      expiryMonth: 9,
      expiryYear: 2031,
    );
  });

  tearDown(() async {
    await appDatabase.close();
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  test('paymentMethodsProvider no conserva datos entre usuarios', () async {
    int? currentUserId = 1;
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith((ref) => currentUserId),
        appDatabaseProvider.overrideWithValue(appDatabase),
        ownershipNotNeededOverride,
      ],
    );
    addTearDown(container.dispose);
    container.listen(paymentMethodsProvider, (_, _) {});

    final userA = await container.read(paymentMethodsProvider.future);
    expect(userA.single.last4, '4242');

    currentUserId = 2;
    container.invalidate(currentUserIdProvider);
    final userB = await container.read(paymentMethodsProvider.future);
    expect(userB.single.last4, '4444');
    expect(userB.any((method) => method.last4 == '4242'), isFalse);

    currentUserId = 1;
    container.invalidate(currentUserIdProvider);
    final userAAgain = await container.read(paymentMethodsProvider.future);
    expect(userAAgain.single.last4, '4242');
  });
}
