import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/auth/data/password_hasher.dart';
import 'package:giftify/features/auth/models/auth_exceptions.dart';
import 'package:giftify/features/auth/providers/auth_controller.dart';
import 'package:giftify/features/auth/providers/auth_providers.dart';

import '../helpers/fake_auth.dart';

void main() {
  late InMemoryUserRepository repository;
  late InMemorySessionStore session;
  late Pbkdf2PasswordHasher hasher;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(repository),
        sessionStoreProvider.overrideWithValue(session),
        passwordHasherProvider.overrideWithValue(hasher),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    repository = InMemoryUserRepository();
    session = InMemorySessionStore();
    hasher = Pbkdf2PasswordHasher(iterations: 1000, random: Random(5));
  });

  test('sin sesión restaura null', () async {
    final container = createContainer();

    expect(await container.read(authControllerProvider.future), isNull);
  });

  test('restaura una sesión válida', () async {
    final user = repository.seedUser(name: 'Ana', email: 'ana@mail.com');
    session.userId = user.id;
    final container = createContainer();

    final restored = await container.read(authControllerProvider.future);

    expect(restored?.id, user.id);
    expect(session.userId, user.id);
  });

  test('limpia una sesión huérfana', () async {
    session.userId = 999;
    final container = createContainer();

    expect(await container.read(authControllerProvider.future), isNull);
    expect(session.userId, isNull);
  });

  test('propaga error de restauración sin borrar la sesión', () async {
    session.userId = 1;
    repository.failReads = true;
    final container = createContainer();

    await expectLater(
      container.read(authControllerProvider.future),
      throwsA(isA<AuthStorageException>()),
    );
    expect(session.userId, 1);
  });

  test('registro exitoso guarda sesión y publica usuario', () async {
    final container = createContainer();
    await container.read(authControllerProvider.future);

    await container
        .read(authControllerProvider.notifier)
        .register(
          name: 'Ana',
          email: 'ana@mail.com',
          password: 'contrasena-123',
        );

    final state = container.read(authControllerProvider);
    expect(state.value?.email, 'ana@mail.com');
    expect(session.userId, state.value?.id);
  });

  test('registro duplicado no cambia la sesión', () async {
    repository.seedUser(name: 'Ana', email: 'ana@mail.com');
    final container = createContainer();
    await container.read(authControllerProvider.future);

    await expectLater(
      container
          .read(authControllerProvider.notifier)
          .register(
            name: 'Otra',
            email: 'ANA@MAIL.COM',
            password: 'contrasena-123',
          ),
      throwsA(isA<EmailAlreadyRegisteredException>()),
    );
    expect(container.read(authControllerProvider).value, isNull);
    expect(session.userId, isNull);
  });

  test('login exitoso guarda sesión', () async {
    final hash = await hasher.hash('contrasena-123');
    final user = repository.seedUser(
      name: 'Ana',
      email: 'ana@mail.com',
      passwordHash: hash.hash,
      passwordSalt: hash.salt,
    );
    final container = createContainer();
    await container.read(authControllerProvider.future);

    await container
        .read(authControllerProvider.notifier)
        .login(email: 'ana@mail.com', password: 'contrasena-123');

    expect(container.read(authControllerProvider).value?.id, user.id);
    expect(session.userId, user.id);
  });

  test('login con credenciales incorrectas no crea sesión', () async {
    repository.seedUser(name: 'Ana', email: 'ana@mail.com');
    final container = createContainer();
    await container.read(authControllerProvider.future);

    await expectLater(
      container
          .read(authControllerProvider.notifier)
          .login(email: 'ana@mail.com', password: 'incorrecta'),
      throwsA(isA<InvalidCredentialsException>()),
    );
    expect(session.userId, isNull);
  });

  test('logout limpia la sesión', () async {
    final user = repository.seedUser(name: 'Ana', email: 'ana@mail.com');
    session.userId = user.id;
    final container = createContainer();
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(authControllerProvider).value, isNull);
    expect(session.userId, isNull);
  });
}
