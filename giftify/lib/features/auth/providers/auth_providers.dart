import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';
import '../data/password_hasher.dart';
import '../data/session_store.dart';
import '../data/sqlite_user_repository.dart';
import '../data/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return SqliteUserRepository();
});

final passwordHasherProvider = Provider<PasswordHasher>((ref) {
  return Pbkdf2PasswordHasher();
});

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SharedPreferencesSessionStore();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(userRepositoryProvider),
    ref.watch(passwordHasherProvider),
  );
});
