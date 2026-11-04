# FASE 8 — CRUD y migración de direcciones

ESTADO: EN DESARROLLO

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

## PRs

### PR de migración

Issue: `#30`

Rama: `feat/30-migracion-direcciones`

- dependencias SQLite;
- `AppDatabase`;
- schema v1/v2;
- `onUpgrade`;
- migration test;
- documentación inicial.

### PR de CRUD

Issue: `#31`

Rama: `feat/31-crud-direcciones`

- `AddressRepository`;
- `AddressBook`;
- providers;
- lista;
- formulario;
- navegación;
- UNIQUE;
- en uso;
- archivado;
- pruebas.

El PR de CRUD se crea desde `main` después de integrar la migración.

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

## Calidad

- CI obligatorio: `Formato, análisis y pruebas`.
- Review formal obligatoria.
- Squash and merge.
- No se integra con 0 reviews.
- El ruleset de `main` permanece activo.

## Estado actual

- Bloque A: infraestructura SQLite y migración v1 → v2 integrada en `main`.
- Bloque B: CRUD de `DeliveryAddress` implementado en
  `feat/31-crud-direcciones`.
- Completado localmente: modelo extendido, `AddressBook`, repository SQLite,
  providers, lista, formulario único, navegación desde Home, UNIQUE,
  principal/en uso y archivado/restauración.
- Cierre funcional: hard delete para direcciones no principales, activas o
  archivadas; protección de principal en repository y UI; y restricciones
  UNIQUE traducidas por tipo.
- Pruebas: 181 aprobadas; incluyen SQLite real, providers, migración,
  formulario, lista responsive, navegación y Home.
- FASE 8 permanece **EN DESARROLLO**: faltan QA automatizado final, QA manual,
  CI, review y merge del PR de CRUD.

## Fuera de alcance

- Cart;
- Products;
- Checkout;
- backend;
- pagos;
- modificar la migración v1 → v2 o `AppDatabase`;
- migrar Cart o Products a SQLite.

No modificar FASE 6.
