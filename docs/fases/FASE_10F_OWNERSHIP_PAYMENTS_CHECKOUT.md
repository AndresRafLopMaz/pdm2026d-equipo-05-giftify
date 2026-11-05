# FASE 10F - Ownership, métodos de pago y Checkout V2

## Estado

- **10F-A — Ownership por usuario:** completado.
- **10F-B — Payment Methods:** completado.
- **10F-C — Checkout V2:** pendiente.

Estado actual:

```text
AppDatabase.version = 5
```

No existen Orders ni gateway. Checkout V2 todavía no está implementado.

## 10F-A — Ownership

### Problema corregido

Antes de 10F-A:

- `delivery_addresses` no tenía `user_id`;
- `giftify.cart_entries` era global;
- `giftify.deleted_product_ids` era global;
- Logout solo limpiaba la sesión.

### Schema de direcciones v4

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

Índices:

```text
idx_delivery_addresses_user_label_nocase
idx_delivery_addresses_user_single_default
idx_delivery_addresses_user_archived
```

La tabla se reconstruyó para eliminar el UNIQUE global de `label`.

### Claim legacy

Política: el primer usuario autenticado después del upgrade es el claimant.

Markers:

```text
giftify.ownership_migration_v1_claimant_user_id
giftify.ownership_migration_v1_completed
```

- filas legacy quedan con `user_id = NULL` hasta el claim;
- no son visibles para otros usuarios;
- si B entra antes de completar, no reclama y puede usar sus datos;
- A retoma la migración al volver;
- colisiones de label se resuelven como `Casa (2)`;
- el default del claimant se conserva si ya existe.

### Cart y deleted legacy

```text
giftify.cart_entries.<userId>
giftify.deleted_product_ids.<userId>
```

El claimant mueve el carrito legacy y los eliminados. El merge de carrito usa
máximo de cantidad por producto para que sea idempotente ante un crash entre
escritura y borrado de la key legacy.

### Providers

```text
currentUserIdProvider
ownershipMigrationProvider
```

Addresses, cart y products se reconstruyen al cambiar usuario. No se conserva
estado de A al entrar B.

### Rutas privadas base

Se protegieron con AuthGate:

```text
/addresses
/cart
/checkout
```

## 10F-B — Payment Methods

### DB v5

```sql
CREATE TABLE payment_methods (
  id TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL
    REFERENCES users(id) ON DELETE CASCADE,
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
);

CREATE INDEX idx_payment_methods_user
ON payment_methods(user_id);

CREATE UNIQUE INDEX idx_payment_methods_user_default
ON payment_methods(user_id)
WHERE is_default = 1;
```

`PRAGMA foreign_keys = ON` sigue activo.

### Modelo

```dart
PaymentBrand { visa, mastercard, amex, other }
```

Labels: Visa, Mastercard, American Express, Otra.

`PaymentMethod`:

```text
id
userId
holderName
brand
last4
expiryMonth
expiryYear
isDefault
```

No contiene PAN, CVV, PIN, gatewayToken ni billingAddress.

### Seguridad

No se captura ni persiste:

```text
PAN completo
CVV/CVC
PIN
token de gateway
```

La UI pide directamente:

```text
Titular
Marca
Últimos 4 dígitos
Mes
Año
Predeterminado
```

Se muestra:

```text
Usa datos ficticios para esta demostración.
```

No hay integración con Stripe, PayPal, bancos ni gateways. No se declara PCI DSS.

### Repositorio

```text
SqflitePaymentMethodRepository(userId)
```

- todas las operaciones filtran `user_id`;
- delete/setDefault no cruzan usuarios;
- el primer método queda default;
- setDefault solo afecta al usuario;
- delete default promueve determinísticamente otro método;
- hard delete;
- no update.

### Validación

```text
holderName no vacío, trim, máximo 80
last4 exactamente 4 dígitos ASCII
month 1–12
year no vencido
```

La validación de vencimiento usa `now` inyectable en el repository para tests.

### UI

```text
PaymentMethodsScreen
AddPaymentMethodScreen
```

PaymentMethodsScreen:

- lista;
- empty state;
- aviso ficticio;
- default visible con texto;
- menú de acciones;
- eliminar con confirmación;
- agregar.

AddPaymentMethodScreen:

- formulario;
- dropdown de marca;
- mes/año;
- switch de predeterminado;
- validaciones;
- sin PAN/CVV.

### Profile y rutas

Profile añade:

```text
Cuenta
- Mis direcciones
- Métodos de pago
```

Rutas:

```text
/payment-methods
/payment-methods/new
```

Ambas protegidas por AuthGate.

### Provider

```text
paymentMethodRepositoryProvider
paymentMethodsProvider
```

Dependen de `currentUserIdProvider` y se reconstruyen al cambiar usuario.

### Tests

Cubiertos:

- migración v4 → v5;
- cadena v1/v2/v3 → v5;
- fresh v5;
- constraints de brand, last4, month, default y FK;
- CRUD de repositorio;
- default independiente;
- promoción al borrar default;
- aislamiento A/B;
- no cruce de delete/setDefault;
- cascada de user delete;
- provider switch;
- UI empty/list/default/delete/add;
- validaciones;
- dark y responsive;
- rutas protegidas;
- regresión de ownership, Auth y Theme.

Total actual: **373 pruebas aprobadas**.

## Limitaciones

- Checkout V2 no implementado.
- Orders no implementado.
- No hay gateway ni procesamiento real.
- No hay edición de métodos.
- No hay PAN ni CVV.
- Android pendiente de validación física.
- Web no valida SQLite.
- La atribución legacy sigue siendo por primer login.
- El merge legacy de carrito usa máximo de cantidad para ser idempotente.

## Participación

- Andrés: DB v5, schema, constraints, FK, repository scoped, provider,
  seguridad de storage e integración.
- Catherine: revisión de UX de Payment Methods, empty state, delete/default,
  copy y discoverability desde Profile; no se forzó commit propio sin
  implementación sustancial.
- Diego: tests de migración, multiusuario, seguridad, routing, dark,
  responsive y documentación.
- Brayan11Hernandez: revisión de datos ficticios, copy, QA conceptual, casos
  manuales y documentación. Sin acceso a migrations, repositories, storage,
  Auth ni providers críticos. No se usó como author/co-author sin email Git
  verificado.
