# FASE 8 — CRUD y migración de direcciones

ESTADO: COMPLETADA

## Objetivo

Incorporar `DeliveryAddress` como entidad persistente con:

- lista;
- crear;
- editar;
- borrar;
- mismo formulario para crear y editar;
- edición con el mismo id;
- UNIQUE por etiqueta con mensaje humano;
- dirección principal como registro en uso;
- eliminación bloqueada para la principal;
- archivado como salida;
- migración SQLite versionada;
- prueba desde una base anterior con datos;
- refresco de lista mediante provider.

## Decisión de persistencia

SQLite se usa únicamente para `DeliveryAddress`.

- Archivo: `giftify.db`.
- `AppDatabase.version = 2`.
- Cart y Products continúan con `shared_preferences`.
- No se migran Cart ni Products.
- No se modifica Checkout en esta fase.

## Schema v1

```sql
CREATE TABLE delivery_addresses (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL UNIQUE,
  recipient_name TEXT NOT NULL,
  address_line TEXT NOT NULL,
  city TEXT NOT NULL,
  department TEXT NOT NULL,
  reference TEXT
);
```

## Schema v2

Se agregan:

```sql
archived   INTEGER NOT NULL DEFAULT 0
is_default INTEGER NOT NULL DEFAULT 0
```

Índices:

- `UNIQUE(label COLLATE NOCASE)`;
- `UNIQUE(is_default) WHERE is_default = 1`;
- índice sobre `archived`.

## Migración

`onUpgrade` v1 → v2:

- agrega `archived`;
- agrega `is_default`;
- crea los índices;
- conserva las filas existentes;
- no borra, no recrea y no destruye datos.

La migración publicada es inmutable. Los cambios futuros se harán en v2 → v3.

## Prueba de migración

Archivo:

```text
giftify/test/database/address_migration_test.dart
```

Flujo:

1. crear base temporal v1;
2. insertar una dirección real;
3. cerrar;
4. abrir con `AppDatabase` v2;
5. ejecutar `onUpgrade`;
6. comprobar id y datos;
7. comprobar `archived = 0` e `is_default = 0`;
8. comprobar versión 2;
9. comprobar columnas e índices;
10. comprobar CRUD básico v2;
11. reabrir y confirmar que los datos siguen igual.

## PRs integrados

| PR real | Issue | Rama | Squash merge en main | CI | Reviews |
|---|---|---|---|---|---|
| `#32` | `#30` | `feat/30-migracion-direcciones` | `d0e87d4094209f53af4e56957c5fd9bfb7b8b4a0` | 2 checks en success | 0 reviews |
| `#33` | `#31` | `feat/31-crud-direcciones` | `58785636af14054f442a30facaa8505e36c9df8a` | 2 checks en success | 0 reviews |

No existe un PR `#31`; `#31` es el Issue del CRUD. El PR real del CRUD es `#33`.

### Excepción de review

Los PR `#32` y `#33` no registraron reviews formales antes del merge.
El CI sí quedó en verde. Esta situación se documenta como excepción de proceso.

El Issue `#30` está cerrado. El Issue `#31` permanece abierto al momento de este
cierre documental.

## Reglas funcionales

### UNIQUE

- `label` se normaliza con `trim`.
- UNIQUE real en SQLite.
- UNIQUE `COLLATE NOCASE`.
- El repositorio traduce el error a:

```text
Ya existe una dirección con ese nombre.
Usa otro nombre para identificarla.
```

### En uso

```text
is_default = 1  →  dirección principal  →  en uso
```

- No se elimina.
- Se ofrece cambiar principal o archivar.
- Al archivar la principal se reasigna la siguiente activa o se deja sin principal.
- Una dirección activa que no sea principal sí puede eliminarse directamente.

### Archivado

- `archived = 1` oculta de la lista activa.
- Se puede consultar archivadas.
- Se puede restaurar.
- Una archivada no principal se puede eliminar.

## Calidad y cierre

- CI: PR `#32` y PR `#33` con 2 checks en `success`.
- Squash and merge: aplicado en ambos PR.
- Reviews formales: **0** en `#32` y **0** en `#33`.
- La ausencia de reviews se registra como excepción de proceso, no como
  aprobación inventada.
- Ruleset de `main`: permanece activo; este cierre documental se hace por rama y
  PR, no por push directo.

## QA final real

Ejecutado sobre `main` actualizado:

- `dart format --output=none --set-exit-if-changed lib test`:
  `Formatted 75 files (0 changed)`.
- `flutter analyze`: `No issues found!`.
- `flutter test`: **181 pruebas aprobadas**.
- `git diff --check`: sin errores, exit code `0`.

## QA manual Android

**NO EJECUTADA.**

Motivo: el entorno utilizado no tenía Android SDK, AVD ni `adb`.
No se declara evidencia visual/manual como completada.

## Estado actual

- Bloque A: infraestructura SQLite y migración v1 → v2 integrada en `main`.
- Bloque B: CRUD de `DeliveryAddress` integrado en `main`.
- Modelo extendido, `AddressBook`, repository SQLite, providers, lista,
  formulario único, navegación desde Home, UNIQUE, principal/en uso,
  delete libre y archivado/restauración: completados.
- Migración v1 → v2 y `AppDatabase` conservados sin cambios tras el CRUD.
- Issue `#31`: permanece abierto al cierre documental.
- FASE 8: **COMPLETADA** documentalmente con la limitación explícita de QA
  manual Android no ejecutada.

## Fuera de alcance

- Cart;
- Products;
- Checkout;
- backend;
- pagos;
- modificar la migración v1 → v2 o `AppDatabase`;
- migrar Cart o Products a SQLite.

No modificar FASE 6.
