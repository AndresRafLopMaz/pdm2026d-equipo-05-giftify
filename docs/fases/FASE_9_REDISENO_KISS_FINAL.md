# FASE 9 — Rediseño KISS final

**Fecha:** 2026-11-05
**Rama:** `feat/redesign-kiss-final`
**Estado:** implementación técnica completada; QA manual pendiente.

## Objetivo

Unificar la presentación de Giftify bajo un sistema visual simple, consistente y
mobile-first, sin alterar la lógica de negocio, la persistencia ni la navegación
funcional existente.

## Problema visual previo

- Múltiples acentos: verde, rosa, amarillo y lila.
- Gradientes y sombras decorativas.
- Cards, bordes y radios inconsistentes.
- Inputs con decoraciones locales distintas.
- CTAs con tres colores y jerarquías diferentes.
- Home con contenido muerto y acciones duplicadas.
- Results con filtros y resumen dentro de cards.
- Detail con CTA al final del scroll.
- Cart con cards por producto y controles rosas.
- Checkout con cards y opciones de pago personalizadas.
- Addresses con Card por registro y estados decorativos de 76x76.
- Register con CTA amarillo y enlace de login sin función.

## Principios KISS aplicados

- Un solo acento verde.
- Fondo neutro.
- Sin gradientes.
- Sin sombras decorativas.
- Sin cards anidadas.
- Un CTA principal por pantalla.
- Mobile-first.
- Estados loading/error/empty consistentes.
- Accesibilidad antes que decoración.

## Sistema visual

- `primary`: `#087A4A`
- `primaryContainer`: `#E6F4EC`
- canvas: `#F7F8F7`
- surface: `#FFFFFF`
- surfaceMuted: `#EEF2EF`
- texto: `#1F2522`
- muted: `#5F6B64`
- borde: `#D8E0DB`
- error: `#B3261E`
- warning: `#7A5200`
- warning background: `#FFF4D6`

Centralizado en `core/theme/app_theme.dart`:

- ColorScheme.
- TextTheme.
- AppBarTheme.
- FilledButton, OutlinedButton y TextButton.
- CardTheme.
- InputDecorationTheme.
- NavigationBarTheme.
- DividerTheme.
- SnackBarTheme.
- DialogTheme.

## Navegación final

```text
Inicio | Buscar | Catálogo | Carrito
```

- `Próximamente` no es tab.
- `ComingSoonScreen` se conserva como fallback.
- `IndexedStack` conserva las tabs visitadas.
- Se mantiene `AppRouter`; no se migró a `go_router`.

## Pantallas modificadas

- Register.
- Home.
- Search.
- Results.
- Detail.
- Cart.
- Checkout.
- Addresses.
- AddressForm.
- AddressCard.
- MainShell.
- ComingSoonScreen.

## Persistencia preservada

- Productos eliminados: `SharedPreferences`.
- Carrito: `SharedPreferences`, únicamente `productId` y `quantity`.
- Direcciones: SQLite, CRUD, principal, UNIQUE, archivo y restauración.
- Se agregó una prueba de integración conceptual:
  carrito persistido → MainShell → tab Carrito → producto visible.

No se modificaron repositories, stores, providers, SQLite ni migraciones.

## Decisiones explícitamente NO implementadas

- Autenticación real.
- Login.
- Persistencia de perfil.
- Persistencia de criterios de búsqueda.
- Persistencia de Checkout u órdenes.
- Limpieza automática del carrito al confirmar.
- Integración Checkout → AddressBook.
- Pasarela de pago real.
- Backend.
- Migración a `go_router`.

## Tests

- Regresión automatizada: **184 pruebas aprobadas**.
- Format: 75 archivos, 0 cambios.
- Analyze: sin issues.
- Diff-check: exit 0.
- Se conservaron tests de migración, SQLite, repositorios, providers,
  persistencia, delete/undo, total y CRUD de direcciones.
- Se agregó un test de persistencia visible del carrito en MainShell.

## QA ejecutado

- `flutter build web`: exit 0.
- `flutter run -d edge --no-resident --web-port 7361`: exit 0.
- `flutter devices`: Windows y Edge disponibles.
- Windows build intentado: bloqueado por Developer Mode/symlinks.
- Android: no ejecutado; no hay Android SDK, `adb` ni emulador.
- No se declaró QA manual.

## QA pendiente

- Revisión visual manual en Android/Windows.
- Verificación de SQLite/Addresses en Android.
- Capturas antes/después.
- PR y reviews reales.

## Limitaciones

- Web no valida SQLite.
- La compilación Windows requiere Developer Mode habilitado.
- No hay evidencia manual de Android.
- No hay usuarios reales, backend ni pagos reales.
- No se generaron capturas en este bloque.

## Limpieza legacy

Se eliminaron de `app_theme.dart` las constantes sin referencias reales:

- `rosaPrincipal`
- `rosaClaro`
- `amarilloPrincipal`
- `verdeOscuro`

Después de modernizar `ComingSoonScreen`, también quedaron sin uso:

- `fondoPrincipal`
- `verdeClaro`
- `verdePrincipal`
- `textoPrincipal`
- `textoSecundario`

No quedan referencias legacy en `lib/` ni `test/`.
