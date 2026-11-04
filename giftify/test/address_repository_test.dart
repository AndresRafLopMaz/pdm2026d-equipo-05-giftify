import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/database/app_database.dart';
import 'package:giftify/features/addresses/data/address_book.dart';
import 'package:giftify/features/addresses/data/address_repository.dart';
import 'package:giftify/features/addresses/data/sqflite_address_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/database_test_helper.dart';

AddressDraft _draft(
  String label, {
  String recipient = 'María López',
  String addressLine = '5a avenida 10-20, zona 1',
  String city = 'Guatemala',
  String department = 'Guatemala',
  String? reference = 'Portón verde',
  bool isDefault = false,
}) {
  return AddressDraft(
    label: label,
    recipientName: recipient,
    addressLine: addressLine,
    city: city,
    department: department,
    reference: reference,
    isDefault: isDefault,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late String databasePath;
  late AppDatabase appDatabase;
  late SqfliteAddressRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDirectory = await createDatabaseTestDirectory();
    databasePath = databasePathIn(tempDirectory);
    appDatabase = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
    repository = SqfliteAddressRepository(database: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
    await deleteDatabaseTestDirectory(tempDirectory);
  });

  test('crea y persiste la primera dirección como principal', () async {
    final created = await repository.create(_draft('Casa'));

    expect(created.isDefault, isTrue);
    expect(created.isArchived, isFalse);

    final book = await repository.loadBook();
    expect(book.active, hasLength(1));
    expect(book.active.single.id, created.id);
    expect(book.active.single.label, 'Casa');
    expect(book.defaultAddressId, created.id);
  });

  test('la segunda dirección no es principal y se puede cambiar', () async {
    final casa = await repository.create(_draft('Casa'));
    final trabajo = await repository.create(_draft('Trabajo'));

    expect(casa.isDefault, isTrue);
    expect(trabajo.isDefault, isFalse);

    await repository.setDefault(trabajo.id);

    final book = await repository.loadBook();
    expect(book.defaultAddressId, trabajo.id);
    expect(
      book.active.firstWhere((address) => address.id == casa.id).isDefault,
      isFalse,
    );
  });

  test('editar conserva exactamente el mismo id', () async {
    final created = await repository.create(_draft('Casa'));

    final updated = await repository.update(
      created.id,
      _draft(
        'Casa de mamá',
        city: 'Mixco',
        addressLine: '10a calle 2-30, zona 3',
      ),
    );

    expect(updated.id, created.id);
    expect(updated.label, 'Casa de mamá');
    expect(updated.city, 'Mixco');
    expect(updated.isDefault, isTrue);

    final book = await repository.loadBook();
    expect(book.active.single.id, created.id);
    expect(book.active.single.label, 'Casa de mamá');
  });

  test('normaliza trim y espacios internos de la etiqueta', () async {
    final created = await repository.create(_draft('   Casa   de   mamá  '));

    expect(created.label, 'Casa de mamá');
  });

  test('UNIQUE ignora mayúsculas y espacios alrededor', () async {
    await repository.create(_draft('Casa'));

    await expectLater(
      repository.create(_draft('   CASA   ')),
      throwsA(
        isA<DuplicateAddressLabelException>().having(
          (error) => error.message,
          'message',
          contains('Ya existe una dirección con ese nombre.'),
        ),
      ),
    );

    final book = await repository.loadBook();
    expect(book.active, hasLength(1));
  });

  test('el duplicado en edición se traduce a mensaje humano', () async {
    await repository.create(_draft('Casa'));
    final trabajo = await repository.create(_draft('Trabajo'));

    await expectLater(
      repository.update(trabajo.id, _draft('casa')),
      throwsA(isA<DuplicateAddressLabelException>()),
    );

    final book = await repository.loadBook();
    expect(
      book.active.firstWhere((address) => address.id == trabajo.id).label,
      'Trabajo',
    );
  });

  test('el error UNIQUE nunca expone SQL', () async {
    await repository.create(_draft('Casa'));

    try {
      await repository.create(_draft('casa'));
      fail('Se esperaba un duplicado.');
    } on DuplicateAddressLabelException catch (error) {
      expect(error.toString(), isNot(contains('UNIQUE')));
      expect(error.toString(), isNot(contains('SqliteException')));
    }
  });

  test('bloquea eliminar una dirección activa no principal', () async {
    final casa = await repository.create(_draft('Casa'));
    final trabajo = await repository.create(_draft('Trabajo'));

    await expectLater(
      repository.delete(trabajo.id),
      throwsA(
        isA<ActiveAddressDeletionException>().having(
          (error) => error.message,
          'message',
          'Archiva la dirección antes de eliminarla definitivamente.',
        ),
      ),
    );

    final book = await repository.loadBook();
    expect(book.active, hasLength(2));
    expect(book.defaultAddressId, casa.id);
  });

  test(
    'elimina definitivamente una dirección archivada no principal',
    () async {
      await repository.create(_draft('Casa'));
      final trabajo = await repository.create(_draft('Trabajo'));
      await repository.archive(trabajo.id);

      await repository.delete(trabajo.id);

      final book = await repository.loadBook();
      expect(book.active, hasLength(1));
      expect(book.archived, isEmpty);
    },
  );

  test('la dirección principal en uso no se puede eliminar', () async {
    final casa = await repository.create(_draft('Casa'));

    await expectLater(
      repository.delete(casa.id),
      throwsA(
        isA<AddressInUseException>().having(
          (error) => error.message,
          'message',
          'No puedes eliminar la dirección principal porque está en uso.',
        ),
      ),
    );

    final book = await repository.loadBook();
    expect(book.active, hasLength(1));
    expect(book.active.single.id, casa.id);
  });

  test('archivar una dirección no principal la oculta de activas', () async {
    await repository.create(_draft('Casa'));
    final trabajo = await repository.create(_draft('Trabajo'));

    await repository.archive(trabajo.id);

    final book = await repository.loadBook();
    expect(book.active, hasLength(1));
    expect(book.archived, hasLength(1));
    expect(book.archived.single.id, trabajo.id);
    expect(book.defaultAddressId, isNot(trabajo.id));
  });

  test('archivar la principal reasigna otra activa', () async {
    final casa = await repository.create(_draft('Casa'));
    await repository.create(_draft('Trabajo'));
    final oficina = await repository.create(_draft('Oficina'));

    await repository.archive(casa.id);

    final book = await repository.loadBook();
    expect(book.archived.single.id, casa.id);
    expect(book.defaultAddressId, oficina.id);
    expect(
      book.active.firstWhere((address) => address.id == oficina.id).isDefault,
      isTrue,
    );
  });

  test('archivar la única principal deja la principal en null', () async {
    final casa = await repository.create(_draft('Casa'));

    await repository.archive(casa.id);

    final book = await repository.loadBook();
    expect(book.active, isEmpty);
    expect(book.archived.single.id, casa.id);
    expect(book.defaultAddressId, isNull);
  });

  test(
    'restaurar una dirección sin principal la convierte en principal',
    () async {
      final casa = await repository.create(_draft('Casa'));
      await repository.archive(casa.id);

      await repository.restore(casa.id);

      final book = await repository.loadBook();
      expect(book.archived, isEmpty);
      expect(book.active.single.id, casa.id);
      expect(book.defaultAddressId, casa.id);
    },
  );

  test('restaurar conserva la principal existente', () async {
    final casa = await repository.create(_draft('Casa'));
    final trabajo = await repository.create(_draft('Trabajo'));
    await repository.archive(casa.id);

    await repository.restore(casa.id);

    final book = await repository.loadBook();
    expect(book.defaultAddressId, trabajo.id);
    expect(
      book.active.firstWhere((address) => address.id == casa.id).isDefault,
      isFalse,
    );
  });

  test('no permite usar una dirección archivada como principal', () async {
    final casa = await repository.create(_draft('Casa'));
    await repository.archive(casa.id);

    await expectLater(
      repository.setDefault(casa.id),
      throwsA(isA<AddressValidationException>()),
    );
  });

  test('editar no permite convertir una archivada en principal', () async {
    final casa = await repository.create(_draft('Casa'));
    final trabajo = await repository.create(_draft('Trabajo'));
    await repository.archive(trabajo.id);

    await expectLater(
      repository.update(trabajo.id, _draft('Trabajo', isDefault: true)),
      throwsA(isA<AddressValidationException>()),
    );

    final book = await repository.loadBook();
    expect(book.defaultAddressId, casa.id);
    expect(book.archived.single.id, trabajo.id);
    expect(book.archived.single.isDefault, isFalse);
  });

  test('una restricción UNIQUE ajena a label usa un error genérico', () async {
    final db = await appDatabase.database;
    await db.execute('''
      CREATE TRIGGER reject_address_insert
      BEFORE INSERT ON ${AppDatabase.deliveryAddressesTable}
      BEGIN
        SELECT RAISE(ABORT, 'UNIQUE constraint failed: delivery_addresses.id');
      END
    ''');

    await expectLater(
      repository.create(_draft('Casa')),
      throwsA(
        isA<AddressException>()
            .having(
              (error) => error,
              'type',
              isNot(isA<DuplicateAddressLabelException>()),
            )
            .having((error) => error.message, 'message', isNot(contains('SQL')))
            .having(
              (error) => error.message,
              'message',
              isNot(contains('delivery_addresses')),
            ),
      ),
    );
  });

  test('los datos persisten al cerrar y reabrir SQLite', () async {
    final casa = await repository.create(_draft('Casa'));
    final trabajo = await repository.create(_draft('Trabajo'));
    await repository.setDefault(trabajo.id);
    await repository.archive(casa.id);

    await appDatabase.close();

    final reopened = AppDatabase(
      factory: databaseFactoryFfi,
      path: databasePath,
    );
    addTearDown(reopened.close);
    final reopenedRepository = SqfliteAddressRepository(database: reopened);

    final book = await reopenedRepository.loadBook();
    expect(book.active, hasLength(1));
    expect(book.active.single.id, trabajo.id);
    expect(book.active.single.isDefault, isTrue);
    expect(book.archived.single.id, casa.id);
    expect(book.defaultAddressId, trabajo.id);
  });
}
