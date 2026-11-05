import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/features/auth/data/password_hasher.dart';
import 'package:giftify/features/auth/data/sqlite_user_repository.dart';
import 'package:giftify/features/auth/models/auth_exceptions.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;
  late AppDatabase appDatabase;
  late SqliteUserRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    repository = SqliteUserRepository(database: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  Future<(String, String)> credentials() async {
    final result = await Pbkdf2PasswordHasher(
      iterations: 1000,
      random: Random(9),
    ).hash('contrasena-123');
    return (result.hash, result.salt);
  }

  test('crea un usuario y lo recupera por id y email', () async {
    final (hash, salt) = await credentials();

    final created = await repository.createUser(
      name: '  Ana López  ',
      email: '  Ana@Mail.com ',
      passwordHash: hash,
      passwordSalt: salt,
    );

    expect(created.id, greaterThan(0));
    expect(created.name, 'Ana López');
    expect(created.email, 'ana@mail.com');

    final byId = await repository.findById(created.id);
    final byEmail = await repository.findByEmail('ANA@MAIL.COM');

    expect(byId?.id, created.id);
    expect(byEmail?.id, created.id);
    expect(byEmail?.name, 'Ana López');
  });

  test('recupera credenciales sin exponerlas en User', () async {
    final (hash, salt) = await credentials();
    final created = await repository.createUser(
      name: 'Ana',
      email: 'ana@mail.com',
      passwordHash: hash,
      passwordSalt: salt,
    );

    final stored = await repository.findCredentialsByEmail('ana@mail.com');

    expect(stored?.user.id, created.id);
    expect(stored?.passwordHash, hash);
    expect(stored?.passwordSalt, salt);
  });

  test('rechaza email duplicado con distinta capitalización', () async {
    final (hash, salt) = await credentials();
    await repository.createUser(
      name: 'Ana',
      email: 'ana@mail.com',
      passwordHash: hash,
      passwordSalt: salt,
    );

    await expectLater(
      repository.createUser(
        name: 'Otra',
        email: 'ANA@mail.com',
        passwordHash: hash,
        passwordSalt: salt,
      ),
      throwsA(isA<EmailAlreadyRegisteredException>()),
    );
  });

  test('persiste usuarios tras cerrar y reabrir la base', () async {
    final (hash, salt) = await credentials();
    final created = await repository.createUser(
      name: 'Ana',
      email: 'ana@mail.com',
      passwordHash: hash,
      passwordSalt: salt,
    );
    await appDatabase.close();

    final reopened = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(reopened.close);
    final reopenedRepository = SqliteUserRepository(database: reopened);

    final found = await reopenedRepository.findById(created.id);
    expect(found?.email, 'ana@mail.com');
  });

  test('devuelve null para usuario inexistente', () async {
    expect(await repository.findById(999), isNull);
    expect(await repository.findByEmail('nadie@mail.com'), isNull);
    expect(await repository.findCredentialsByEmail('nadie@mail.com'), isNull);
  });

  test('guarda hash y salt, nunca la contraseña plana', () async {
    final (hash, salt) = await credentials();
    final created = await repository.createUser(
      name: 'Ana',
      email: 'ana@mail.com',
      passwordHash: hash,
      passwordSalt: salt,
    );

    final db = await appDatabase.database;
    final row = (await db.query(
      AppDatabase.usersTable,
      where: 'id = ?',
      whereArgs: [created.id],
    )).single;

    expect(row['password_hash'], hash);
    expect(row['password_salt'], salt);
    expect(row['created_at'], isA<int>());
    expect(row.toString(), isNot(contains('contrasena-123')));
  });
}
