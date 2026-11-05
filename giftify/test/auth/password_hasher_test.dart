import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/auth/data/password_hasher.dart';

void main() {
  Pbkdf2PasswordHasher hasher({int seed = 7}) {
    return Pbkdf2PasswordHasher(iterations: 1000, random: Random(seed));
  }

  test('el hash no contiene la contraseña y usa salt de 16 bytes', () async {
    final result = await hasher().hash('contrasena-segura');

    expect(result.hash, isNot(contains('contrasena-segura')));
    expect(base64Decode(result.hash), hasLength(32));
    expect(base64Decode(result.salt), hasLength(16));
  });

  test('salts distintos producen hashes distintos', () async {
    final first = await hasher(seed: 1).hash('misma-password');
    final second = await hasher(seed: 2).hash('misma-password');

    expect(first.salt, isNot(second.salt));
    expect(first.hash, isNot(second.hash));
  });

  test('misma password y mismo salt producen salida determinista', () async {
    final first = await hasher(seed: 42).hash('misma-password');
    final second = await hasher(seed: 42).hash('misma-password');

    expect(first.hash, second.hash);
    expect(first.salt, second.salt);
  });

  test('verify acepta la contraseña correcta', () async {
    final passwordHasher = hasher();
    final result = await passwordHasher.hash('correcta-123');

    expect(
      await passwordHasher.verify(
        password: 'correcta-123',
        storedHash: result.hash,
        storedSalt: result.salt,
      ),
      isTrue,
    );
  });

  test('verify rechaza una contraseña incorrecta', () async {
    final passwordHasher = hasher();
    final result = await passwordHasher.hash('correcta-123');

    expect(
      await passwordHasher.verify(
        password: 'incorrecta-123',
        storedHash: result.hash,
        storedSalt: result.salt,
      ),
      isFalse,
    );
  });

  test('verify devuelve false con hash o salt corruptos', () async {
    final passwordHasher = hasher();
    final result = await passwordHasher.hash('correcta-123');

    expect(
      await passwordHasher.verify(
        password: 'correcta-123',
        storedHash: 'no-es-base64',
        storedSalt: result.salt,
      ),
      isFalse,
    );
    expect(
      await passwordHasher.verify(
        password: 'correcta-123',
        storedHash: result.hash,
        storedSalt: base64Encode(List<int>.filled(4, 1)),
      ),
      isFalse,
    );
  });

  test('verify devuelve false con hash de longitud incorrecta', () async {
    final passwordHasher = hasher();

    expect(
      await passwordHasher.verify(
        password: 'correcta-123',
        storedHash: base64Encode(List<int>.filled(16, 1)),
        storedSalt: base64Encode(List<int>.filled(16, 2)),
      ),
      isFalse,
    );
  });
}
