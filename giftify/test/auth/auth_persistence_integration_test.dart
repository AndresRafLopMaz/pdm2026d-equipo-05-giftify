import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/features/auth/data/password_hasher.dart';
import 'package:giftify/features/auth/data/session_store.dart';
import 'package:giftify/features/auth/data/sqlite_user_repository.dart';
import 'package:giftify/features/auth/providers/auth_controller.dart';
import 'package:giftify/features/auth/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;
  late AppDatabase appDatabase;
  late SqliteUserRepository repository;
  late Pbkdf2PasswordHasher hasher;
  late SharedPreferencesSessionStore sessionStore;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    repository = SqliteUserRepository(database: appDatabase);
    hasher = Pbkdf2PasswordHasher(iterations: 1000);
    sessionStore = SharedPreferencesSessionStore();
  });

  tearDown(() async {
    await appDatabase.close();
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(repository),
        sessionStoreProvider.overrideWithValue(sessionStore),
        passwordHasherProvider.overrideWithValue(hasher),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'registro persiste en SQLite y la sesión se restaura tras reinicio',
    () async {
      final first = createContainer();
      await first.read(authControllerProvider.future);

      await first
          .read(authControllerProvider.notifier)
          .register(
            name: 'Ana López',
            email: '  Ana@Mail.com ',
            password: 'contrasena-123',
          );

      final userId = await sessionStore.readUserId();
      expect(userId, isNotNull);

      final db = await appDatabase.database;
      final row = (await db.query(
        AppDatabase.usersTable,
        where: 'id = ?',
        whereArgs: [userId],
      )).single;
      expect(row['email'], 'ana@mail.com');
      expect(row['password_hash'], isNot(contains('contrasena-123')));
      expect(row['password_salt'], isNotEmpty);

      final restarted = createContainer();
      final restored = await restarted.read(authControllerProvider.future);

      expect(restored?.id, userId);
      expect(restored?.email, 'ana@mail.com');

      await restarted.read(authControllerProvider.notifier).logout();
      expect(await sessionStore.readUserId(), isNull);
      expect(restarted.read(authControllerProvider).value, isNull);

      await restarted
          .read(authControllerProvider.notifier)
          .login(email: 'ANA@MAIL.COM', password: 'contrasena-123');
      expect(await sessionStore.readUserId(), userId);
      expect(restarted.read(authControllerProvider).value?.id, userId);
    },
  );

  test('una sesión huérfana se elimina al restaurar', () async {
    await sessionStore.saveUserId(9999);
    final container = createContainer();

    final restored = await container.read(authControllerProvider.future);

    expect(restored, isNull);
    expect(await sessionStore.readUserId(), isNull);
  });
}
