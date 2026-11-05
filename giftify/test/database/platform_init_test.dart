import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/core/database/database_platform.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la inicialización Web no altera el factory nativo ni el schema', () {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    configureDatabasePlatform();

    expect(databaseFactory, same(databaseFactoryFfi));
    expect(AppDatabase.version, 5);
  });
}
