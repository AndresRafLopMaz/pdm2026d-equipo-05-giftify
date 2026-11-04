import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/models/delivery_address.dart';
import 'address_book.dart';
import 'address_repository.dart';

class SqfliteAddressRepository implements AddressRepository {
  SqfliteAddressRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  static final Map<Object, Future<void>> _operations = {};
  static int _idSequence = 0;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  @override
  Future<AddressBook> loadBook() {
    return _serialize(() async {
      final db = await _db;
      final rows = await db.query(
        AppDatabase.deliveryAddressesTable,
        orderBy: 'is_default DESC, label COLLATE NOCASE ASC',
      );
      return AddressBook(addresses: rows.map(_fromRow).toList(growable: false));
    });
  }

  @override
  Future<DeliveryAddress> create(AddressDraft draft) {
    return _serialize(() async {
      final normalized = _normalize(draft);
      final db = await _db;

      try {
        return await db.transaction((txn) async {
          final makeDefault = normalized.isDefault || !await _hasDefault(txn);

          if (makeDefault) {
            await txn.update(AppDatabase.deliveryAddressesTable, {
              'is_default': 0,
            }, where: 'is_default = 1');
          }

          final address = DeliveryAddress(
            id: _newId(),
            label: normalized.label,
            recipientName: normalized.recipientName,
            addressLine: normalized.addressLine,
            city: normalized.city,
            department: normalized.department,
            reference: normalized.reference,
            isDefault: makeDefault,
          );

          await txn.insert(AppDatabase.deliveryAddressesTable, _toRow(address));
          return address;
        });
      } on DatabaseException catch (error) {
        throw _translate(error);
      }
    });
  }

  @override
  Future<DeliveryAddress> update(String id, AddressDraft draft) {
    return _serialize(() async {
      final normalized = _normalize(draft);
      final db = await _db;

      try {
        return await db.transaction((txn) async {
          final existing = await _findById(txn, id);
          final makeDefault = normalized.isDefault || existing.isDefault;

          if (makeDefault && !existing.isDefault) {
            await txn.update(AppDatabase.deliveryAddressesTable, {
              'is_default': 0,
            }, where: 'is_default = 1');
          }

          final updated = DeliveryAddress(
            id: existing.id,
            label: normalized.label,
            recipientName: normalized.recipientName,
            addressLine: normalized.addressLine,
            city: normalized.city,
            department: normalized.department,
            reference: normalized.reference,
            isDefault: makeDefault,
            isArchived: existing.isArchived,
          );

          await txn.update(
            AppDatabase.deliveryAddressesTable,
            _toRow(updated),
            where: 'id = ?',
            whereArgs: [existing.id],
          );
          return updated;
        });
      } on DatabaseException catch (error) {
        throw _translate(error);
      }
    });
  }

  @override
  Future<void> delete(String id) {
    return _serialize(() async {
      final db = await _db;

      try {
        await db.transaction((txn) async {
          final existing = await _findById(txn, id);
          if (existing.isDefault) {
            throw const AddressInUseException();
          }

          await txn.delete(
            AppDatabase.deliveryAddressesTable,
            where: 'id = ?',
            whereArgs: [existing.id],
          );
        });
      } on DatabaseException catch (error) {
        throw _translate(error);
      }
    });
  }

  @override
  Future<void> archive(String id) {
    return _serialize(() async {
      final db = await _db;

      try {
        await db.transaction((txn) async {
          final existing = await _findById(txn, id);
          if (existing.isArchived) {
            return;
          }

          if (!existing.isDefault) {
            await txn.update(
              AppDatabase.deliveryAddressesTable,
              {'archived': 1},
              where: 'id = ?',
              whereArgs: [existing.id],
            );
            return;
          }

          await txn.update(
            AppDatabase.deliveryAddressesTable,
            {'archived': 1, 'is_default': 0},
            where: 'id = ?',
            whereArgs: [existing.id],
          );

          final nextRows = await txn.query(
            AppDatabase.deliveryAddressesTable,
            columns: ['id'],
            where: 'archived = 0 AND id <> ?',
            whereArgs: [existing.id],
            orderBy: 'label COLLATE NOCASE ASC',
            limit: 1,
          );

          if (nextRows.isNotEmpty) {
            await txn.update(
              AppDatabase.deliveryAddressesTable,
              {'is_default': 1},
              where: 'id = ?',
              whereArgs: [nextRows.single['id']],
            );
          }
        });
      } on DatabaseException catch (error) {
        throw _translate(error);
      }
    });
  }

