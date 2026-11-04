# Laboratorio S16 — CRUD y migración de direcciones

ESTADO: BLOQUE A EN DESARROLLO

## 1. Objetivo

Incorporar `DeliveryAddress` como entidad persistente con CRUD completo,
UNIQUE por etiqueta, dirección principal como registro en uso y archivado.

El laboratorio se divide en dos PR separados:

1. migración SQLite v1 → v2;
2. CRUD, providers, lista, formulario y navegación.

## 2. Entidad

Entidad elegida: `DeliveryAddress`.

Motivos:

- el modelo ya existe en `shared/models/delivery_address.dart`;
- el formulario es pequeño y natural;
- Home ya tiene la entrada “Mis direcciones”;
- permite UNIQUE por `label`;
- permite “en uso” mediante `is_default`;
- permite archivar sin borrar;
- no obliga a modificar Cart ni Products.

## 3. Persistencia

SQLite se usa **únicamente** para `DeliveryAddress`.

- Archivo: `giftify.db`.
- Base: `AppDatabase`.
- Versión actual: `2`.
- Cart y Products continúan con `shared_preferences`.
- No se migran Cart ni Products a SQLite.
- No se modifica Checkout en este laboratorio.

## 4. Schema v1

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

## 5. Schema v2

Se agregan:

```sql
archived   INTEGER NOT NULL DEFAULT 0
is_default INTEGER NOT NULL DEFAULT 0
```

Índices:

- UNIQUE de `label COLLATE NOCASE`;
- UNIQUE parcial de `is_default = 1`;
- índice sobre `archived`.

## 6. Migración

`AppDatabase.onUpgrade` ejecuta:

- `ALTER TABLE` para `archived`;
- `ALTER TABLE` para `is_default`;
- creación de índices nuevos.

Prohibido:

- `DROP TABLE`;
- `DELETE`;
- recrear la tabla;
- borrar datos;
- editar una migración ya publicada.

La migración v1 → v2 es inmutable. Cualquier cambio futuro será v2 → v3.

## 7. Reglas funcionales

### UNIQUE

- `label` es única.
- Se aplica `trim` antes de guardar.
- El índice `COLLATE NOCASE` impide diferencias solo por mayúsculas.
- El repositorio traduce el error UNIQUE a un mensaje humano.
- Nunca se muestra SQL al usuario.

### En uso

```text
is_default == 1  →  dirección principal  →  en uso
```

- La principal no se puede eliminar.
- Se ofrece cambiarla de principal o archivarla.
- Al archivar la principal se reasigna la siguiente activa o se deja sin principal.

### Archivado

- `archived = 1` oculta la dirección de la lista activa.
- La lista permite consultar archivadas.
- Una archivada puede restaurarse.
- Una archivada que no sea principal puede eliminarse.

## 8. PRs

| PR | Rama prevista | Contenido |
|---|---|---|
| Migración | `feat/30-migracion-direcciones` | AppDatabase, schema v1/v2, onUpgrade, migration test |
| CRUD | `feat/31-crud-direcciones` | Repository, providers, lista, formulario, navegación, pruebas |

El PR de CRUD se crea desde el `main` actualizado después de integrar la migración.

## 9. Calidad y proceso

- CI obligatorio: `Formato, análisis y pruebas`.
- Review formal obligatoria.
- Squash and merge.
- No se integra con 0 reviews.
- El ruleset de `main` permanece activo.

## 10. Fuera de alcance del Bloque A

- `AddressRepository`;
- providers de direcciones;
- lista;
- formulario;
- navegación;
- CRUD;
- archivado desde UI.
