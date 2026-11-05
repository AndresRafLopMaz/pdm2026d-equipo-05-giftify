# FASE 10F - Ownership, métodos de pago y Checkout V2

## Estado

- **10F-A — Ownership por usuario:** completado.
- **10F-B — Payment Methods:** pendiente.
- **10F-C — Checkout V2:** pendiente.

Esta entrega implementa exclusivamente 10F-A. `AppDatabase.version = 4`.
No existe tabla `payment_methods`.

## 10F-A — Ownership

### Problema corregido

Antes de esta fase:

- `delivery_addresses` no tenía `user_id` y el repositorio consultaba todas las
  filas;
- `giftify.cart_entries` era global;
- `giftify.deleted_product_ids` era global;
- Logout solo limpiaba `giftify.session_user_id`.

Por eso A y B compartían datos.

### Schema v4

```sql
CREATE TABLE delivery_addresses (
  id TEXT PRIMARY KEY,
  user_id INTEGER
    REFERENCES users(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  recipient_name TEXT NOT NULL,
  address_line TEXT NOT NULL,
  city TEXT NOT NULL,
  department TEXT NOT NULL,
  reference TEXT,
  archived INTEGER NOT NULL DEFAULT 0,
  is_default INTEGER NOT NULL DEFAULT 0
);
```

`user_id` queda nullable solo para datos legacy hasta el claim. Las nuevas
direcciones siempre se insertan con `user_id`.

La migración reconstruye la tabla para eliminar el `UNIQUE` global de `label`.
Los datos se copian dentro de la migración; no se eliminan silenciosamente.

Índices:

```text
idx_delivery_addresses_user_label_nocase
  UNIQUE(user_id, label COLLATE NOCASE)
  WHERE user_id IS NOT NULL

idx_delivery_addresses_user_single_default
  UNIQUE(user_id)
  WHERE is_default = 1 AND user_id IS NOT NULL

idx_delivery_addresses_user_archived
  (user_id, archived)
```

Foreign keys:

```text
PRAGMA foreign_keys = ON
delivery_addresses.user_id → users.id ON DELETE CASCADE
```

### Migración

```text
v1 → v2
v2 → v3
v3 → v4
```

También se prueba v1→v4, v2→v4, v3→v4 y fresh v4.

### Claim legacy

Política aprobada:

- el primer usuario autenticado después del upgrade es el claimant;
- el claimant se persiste inmediatamente;
- si otro usuario entra antes de completar, no reclama nada;
- el legacy pendiente permanece reservado para el claimant;
- las direcciones sin propietario no son visibles para queries scoped.

Markers:

```text
giftify.ownership_migration_v1_claimant_user_id
giftify.ownership_migration_v1_completed
```

### Direcciones legacy

- `user_id = NULL` hasta el claim.
- El claim actualiza solo filas NULL.
- Si el claimant ya tiene una etiqueta igual, se genera `Casa (2)`, `Casa (3)`,
  etc. de forma determinista.
- Si el claimant ya tiene una dirección default, la legacy deja de ser default.
- Si el claimant no tiene default, una legacy default puede conservarlo.
- Los conflictos se resuelven antes de violar índices.

### Carrito

Keys:

```text
giftify.cart_entries.<userId>
legacy: giftify.cart_entries
```

El store recibe `userId`; el repository/provider se reconstruye al cambiar
usuario.

La migración legacy la ejecuta solo el claimant. Si la key destino ya existiera
por un crash previo, se hace merge por `productId` usando el máximo de cantidad.
Esta regla es idempotente y evita duplicar cantidades en un retry aunque el
proceso se interrumpa entre la escritura y la eliminación de la key legacy.

Se añadió `clearItems()` y `CartItemsNotifier.clear()` para validar aislamiento.
No se conectó todavía a Checkout V2.

### Productos eliminados

Keys:

```text
giftify.deleted_product_ids.<userId>
legacy: giftify.deleted_product_ids
```

La migración hace unión de sets hacia el claimant y elimina la key legacy.
Los reintentos son idempotentes.

`MockProductRepository` sigue usando el catálogo global, pero el
`DeletedProductsStore` es por usuario.

### Providers

```text
currentUserIdProvider
ownershipMigrationProvider
```

Los providers de addresses, cart y products esperan la migración y reconstruyen
su estado cuando cambia `currentUserId`.

- `addressesProvider` pasó a autoDispose.
- `cartItemsProvider` ya era autoDispose.
- `productsProvider` ya era autoDispose family.
- No se conserva el estado de A al entrar B.
- Los repositories no importan AuthController.

### Rutas protegidas

Se protegieron con `AuthGate`:

```text
/addresses
/cart
/checkout
```

Sin sesión muestran Login y no exponen datos.

Se mantienen Profile/Settings protegidos y el fallback de ruta desconocida.

### Tests de 10F-A

Cubiertos:

- migración v1/v2/v3 → v4;
- fresh v4;
- FK y ON DELETE CASCADE;
- labels duplicados entre usuarios permitidos;
- label duplicado dentro del mismo usuario rechazado;
- default independiente;
- claim de legacy addresses;
- colisiones de label/default;
- pendingForOtherUser;
- cart A/B;
- cart legacy y retry sin duplicación;
- deleted products A/B;
- products provider al cambiar usuario;
- direcciones/carrito/checkout sin sesión;
- regresión completa.

Total actual: **345 pruebas aprobadas**.

## Limitaciones

- No se implementó Payment Methods.
- No se implementó Checkout V2.
- No se implementaron Orders.
- No se modificó password hashing, Auth, Theme ni Search.
- Legacy se atribuye al primer login; el dato histórico era global y no existe
  atribución perfecta. La política está documentada y probada.
- La validación física en Android sigue pendiente.
- La compilación web no valida SQLite.

## Participación

- Andrés: SQLite v4, rebuilding de addresses, FKs, ownership service, claim,
  scoped repositories/stores, providers e integración.
- Diego: tests de migración, multiusuario, routing y regresión.
- Catherine: revisión de flujo de cambio de usuario y documentación UX; no se
  forzó un commit propio sin implementación sustancial.
- Brayan11Hernandez: revisión conceptual, casos manuales y documentación; sin
  acceso a migraciones, repositories, storage keys ni Auth. No se usó como
  author/co-author sin email Git verificado.
