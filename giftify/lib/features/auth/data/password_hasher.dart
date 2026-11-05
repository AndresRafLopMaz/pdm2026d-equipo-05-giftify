import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../models/password_hash_result.dart';

abstract class PasswordHasher {
  Future<PasswordHashResult> hash(String password);

  Future<bool> verify({
    required String password,
    required String storedHash,
    required String storedSalt,
  });
}

class Pbkdf2PasswordHasher implements PasswordHasher {
  Pbkdf2PasswordHasher({this.iterations = defaultIterations, Random? random})
    : assert(iterations > 0),
      _random = random ?? Random.secure();

  static const int defaultIterations = 600000;
  static const int saltLength = 16;
  static const int hashLength = 32;
  static const int bits = hashLength * 8;

  final int iterations;
  final Random _random;

  @override
  Future<PasswordHashResult> hash(String password) async {
    final salt = _randomSalt();
    final hash = await _derive(password, salt);

    return PasswordHashResult(
      hash: base64Encode(hash),
      salt: base64Encode(salt),
    );
  }

  @override
  Future<bool> verify({
    required String password,
    required String storedHash,
    required String storedSalt,
  }) async {
    try {
      final expected = base64Decode(storedHash);
      final salt = base64Decode(storedSalt);
      if (expected.length != hashLength || salt.length != saltLength) {
        return false;
      }

      final actual = await _derive(password, salt);
      return _constantTimeEquals(actual, expected);
    } catch (_) {
      return false;
    }
  }

  Future<List<int>> _derive(String password, List<int> salt) async {
    final algorithm = Pbkdf2.hmacSha256(iterations: iterations, bits: bits);
    final key = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return key.extractBytes();
  }

  Uint8List _randomSalt() {
    final salt = Uint8List(saltLength);
    for (var index = 0; index < salt.length; index++) {
      salt[index] = _random.nextInt(256);
    }
    return salt;
  }

  bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }

    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}
