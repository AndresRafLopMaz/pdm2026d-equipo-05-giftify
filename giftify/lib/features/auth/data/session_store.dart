import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_exceptions.dart';

abstract class SessionStore {
  Future<int?> readUserId();

  Future<void> saveUserId(int id);

  Future<void> clear();
}

class SharedPreferencesSessionStore implements SessionStore {
  static const String storageKey = 'giftify.session_user_id';

  @override
  Future<int?> readUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(storageKey);
  }

  @override
  Future<void> saveUserId(int id) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setInt(storageKey, id);
    if (!saved) {
      throw const AuthStorageException();
    }
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey(storageKey)) {
      return;
    }

    final removed = await preferences.remove(storageKey);
    if (!removed) {
      throw const AuthStorageException();
    }
  }
}
