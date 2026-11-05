import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'auth_providers.dart';

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final sessionStore = ref.read(sessionStoreProvider);
    final userId = await sessionStore.readUserId();
    if (userId == null) {
      return null;
    }

    final user = await ref.read(userRepositoryProvider).findById(userId);
    if (user == null) {
      await sessionStore.clear();
      return null;
    }

    return user;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await ref
        .read(authServiceProvider)
        .register(name: name, email: email, password: password);

    await ref.read(sessionStoreProvider).saveUserId(user.id);
    state = AsyncData(user);
  }

  Future<void> login({required String email, required String password}) async {
    final user = await ref
        .read(authServiceProvider)
        .login(email: email, password: password);

    await ref.read(sessionStoreProvider).saveUserId(user.id);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(sessionStoreProvider).clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
  retry: (retryCount, error) => null,
);
