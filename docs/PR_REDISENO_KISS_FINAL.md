# feat: completar rediseño KISS y flujo funcional de Giftify

## Summary

Este PR consolida el rediseño KISS y la expansión funcional de Giftify: Home,
Search V2, catálogo, carrito, autenticación local, perfil, apariencia,
direcciones, métodos de pago ficticios, Checkout V2, aislamiento multiusuario
y soporte SQLite en Web.

Base: `main` en `55fd61780cc4d3572ad72cc2fa1b01f5abd277e7`.

## Principales cambios

- Design System KISS y evolución posterior a V2.
- Home con descubrimiento, categorías y accesos rápidos.
- Search V2 con criterios, presupuesto e intereses.
- Catálogo de 36 productos.
- Results, filtros y Detail.
- Autenticación local con sesión persistente y AuthGate.
- Profile y Settings.
- Light, Dark y System con persistencia.
- Carrito persistente por usuario.
- Addresses con principal, archivo y restauración.
- Ownership multiusuario para addresses, cart, deleted products y payments.
- Payment Methods ficticios.
- Checkout V2 con snapshot, selector de pago y pago vencido.
- Checkout Success sin Orders.
- SQLite Web mediante `sqflite_common_ffi_web`.
- README final y 16 capturas reales.

## Arquitectura

- Flutter y Material 3.
- Riverpod para estado y providers.
- Separación por `features/`.
- `AppRouter` centralizado y `AuthGate` en rutas privadas.
- Repositorios scoped por `user_id`.
- SQLite para usuarios, direcciones y pagos.
- SharedPreferences para sesión, tema, carrito, productos eliminados y
  markers de ownership.

## Persistencia

SQLite:

- `users`
- `delivery_addresses`
- `payment_methods`

SharedPreferences:

- `giftify.session_user_id`
- `giftify.theme_mode`
- `giftify.cart_entries.<userId>`
- `giftify.deleted_product_ids.<userId>`
- markers de ownership

Web:

- `sqflite_common_ffi_web` 1.2.0.
- `web/sqlite3.wasm`.
- `web/sqflite_sw.js`.
- Persistencia de navegador mediante IndexedDB.
- El soporte Web del paquete debe considerarse una solución de desarrollo.

## Seguridad

- PBKDF2-HMAC-SHA256.
- 600,000 iteraciones en producción.
- Salt de 16 bytes y hash de 32 bytes.
- Sin contraseñas en texto plano.
- Sin PAN completo.
- Sin CVV/CVC.
- Sin PIN.
- Sin token de gateway.
- Checkout simulado y sin backend/pagos reales.
- No se declara PCI DSS.

## Testing

- `dart format --output=none --set-exit-if-changed lib test`: PASS.
- `flutter analyze`: PASS.
- `flutter test`: **423 pruebas aprobadas**.
- `git diff --check`: PASS.
- `flutter build web`: PASS.

## Manual QA

Web:

- Prueba manual realizada por el usuario.
- Register/Login y capturas reales proporcionadas.
- SQLite Web habilitado en el puerto fijo 7366.

Android:

- **PENDIENTE**. No hay Android SDK, `adb` ni emulador/dispositivo disponible.
- Checklist manual en `docs/qa/QA_FINAL_ANDROID.md`.

## Known limitations

- Sin backend.
- Sin Orders ni historial de compras.
- Sin gateway ni pagos reales.
- Assets de producto mediante fallback A+ por categoría; WebP pendiente de
  licencia/origen.
- Android físico pendiente.
- Web requiere un origen estable para conservar IndexedDB.
- P2 de robustez documentados en `FASE_10G_QA_FINAL.md`.

## Screenshots

16 capturas reales en `docs/screenshots/`:

- Login, Register.
- Home, Search.
- Catalog, Cart.
- Addresses, Address form, Address created, Address archived.
- Profile, Appearance settings.
- Payment methods, Add payment method.
- Checkout confirmation, Order success.

## Review checklist

- Catherine: UX, copy, Profile, Payments, Checkout.
- Diego: tests, routing, migrations, responsive, accessibility.
- Brayan11Hernandez: visual, catalog, iconography, screenshots, manual QA.
- Andrés: integration, security, persistence, PR.

No se declaran reviews como realizados hasta que ocurran.
