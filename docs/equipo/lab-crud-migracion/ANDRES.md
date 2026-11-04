# Andrés — migración SQLite

## Issue

`#30 — [Lab S16] Migración SQLite versionada de direcciones`

## Rama

`feat/30-migracion-direcciones`

## Trabajo asignado

- dependencias `sqflite`, `path` y `sqflite_common_ffi`;
- `AppDatabase` con `version = 2`;
- archivo `giftify.db`;
- apertura perezosa;
- `onCreate` con esquema v2;
- `onUpgrade` v1 → v2;
- migration test desde una base v1 con datos;
- documentación inicial de FASE 8;
- QA del bloque.

## Archivos principales

```text
giftify/lib/core/database/app_database.dart
giftify/test/database/address_migration_test.dart
giftify/test/helpers/database_test_helper.dart
giftify/pubspec.yaml
giftify/pubspec.lock
docs/equipo/lab-crud-migracion/
docs/fases/FASE_8_CRUD_MIGRACION.md
```

## Reglas

- SQLite solo para `DeliveryAddress`.
- No modificar Cart ni Products.
- No implementar repository, providers, lista, formulario, navegación ni CRUD.
- No editar la migración v1 → v2 después de publicarla.
- No integrar sin CI verde y review formal.

## Validación

Desde `giftify/`:

```powershell
dart format lib test
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Desde la raíz:

```powershell
git diff --check
```

## Pregunta obligatoria del PR

La respuesta técnica debe explicar que una migración publicada pudo ejecutarse
antes, que el teléfono no necesariamente la vuelve a ejecutar, que el esquema
real puede quedar distinto del esperado y que por eso toda migración publicada
es inmutable.
