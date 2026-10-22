# FASE 7 — Navegación, filtros y Deshacer

ESTADO: EN DESARROLLO

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
- Pareja 1: pendiente.
- Pareja 2: pendiente.
- Persistencia: pendiente de implementación en las parejas.
- FASE 7 no está completada.

## Pendientes

- PR de navegación con CI y review.
- Crear Issues de parejas.
- Implementar filtros, delete/undo y persistencia.
- QA global.
- Actualizar FASE 7 a COMPLETADA al cerrar.

No modificar FASE 6.
