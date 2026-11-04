# Catherine — repository y providers de direcciones

## Issue futuro

`#31 — [Lab S16] CRUD de direcciones con UNIQUE, en uso y archivado`

Depende de que el PR de migración `#30` esté integrado en `main`.

## Trabajo futuro

- `AddressBook`;
- `AddressRepository`;
- `SqfliteAddressRepository`;
- proveedor `addressRepositoryProvider`;
- `AddressesNotifier` y `addressesProvider`;
- traducción de UNIQUE a mensaje humano;
- regla de dirección principal;
- archivado y restauración;
- invalidación del provider después de cada mutación;
- pruebas unitarias del repositorio.

## Archivos previstos

```text
giftify/lib/features/addresses/data/address_book.dart
giftify/lib/features/addresses/data/address_repository.dart
giftify/lib/features/addresses/data/sqflite_address_repository.dart
giftify/lib/features/addresses/providers/addresses_provider.dart
giftify/test/address_repository_test.dart
```

## Dependencia

No comenzar el CRUD hasta que la migración v1 → v2 esté en `main`.
No modificar `AppDatabase` ni la migración publicada desde esta rama.

## Reglas

- No tocar Cart ni Products.
- No duplicar `DeliveryAddress`.
- La UI no debe recibir errores SQL.
- La lista se refresca con `ref.invalidate(addressesProvider)`.
- No agregar elementos manualmente a la lista de UI.
- Mantener loading, error con `Reintentar`, vacío y datos.
