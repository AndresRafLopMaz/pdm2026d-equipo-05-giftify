import 'dart:math';

import 'package:flutter_riverpod/misc.dart';
import 'package:giftify/features/auth/data/password_hasher.dart';
import 'package:giftify/features/auth/models/user.dart';
import 'package:giftify/features/auth/providers/auth_providers.dart';

import 'fake_auth.dart';

class AuthTestHarness {
  AuthTestHarness()
    : hasher = Pbkdf2PasswordHasher(iterations: 1000, random: Random(11));

  final InMemoryUserRepository repository = InMemoryUserRepository();
  final InMemorySessionStore session = InMemorySessionStore();
  final Pbkdf2PasswordHasher hasher;

  List<Override> get overrides => [
    userRepositoryProvider.overrideWithValue(repository),
    sessionStoreProvider.overrideWithValue(session),
    passwordHasherProvider.overrideWithValue(hasher),
  ];

  Future<User> seedUserWithPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final hash = await hasher.hash(password);
    return repository.seedUser(
      name: name,
      email: email,
      passwordHash: hash.hash,
      passwordSalt: hash.salt,
    );
  }
}
