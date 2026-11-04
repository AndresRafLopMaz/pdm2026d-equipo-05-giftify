import 'dart:io';

import 'package:giftify/core/database/app_database.dart';
import 'package:path/path.dart' as p;

Future<Directory> createDatabaseTestDirectory() {
  return Directory.systemTemp.createTemp('giftify_database_test_');
}

String databasePathIn(Directory directory) {
  return p.join(directory.path, AppDatabase.fileName);
}

Future<void> deleteDatabaseTestDirectory(Directory directory) async {
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}
