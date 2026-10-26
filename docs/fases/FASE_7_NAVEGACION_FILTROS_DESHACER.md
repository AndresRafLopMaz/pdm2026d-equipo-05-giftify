# FASE 7 — Navegación, filtros y Deshacer

ESTADO: COMPLETADA

## Objetivo

Incorporar navegación principal con provider/Notifier e `IndexedStack`, filtros
reactivos sobre listados y borrado con Deshacer persistente, manteniendo Giftify
como un MVP completamente local.

## Requisitos del laboratorio

- navegación real mediante provider/Notifier + `IndexedStack`;
- ningún botón de navegación sin acción;
- pantallas inexistentes muestran `Próximamente`;
- navegación desde otra pantalla cambiando el provider, sin callbacks por
  constructor;
- trabajo en parejas sobre listados filtrables;
- filtro como objeto inmutable dentro de un Notifier;
- el provider del listado hace `ref.watch` del filtro;
- cambiar filtro vuelve a consultar automáticamente;
- conservar loading/error/retry/empty/data;
- `Dismissible` con key = id, nunca índice;
- borrar primero en repositorio/persistencia;
- si falla, la fila vuelve;
- SnackBar con `Deshacer`;
- Deshacer restaura el registro idéntico con el mismo id;
- widget tests de filtro, borrado y Deshacer;
- PR con CI verde y review;
- persistencia local al cerrar/reabrir.

## Decisiones arquitectónicas

- `flutter_riverpod` 3.x como gestor de estado.
- `Notifier` + `IndexedStack`.
- Tabs: Inicio, Buscar, Catálogo, Próximamente.
- `AppRouter` se conserva para Detail, Cart y Checkout.
- `shared_preferences` para persistencia local.
- No SQLite.
- No backend remoto.
- No `go_router`.
- Protección de `main` activa.

## Navegación

```text
Register → AppRoutes.home → MainShell
```

MainShell:

```text
Inicio       → HomeScreen
Buscar       → GiftSearchScreen
Catálogo     → ProductResultsScreen(criteria: null)
Próximamente → ComingSoonScreen
```

Home:

- CTA → `AppTab.search`;
- “Ver todo” → `AppTab.catalog`;
- accesos sin pantalla → `AppTab.comingSoon`.

`IndexedStack` mantiene el estado y el scroll.

## Riverpod

- `ProviderScope` en `main.dart`.
- `AppTabNotifier` / `appTabProvider`.
- Providers asíncronos con retry automático desactivado:

```dart
retry: (retryCount, error) => null
```

## shared_preferences

Persistencia local:

- Products: IDs eliminados; restaurar desde `mockProducts`.
- Cart: `productId` + `quantity`; reconstruir desde `mockProducts`.

La prueba de cerrar/reabrir es obligatoria.

## Parejas y ramas previstas

### Pareja 1

```text
Andrés + Brayan
Rama: feat/<issue>-filtro-productos
```

Products: `ProductFilter`, `ProductFilterNotifier`, `productFilterProvider`,
`productsProvider`, delete/undo y persistencia.

### Pareja 2

```text
Catherine + Diego
Rama: feat/<issue>-filtro-carrito
```

Cart: `CartRepository`, `CartFilter`, `cartFilterProvider`,
`cartItemsProvider`, delete/undo y persistencia.

## Pruebas previstas

- navegación por tabs;
- Home CTA y “Ver todo”;
- scroll conservado;
- cada botón de navegación con acción;
- filtro reactivo sin botón Recargar;
- empty por filtro;
- Dismissible key = id;
- delete falla => fila permanece;
- undo restaura mismo id/datos;
- persistencia cerrar/reabrir;
- Cart total y Checkout con todos los ítems;
- flujo Register → Checkout;
- CI verde.

## Estado actual

- Bloque A: navegación base, Riverpod, `MainShell`, tabs y documentación.
- Navegación integrada en `main` mediante PR #25.
- Issue de Products: #26.
- Rama Products: `feat/26-filtro-productos`.
- Pareja 1 (Products): implementada e integrada mediante PR #28.
  - `ProductFilter` inmutable;
  - `ProductFilterNotifier` y `productFilterProvider`;
  - `productsProvider` con `ref.watch` del filtro;
  - delete/restore repository-first;
  - `Dismissible` con key = id;
  - SnackBar con Deshacer;
  - persistencia de IDs eliminados con `shared_preferences`;
  - loading/error/retry/empty/data.
- Issue de Cart: #27.
- Rama Cart: `feat/27-filtro-carrito`.
- Pareja 2 (Cart): implementada e integrada mediante PR #29.
  - `CartRepository` y `PersistentCartRepository`;
  - `CartFilter` inmutable y `cartFilterProvider`;
  - `cartItemsProvider` con `ref.watch` del filtro;
  - `CartSnapshot` con `allItems`, `visibleItems`, total y categorías;
  - filtro no altera el total general;
  - Checkout recibe todos los ítems reales;
  - `Dismissible` con key = id;
  - delete repository-first, fallo conserva la fila;
  - SnackBar con Deshacer;
  - restauración de mismo id, producto y cantidad;
  - persistencia con `shared_preferences`;
  - loading/error/retry/empty/data;
  - carrito vacío diferenciado de filtro sin resultados.
- Validación global final: 137 pruebas aprobadas.
- FASE 7 completada técnicamente.

## PRs integrados

| PR | Rama | Commit en main | CI | Review |
|---|---|---|---|---|
| #25 | `feat/navegacion` | `2e8db0a` | Verde | 0 reviews |
| #28 | `feat/26-filtro-productos` | `2e3689d` | Verde | 0 reviews |
| #29 | `feat/27-filtro-carrito` | `7e4871a` | Verde | 0 reviews |

Los tres PR fueron integrados como commit squash. El check
`Formato, análisis y pruebas` quedó en verde en cada uno.

### Excepción de proceso

Los PR #25, #28 y #29 no recibieron reviews/aprobaciones antes de integrarse.
El ruleset de `main` está deshabilitado. Esta es una excepción de proceso que
debe regularizarse si el laboratorio exige la aprobación formal de otro
integrante.

## QA global

- `dart format --output=none --set-exit-if-changed lib test` — 60 archivos,
  0 cambios.
- `flutter analyze` — No issues found!.
- `flutter test` — 137 pruebas aprobadas.
- `git diff --check` — sin errores.
- Navegación: MainShell, tabs, Home → Search, Ver todo → Catálogo y scroll.
- Products: filtros, delete/undo, persistencia, estados y Results → Detail.
- Cart: filtros, delete/undo, persistencia, total completo y Checkout con todos
  los ítems.
- Responsive cubierto por tests donde existe.

## Pendientes

- Regularizar la review/aprobación de los PR si el laboratorio la exige.
- Reactivar/verificar manualmente el ruleset de `main`.
- Completar la consolidación final de `docs/bitacora-ia.md`.

No modificar FASE 6.
