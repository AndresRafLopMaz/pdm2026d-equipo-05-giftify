import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/enums/payment_brand.dart';
import '../../../shared/models/payment_method.dart';
import 'payment_method_errors.dart';
import 'payment_method_repository.dart';

class SqflitePaymentMethodRepository implements PaymentMethodRepository {
  SqflitePaymentMethodRepository({
    AppDatabase? database,
    required this.userId,
    this.now,
  }) : _database = database ?? AppDatabase.instance;

  static int _idSequence = 0;
  static final Map<Object, Future<void>> _operations = {};

  final AppDatabase _database;
  final int userId;
  final DateTime? now;

  Future<Database> get _db => _database.database;

  @override
  Future<List<PaymentMethod>> list() {
    return _serialize(() async {
      try {
        final db = await _db;
        final rows = await db.query(
          AppDatabase.paymentMethodsTable,
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'is_default DESC, brand COLLATE NOCASE ASC, last4 ASC',
        );
        return List<PaymentMethod>.unmodifiable(rows.map(_fromRow));
      } on DatabaseException {
        throw const PaymentMethodStorageException();
      }
    });
  }

  @override
  Future<PaymentMethod> create({
    required String holderName,
    required PaymentBrand brand,
    required String last4,
    required int expiryMonth,
    required int expiryYear,
    bool isDefault = false,
  }) {
    return _serialize(() async {
      final normalizedHolder = holderName.trim();
      final normalizedLast4 = last4.trim();
      _validate(
        holderName: normalizedHolder,
        last4: normalizedLast4,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
      );

      try {
        final db = await _db;
        return await db.transaction((txn) async {
          final existing = await txn.query(
            AppDatabase.paymentMethodsTable,
            columns: const ['id'],
            where: 'user_id = ?',
            whereArgs: [userId],
            limit: 1,
          );
          final makeDefault = isDefault || existing.isEmpty;

          if (makeDefault) {
            await txn.update(
              AppDatabase.paymentMethodsTable,
              {'is_default': 0},
              where: 'user_id = ?',
              whereArgs: [userId],
            );
          }

          final method = PaymentMethod(
            id: _newId(),
            userId: userId,
            holderName: normalizedHolder,
            brand: brand,
            last4: normalizedLast4,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            isDefault: makeDefault,
          );

          await txn.insert(AppDatabase.paymentMethodsTable, _toRow(method));
          return method;
        });
      } on DatabaseException {
        throw const PaymentMethodStorageException();
      }
    });
  }

  @override
  Future<void> delete(String id) {
    return _serialize(() async {
      try {
        final db = await _db;
        await db.transaction((txn) async {
          final existing = await _findById(txn, id);
          final wasDefault = existing.isDefault;

          await txn.delete(
            AppDatabase.paymentMethodsTable,
            where: 'id = ? AND user_id = ?',
            whereArgs: [id, userId],
          );

          if (!wasDefault) {
            return;
          }

          final nextRows = await txn.query(
            AppDatabase.paymentMethodsTable,
            columns: const ['id'],
            where: 'user_id = ?',
            whereArgs: [userId],
            orderBy: 'brand COLLATE NOCASE ASC, last4 ASC',
            limit: 1,
          );
          if (nextRows.isEmpty) {
            return;
          }

          await txn.update(
            AppDatabase.paymentMethodsTable,
            {'is_default': 1},
            where: 'id = ? AND user_id = ?',
            whereArgs: [nextRows.single['id'], userId],
          );
        });
      } on PaymentMethodException {
        rethrow;
      } on DatabaseException {
        throw const PaymentMethodStorageException();
      }
    });
  }

  @override
  Future<void> setDefault(String id) {
    return _serialize(() async {
      try {
        final db = await _db;
        await db.transaction((txn) async {
          final existing = await _findById(txn, id);
          if (existing.isDefault) {
            return;
          }

          await txn.update(
            AppDatabase.paymentMethodsTable,
            {'is_default': 0},
            where: 'user_id = ?',
            whereArgs: [userId],
          );
          await txn.update(
            AppDatabase.paymentMethodsTable,
            {'is_default': 1},
            where: 'id = ? AND user_id = ?',
            whereArgs: [id, userId],
          );
        });
      } on PaymentMethodException {
        rethrow;
      } on DatabaseException {
        throw const PaymentMethodStorageException();
      }
    });
  }

  Future<PaymentMethod> _findById(DatabaseExecutor executor, String id) async {
    final rows = await executor.query(
      AppDatabase.paymentMethodsTable,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const PaymentMethodNotFoundException();
    }
    return _fromRow(rows.single);
  }

  void _validate({
    required String holderName,
    required String last4,
    required int expiryMonth,
    required int expiryYear,
  }) {
    if (holderName.isEmpty) {
      throw const InvalidPaymentMethodException(
        'Ingresa el nombre del titular.',
      );
    }
    if (holderName.length > 80) {
      throw const InvalidPaymentMethodException(
        'El nombre del titular es demasiado largo.',
      );
    }
    if (!RegExp(r'^[0-9]{4}$').hasMatch(last4)) {
      throw const InvalidPaymentMethodException(
        'Ingresa exactamente los últimos 4 dígitos.',
      );
    }
    if (expiryMonth < 1 || expiryMonth > 12) {
      throw const InvalidPaymentMethodException(
        'Selecciona un mes de vencimiento válido.',
      );
    }

    final current = now ?? DateTime.now();
    if (expiryYear < current.year ||
        (expiryYear == current.year && expiryMonth < current.month)) {
      throw const InvalidPaymentMethodException(
        'La fecha de vencimiento no puede estar en el pasado.',
      );
    }
  }

  String _newId() {
    _idSequence += 1;
    return 'pay-${DateTime.now().microsecondsSinceEpoch}-'
        '${_idSequence.toRadixString(16)}';
  }

  Map<String, Object?> _toRow(PaymentMethod method) {
    return {
      'id': method.id,
      'user_id': userId,
      'holder_name': method.holderName,
      'brand': method.brand.name,
      'last4': method.last4,
      'expiry_month': method.expiryMonth,
      'expiry_year': method.expiryYear,
      'is_default': method.isDefault ? 1 : 0,
    };
  }

  PaymentMethod _fromRow(Map<String, Object?> row) {
    final brandName = row['brand']! as String;
    final brand = PaymentBrand.values.firstWhere(
      (value) => value.name == brandName,
      orElse: () => PaymentBrand.other,
    );

    return PaymentMethod(
      id: row['id']! as String,
      userId: row['user_id']! as int,
      holderName: row['holder_name']! as String,
      brand: brand,
      last4: row['last4']! as String,
      expiryMonth: row['expiry_month']! as int,
      expiryYear: row['expiry_year']! as int,
      isDefault: (row['is_default'] as int? ?? 0) == 1,
    );
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final key = '$userId:${identityHashCode(_database)}';
    final previous = _operations[key] ?? Future<void>.value();
    final result = previous.then((_) => action());
    _operations[key] = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }
}
