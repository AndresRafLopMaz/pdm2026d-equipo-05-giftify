import 'user.dart';

class UserCredentials {
  const UserCredentials({
    required this.user,
    required this.passwordHash,
    required this.passwordSalt,
  });

  final User user;
  final String passwordHash;
  final String passwordSalt;
}
