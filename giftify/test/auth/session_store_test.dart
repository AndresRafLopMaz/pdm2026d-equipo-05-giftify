import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/auth/data/session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('sin clave devuelve null', () async {
    final store = SharedPreferencesSessionStore();

    expect(await store.readUserId(), isNull);
  });

  test('guarda y recupera el id', () async {
    final store = SharedPreferencesSessionStore();

    await store.saveUserId(42);

    expect(await store.readUserId(), 42);
  });

  test('clear elimina la clave', () async {
    final store = SharedPreferencesSessionStore();
    await store.saveUserId(42);

    await store.clear();

    expect(await store.readUserId(), isNull);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.containsKey(SharedPreferencesSessionStore.storageKey),
      isFalse,
    );
  });

  test('el id persiste entre instancias y lecturas', () async {
    await SharedPreferencesSessionStore().saveUserId(7);

    final restarted = SharedPreferencesSessionStore();

    expect(await restarted.readUserId(), 7);
  });
}
