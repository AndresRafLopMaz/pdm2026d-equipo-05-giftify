import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, this.path})
    : _factory = factory ?? databaseFactory;

  static final AppDatabase instance = AppDatabase();

  static const int version = 2;
  static const String fileName = 'giftify.db';
  static const String deliveryAddressesTable = 'delivery_addresses';

  static const String labelNocaseIndex = 'idx_delivery_addresses_label_nocase';
  static const String singleDefaultIndex =
      'idx_delivery_addresses_single_default';
  static const String archivedIndex = 'idx_delivery_addresses_archived';

  final DatabaseFactory _factory;
  final String? path;

  Database? _database;
  Future<Database>? _opening;

  Future<Database> get database {
    final current = _database;
    if (current != null) {
      return Future<Database>.value(current);
    }

    return _opening ??= _open();
  }

  Future<void> close() async {
    final pending = _opening;
    final current = _database;
    _opening = null;
    _database = null;

    if (current != null) {
      await current.close();
      return;
    }

    if (pending != null) {
      try {
        final db = await pending;
        _database = null;
        await db.close();
      } catch (_) {
        return;
      }
    }
  }

  Future<Database> _open() async {
    try {
      final databasePath =
          path ?? p.join(await _factory.getDatabasesPath(), fileName);
      final db = await _factory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: version,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
      _database = db;
      return db;
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $deliveryAddressesTable (
        id TEXT PRIMARY KEY,
        label TEXT NOT NULL UNIQUE,
        recipient_name TEXT NOT NULL,
        address_line TEXT NOT NULL,
        city TEXT NOT NULL,
        department TEXT NOT NULL,
        reference TEXT,
        archived INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _createV2Indexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $deliveryAddressesTable
        ADD COLUMN archived INTEGER NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE $deliveryAddressesTable
        ADD COLUMN is_default INTEGER NOT NULL DEFAULT 0
      ''');

      await _createV2Indexes(db);
    }
  }

  Future<void> _createV2Indexes(Database db) async {
    await db.execute('''
      CREATE UNIQUE INDEX $labelNocaseIndex
      ON $deliveryAddressesTable(label COLLATE NOCASE)
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX $singleDefaultIndex
      ON $deliveryAddressesTable(is_default)
      WHERE is_default = 1
    ''');
    await db.execute('''
      CREATE INDEX $archivedIndex
      ON $deliveryAddressesTable(archived)
    ''');
  }
}
