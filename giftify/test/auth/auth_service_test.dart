import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/auth/data/auth_service.dart';
import 'package:giftify/features/auth/data/password_hasher.dart';
import 'package:giftify/features/auth/models/auth_exceptions.dart';

import '../helpers/fake_auth.dart';

void main() {
  late InMemoryUserRepository repository;
  late AuthService service;
  late Pbkdf2PasswordHasher hasher;

  setUp(() {
    repository = InMemoryUserRepository();
    hasher = Pbkdf2PasswordHasher(iterations: 1000, random: Random(3));
    service = AuthService(repository, hasher);
  });

  test('registra un usuario y normaliza el email', () async {
    final user = await service.register(
      name: '  Ana López ',
      email: '  Ana@Mail.com ',
      password: 'contrasena-123',
    );

    expect(user.name, 'Ana López');
    expect(user.email, 'ana@mail.com');
    expect(repository.length, 1);
    expect(await repository.findByEmail('ANA@MAIL.COM'), isNotNull);
  });

  test('rechaza email duplicado sin distinguir mayúsculas', () async {
    await service.register(
      name: 'Ana',
      email: 'ana@mail.com',
      password: 'contrasena-123',
    );

    await expectLater(
      service.register(
        name: 'Otra',
        email: 'ANA@MAIL.COM',
        password: 'otra-clave-123',
      ),
      throwsA(isA<EmailAlreadyRegisteredException>()),
    );
  });

  test('valida nombre, email, longitud mínima y máxima', () async {
    await expectLater(
      service.register(name: ' ', email: 'ana@mail.com', password: '12345678'),
      throwsA(isA<AuthValidationException>()),
    );
    await expectLater(
      service.register(name: 'Ana', email: 'ana@', password: '12345678'),
      throwsA(isA<AuthValidationException>()),
    );
    await expectLater(
      service.register(name: 'Ana', email: 'ana@mail.com', password: '1234567'),
      throwsA(isA<AuthValidationException>()),
    );
    await expectLater(
      service.register(name: 'Ana', email: 'ana@mail.com', password: 'a' * 129),
      throwsA(isA<AuthValidationException>()),
    );
  });

  test('login acepta credenciales correctas', () async {
    final registered = await service.register(
      name: 'Ana',
      email: 'ana@mail.com',
      password: 'contrasena-123',
    );

    final user = await service.login(
      email: ' ANA@MAIL.COM ',
      password: 'contrasena-123',
    );

    expect(user.id, registered.id);
    expect(user.email, 'ana@mail.com');
  });

  test('login rechaza password incorrecta y email inexistente igual', () async {
    await service.register(
      name: 'Ana',
      email: 'ana@mail.com',
      password: 'contrasena-123',
    );

    await expectLater(
      service.login(email: 'ana@mail.com', password: 'incorrecta'),
      throwsA(isA<InvalidCredentialsException>()),
    );
    await expectLater(
      service.login(email: 'nadie@mail.com', password: 'contrasena-123'),
      throwsA(isA<InvalidCredentialsException>()),
    );
  });

  test('no persiste la contraseña en texto plano', () async {
    await service.register(
      name: 'Ana',
      email: 'ana@mail.com',
      password: 'contrasena-unica',
    );

    final credentials = await repository.findCredentialsByEmail('ana@mail.com');
    expect(credentials?.passwordHash, isNot(contains('contrasena-unica')));
    expect(credentials?.passwordSalt, isNotEmpty);
  });

  test('traduce error de almacenamiento', () async {
    repository.failWrites = true;

    await expectLater(
      service.register(
        name: 'Ana',
        email: 'ana@mail.com',
        password: 'contrasena-123',
      ),
      throwsA(isA<AuthStorageException>()),
    );
  });
}
