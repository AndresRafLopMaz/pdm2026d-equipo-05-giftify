import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/auth_exceptions.dart';
import '../models/user.dart';
import '../models/user_credentials.dart';
import 'email_normalizer.dart';
import 'user_repository.dart';

class SqliteUserRepository implements UserRepository {
  SqliteUserRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  @override
  Future<User> createUser({
    required String name,
    required String email,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    try {
      final db = await _db;
      final id = await db.insert(AppDatabase.usersTable, {
        'name': name.trim(),
        'email': normalizeEmail(email),
        'password_hash': passwordHash,
        'password_salt': passwordSalt,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      return User(id: id, name: name.trim(), email: normalizeEmail(email));
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const EmailAlreadyRegisteredException();
      }
      throw const AuthStorageException();
    } catch (_) {
      throw const AuthStorageException();
    }
  }

  @override
  Future<User?> findById(int id) async {
    try {
      final db = await _db;
      final rows = await db.query(
        AppDatabase.usersTable,
        columns: const ['id', 'name', 'email'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return _userFromRow(rows.single);
    } on DatabaseException {
      throw const AuthStorageException();
    }
  }

  @override
  Future<User?> findByEmail(String email) async {
    try {
      final db = await _db;
      final rows = await db.query(
        AppDatabase.usersTable,
        columns: const ['id', 'name', 'email'],
        where: 'email = ? COLLATE NOCASE',
        whereArgs: [normalizeEmail(email)],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return _userFromRow(rows.single);
    } on DatabaseException {
      throw const AuthStorageException();
    }
  }

  @override
  Future<UserCredentials?> findCredentialsByEmail(String email) async {
    try {
      final db = await _db;
      final rows = await db.query(
        AppDatabase.usersTable,
        where: 'email = ? COLLATE NOCASE',
        whereArgs: [normalizeEmail(email)],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }

      final row = rows.single;
      return UserCredentials(
        user: _userFromRow(row),
        passwordHash: row['password_hash']! as String,
        passwordSalt: row['password_salt']! as String,
      );
    } on DatabaseException {
      throw const AuthStorageException();
    }
  }

  User _userFromRow(Map<String, Object?> row) {
    return User(
      id: row['id']! as int,
      name: row['name']! as String,
      email: row['email']! as String,
    );
  }
}
