# Laboratorio de navegación, filtros y Deshacer — Contexto

ESTADO: TRABAJO ACTUAL — NAVEGACIÓN BASE COMPLETADA

## 1. Objetivo

Cerrar un nuevo laboratorio de Giftify con:

- navegación principal mediante provider/Notifier e `IndexedStack`;
- filtros reactivos sobre listados;
- borrado con repositorio primero y SnackBar con Deshacer;
- persistencia local de borrados/restauración;
- PR con CI verde y review.

El MVP sigue siendo completamente local. No hay backend remoto, SQLite ni
servicios externos.

## 2. Arquitectura aprobada

```text
Flutter + flutter_riverpod 3.x
        ↓
ProviderScope
        ↓
MainShell + IndexedStack
        ↓
AppTabNotifier / appTabProvider
```

Dependencias comunes añadidas en el Bloque A:

```text
flutter_riverpod
shared_preferences
```

No se agregan otras dependencias sin aprobación.

## 3. Navegación

### Actual

```text
Register → AppRoutes.home → MainShell
```

`MainShell` contiene:

```text
Inicio       → HomeScreen
Buscar       → GiftSearchScreen
Catálogo     → ProductResultsScreen(criteria: null)
Próximamente → ComingSoonScreen
```

`AppRouter` se conserva para:

```text
Detail
Cart
Checkout
```

Search y Results también conservan sus rutas para flujos que las necesiten.

### Navegación por provider

- `AppTabNotifier` cambia la pestaña con `select`.
- `MainShell` observa `appTabProvider`.
- Home usa el provider para CTA y “Ver todo”.
- No se usan callbacks de navegación por constructor.

`IndexedStack` mantiene las tabs montadas y conserva scroll/estado.

## 4. Trabajo actual vs trabajo posterior

### TRABAJO ACTUAL: navegación

- `ProviderScope`;
- `AppTab`, `AppTabNotifier`, `appTabProvider`;
- `MainShell` e `IndexedStack`;
- `ComingSoonScreen`;
- Home con navegación por provider;
- `AppRouter.home` apunta a `MainShell`;
- tests de navegación y scroll.

### TRABAJO POSTERIOR: parejas

- Pareja 1: Andrés + Brayan → Products.
- Pareja 2: Catherine + Diego → Cart.
- Filtros, delete/undo y persistencia con `shared_preferences`.
- No se implementan en el Bloque A.

## 5. Persistencia

`shared_preferences` será la persistencia local:

- Products: IDs eliminados o tombstones; al restaurar se recupera el producto
  desde `mockProducts` por id.
- Cart: `productId` + `quantity`; se reconstruye `GiftProduct` desde
  `mockProducts`.

Reglas:

- La prueba de cerrar/reabrir es obligatoria.
- No SQLite.
- No backend remoto.
- No secretos.

## 6. Filtros y providers

Riverpod 3 permite `Notifier`, `AsyncNotifier` y providers reactivos.

Regla importante: desactivar el retry automático de Riverpod 3 en los providers
asíncronos para conservar el botón manual `Reintentar`:

```dart
retry: (retryCount, error) => null
```

Cada pareja implementará su filtro como objeto inmutable dentro de un Notifier.
El provider del listado debe hacer `ref.watch` del filtro y volver a consultar al
cambiarlo.

## 7. Delete/Undo

Requisitos:

- `Dismissible` con `key: ValueKey(id)`, nunca índice;
- borrar primero en repositorio/persistencia;
- si falla, la fila reaparece;
- éxito muestra SnackBar con `Deshacer`;
- Deshacer restaura el mismo objeto y el mismo id;
- no se implementa edición.

Pregunta obligatoria en cada PR de pareja:

> ¿Por qué la key del Dismissible debe ser el id y no el índice, y qué pasaría
> si se borrara la fila 2 de 5?

Respuesta base:

> Porque al eliminar cambian los índices. Si se borra la fila 2 de 5, las filas
> 3–5 pasan a índices 1–3; una key por índice haría que Flutter reutilice el
> estado/animación de otra fila y podría eliminar o restaurar el elemento
> equivocado. El id es estable.

## 8. Git y GitHub

- `main` está protegida.
- Todo entra por PR.
- CI obligatorio: `Formato, análisis y pruebas`.
- Review de otra pareja/Code Owner.
- Squash and merge.
- No push directo a `main`.
- Las ramas `feat/*` no están bloqueadas.

## 9. Archivos coordinados/protegidos

```text
giftify/pubspec.yaml
giftify/lib/main.dart
giftify/lib/app/
giftify/lib/shared/
docs/bitacora-ia.md
```

Después de integrar navegación, las parejas no deben modificar `pubspec.yaml`
salvo necesidad aprobada. Todas las dependencias comunes ya quedaron listas.

## 10. Orden de trabajo

```text
1. Navegación (Bloque A)
2. PR de navegación + CI + review
3. Actualizar main
4. Crear ramas de parejas desde main
5. Pareja 1 (Products)
6. Pareja 2 (Cart)
7. QA global
8. FASE 7
```

No se implementan filtros ni delete/undo en el Bloque A.
