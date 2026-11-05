import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, this.path})
    : _factory = factory ?? databaseFactory;

  static final AppDatabase instance = AppDatabase();

  static const int version = 5;
  static const String fileName = 'giftify.db';
  static const String deliveryAddressesTable = 'delivery_addresses';
  static const String usersTable = 'users';
  static const String paymentMethodsTable = 'payment_methods';

  static const String userLabelIndex =
      'idx_delivery_addresses_user_label_nocase';
  static const String userDefaultIndex =
      'idx_delivery_addresses_user_single_default';
  static const String userArchivedIndex =
      'idx_delivery_addresses_user_archived';
  static const String usersEmailIndex = 'idx_users_email_nocase';
  static const String paymentMethodsUserIndex = 'idx_payment_methods_user';
  static const String paymentMethodsDefaultIndex =
      'idx_payment_methods_user_default';

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
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
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
    await _createUsersTable(db);
    await _createFinalAddressesTable(db, deliveryAddressesTable);
    await _createAddressIndexes(db);
    await _createPaymentMethodsTable(db);
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

    if (oldVersion < 3) {
      await _createUsersTable(db);
    }

    if (oldVersion < 4) {
      await _rebuildAddressesV4(db);
    }

    if (oldVersion < 5) {
      await _createPaymentMethodsTable(db);
    }
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX $usersEmailIndex
      ON $usersTable(email COLLATE NOCASE)
    ''');
  }

  Future<void> _createFinalAddressesTable(Database db, String tableName) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        user_id INTEGER
          REFERENCES $usersTable(id) ON DELETE CASCADE,
        label TEXT NOT NULL,
        recipient_name TEXT NOT NULL,
        address_line TEXT NOT NULL,
        city TEXT NOT NULL,
        department TEXT NOT NULL,
        reference TEXT,
        archived INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _rebuildAddressesV4(Database db) async {
    const temporaryTable = '${deliveryAddressesTable}_v4';

    await db.execute('DROP TABLE IF EXISTS $temporaryTable');
    await _createFinalAddressesTable(db, temporaryTable);
    await db.execute('''
      INSERT INTO $temporaryTable (
        id,
        user_id,
        label,
        recipient_name,
        address_line,
        city,
        department,
        reference,
        archived,
        is_default
      )
      SELECT
        id,
        NULL,
        label,
        recipient_name,
        address_line,
        city,
        department,
        reference,
        archived,
        is_default
      FROM $deliveryAddressesTable
    ''');
    await db.execute('DROP TABLE $deliveryAddressesTable');
    await db.execute(
      'ALTER TABLE $temporaryTable RENAME TO $deliveryAddressesTable',
    );
    await _createAddressIndexes(db);
  }

  Future<void> _createPaymentMethodsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $paymentMethodsTable (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL
          REFERENCES $usersTable(id) ON DELETE CASCADE,
        holder_name TEXT NOT NULL,
        brand TEXT NOT NULL
          CHECK (brand IN ('visa', 'mastercard', 'amex', 'other')),
        last4 TEXT NOT NULL
          CHECK (last4 GLOB '[0-9][0-9][0-9][0-9]'),
        expiry_month INTEGER NOT NULL
          CHECK (expiry_month BETWEEN 1 AND 12),
        expiry_year INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
          CHECK (is_default IN (0, 1))
      )
    ''');

    await db.execute('''
      CREATE INDEX $paymentMethodsUserIndex
      ON $paymentMethodsTable(user_id)
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX $paymentMethodsDefaultIndex
      ON $paymentMethodsTable(user_id)
      WHERE is_default = 1
    ''');
  }

  Future<void> _createV2Indexes(Database db) async {
    await db.execute('''
      CREATE UNIQUE INDEX idx_delivery_addresses_label_nocase
      ON $deliveryAddressesTable(label COLLATE NOCASE)
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX idx_delivery_addresses_single_default
      ON $deliveryAddressesTable(is_default)
      WHERE is_default = 1
    ''');
    await db.execute('''
      CREATE INDEX idx_delivery_addresses_archived
      ON $deliveryAddressesTable(archived)
    ''');
  }

  Future<void> _createAddressIndexes(Database db) async {
    await db.execute('''
      CREATE UNIQUE INDEX $userLabelIndex
      ON $deliveryAddressesTable(user_id, label COLLATE NOCASE)
      WHERE user_id IS NOT NULL
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX $userDefaultIndex
      ON $deliveryAddressesTable(user_id)
      WHERE is_default = 1 AND user_id IS NOT NULL
    ''');
    await db.execute('''
      CREATE INDEX $userArchivedIndex
      ON $deliveryAddressesTable(user_id, archived)
    ''');
  }
}
