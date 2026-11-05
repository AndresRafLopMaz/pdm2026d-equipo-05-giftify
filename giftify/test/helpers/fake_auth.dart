import 'package:giftify/features/auth/data/email_normalizer.dart';
import 'package:giftify/features/auth/data/session_store.dart';
import 'package:giftify/features/auth/data/user_repository.dart';
import 'package:giftify/features/auth/models/auth_exceptions.dart';
import 'package:giftify/features/auth/models/user.dart';
import 'package:giftify/features/auth/models/user_credentials.dart';

class InMemoryUserRepository implements UserRepository {
  final Map<int, UserCredentials> _users = {};
  int _nextId = 1;
  bool failReads = false;
  bool failWrites = false;

  int get length => _users.length;

  User seedUser({
    required String name,
    required String email,
    String passwordHash = 'hash',
    String passwordSalt = 'salt',
  }) {
    final user = User(id: _nextId++, name: name, email: normalizeEmail(email));
    _users[user.id] = UserCredentials(
      user: user,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
    );
    return user;
  }

  @override
  Future<User> createUser({
    required String name,
    required String email,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    if (failWrites) {
      throw const AuthStorageException();
    }

    final normalized = normalizeEmail(email);
    if (_users.values.any((entry) => entry.user.email == normalized)) {
      throw const EmailAlreadyRegisteredException();
    }

    final user = User(id: _nextId++, name: name, email: normalized);
    _users[user.id] = UserCredentials(
      user: user,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
    );
    return user;
  }

  @override
  Future<User?> findById(int id) async {
    if (failReads) {
      throw const AuthStorageException();
    }
    return _users[id]?.user;
  }

  @override
  Future<User?> findByEmail(String email) async {
    if (failReads) {
      throw const AuthStorageException();
    }
    final normalized = normalizeEmail(email);
    for (final entry in _users.values) {
      if (entry.user.email == normalized) {
        return entry.user;
      }
    }
    return null;
  }

  @override
  Future<UserCredentials?> findCredentialsByEmail(String email) async {
    if (failReads) {
      throw const AuthStorageException();
    }
    final normalized = normalizeEmail(email);
    for (final entry in _users.values) {
      if (entry.user.email == normalized) {
        return entry;
      }
    }
    return null;
  }
}

class InMemorySessionStore implements SessionStore {
  int? userId;
  bool failRead = false;
  bool failWrite = false;
  bool failClear = false;

  @override
  Future<int?> readUserId() async {
    if (failRead) {
      throw const AuthStorageException();
    }
    return userId;
  }

  @override
  Future<void> saveUserId(int id) async {
    if (failWrite) {
      throw const AuthStorageException();
    }
    userId = id;
  }

  @override
  Future<void> clear() async {
    if (failClear) {
      throw const AuthStorageException();
    }
    userId = null;
  }
}