  @override
  Future<void> restore(String id) {
    return _serialize(() async {
      final db = await _db;

      try {
        await db.transaction((txn) async {
          final existing = await _findById(txn, id);
          if (!existing.isArchived) {
            return;
          }

          final hasDefault = await _hasDefault(txn);
          await txn.update(
            AppDatabase.deliveryAddressesTable,
            {'archived': 0, 'is_default': hasDefault ? 0 : 1},
            where: 'id = ?',
            whereArgs: [existing.id],
          );
        });
      } on DatabaseException catch (error) {
        throw _translate(error);
      }
    });
  }

  @override
  Future<void> setDefault(String id) {
    return _serialize(() async {
      final db = await _db;

      try {
        await db.transaction((txn) async {
          final existing = await _findById(txn, id);
          if (existing.isArchived) {
            throw const AddressValidationException(
              'No puedes usar como principal una dirección archivada.',
            );
          }
          if (existing.isDefault) {
            return;
          }

          await txn.update(AppDatabase.deliveryAddressesTable, {
            'is_default': 0,
          }, where: 'is_default = 1');
          await txn.update(
            AppDatabase.deliveryAddressesTable,
            {'is_default': 1},
            where: 'id = ?',
            whereArgs: [existing.id],
          );
        });
      } on DatabaseException catch (error) {
        throw _translate(error);
      }
    });
  }

  Future<DeliveryAddress> _findById(
    DatabaseExecutor executor,
    String id,
  ) async {
    final rows = await executor.query(
      AppDatabase.deliveryAddressesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw const AddressNotFoundException();
    }

    return _fromRow(rows.single);
  }

  Future<bool> _hasDefault(DatabaseExecutor executor) async {
    final rows = await executor.query(
      AppDatabase.deliveryAddressesTable,
      columns: ['id'],
      where: 'is_default = 1 AND archived = 0',
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  AddressDraft _normalize(AddressDraft draft) {
    final label = _normalizeLabel(draft.label);
    final recipientName = draft.recipientName.trim();
    final addressLine = draft.addressLine.trim();
    final city = draft.city.trim();
    final department = draft.department.trim();
    final reference = _normalizeOptional(draft.reference);

    if (label.isEmpty) {
      throw const AddressValidationException(
        'Ingresa un nombre para identificar la dirección.',
      );
    }
    if (recipientName.isEmpty) {
      throw const AddressValidationException(
        'Ingresa el nombre del destinatario.',
      );
    }
    if (addressLine.isEmpty) {
      throw const AddressValidationException('Ingresa la dirección.');
    }
    if (city.isEmpty) {
      throw const AddressValidationException('Ingresa la ciudad.');
    }
    if (department.isEmpty) {
      throw const AddressValidationException('Ingresa el departamento.');
    }

    return AddressDraft(
      label: label,
      recipientName: recipientName,
      addressLine: addressLine,
      city: city,
      department: department,
      reference: reference,
      isDefault: draft.isDefault,
    );
  }

  String _normalizeLabel(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String _newId() {
    _idSequence += 1;
    return 'addr-${DateTime.now().microsecondsSinceEpoch}-'
        '${_idSequence.toRadixString(16)}';
  }

  Map<String, Object?> _toRow(DeliveryAddress address) {
    return {
      'id': address.id,
      'label': address.label,
      'recipient_name': address.recipientName,
      'address_line': address.addressLine,
      'city': address.city,
      'department': address.department,
      'reference': address.reference,
      'archived': address.isArchived ? 1 : 0,
      'is_default': address.isDefault ? 1 : 0,
    };
  }

  DeliveryAddress _fromRow(Map<String, Object?> row) {
    return DeliveryAddress(
      id: row['id']! as String,
      label: row['label']! as String,
      recipientName: row['recipient_name']! as String,
      addressLine: row['address_line']! as String,
      city: row['city']! as String,
      department: row['department']! as String,
      reference: row['reference'] as String?,
      isDefault: (row['is_default'] as int? ?? 0) == 1,
      isArchived: (row['archived'] as int? ?? 0) == 1,
    );
  }

  AddressException _translate(DatabaseException error) {
    if (error.isUniqueConstraintError()) {
      return const DuplicateAddressLabelException();
    }
    return const AddressException(
      'No pudimos guardar los cambios de la dirección. '
      'Inténtalo de nuevo.',
    );
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final previous = _operations[_database] ?? Future<void>.value();
    final result = previous.then((_) => action());
    _operations[_database] = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }
}
