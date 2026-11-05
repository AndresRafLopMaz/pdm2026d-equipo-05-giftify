import '../models/user.dart';
import '../models/user_credentials.dart';

abstract class UserRepository {
  Future<User> createUser({
    required String name,
    required String email,
    required String passwordHash,
    required String passwordSalt,
  });

  Future<User?> findById(int id);

  Future<User?> findByEmail(String email);

  Future<UserCredentials?> findCredentialsByEmail(String email);
}
