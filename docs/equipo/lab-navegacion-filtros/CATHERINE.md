# Catherine — Pareja 2: Cart (instrucciones futuras)

ESTADO: TRABAJO POSTERIOR — NO IMPLEMENTAR EN EL BLOQUE A

Rama prevista: `feat/<issue>-filtro-carrito`
Pareja: Catherine + Diego
Módulo principal: `giftify/lib/features/cart/`

## Objetivo

Agregar filtro por categoría, borrado con Deshacer y persistencia local al
carrito, conservando cantidades, totales y Cart → Checkout.

## Responsabilidad individual

Catherine:

- `CartRepository` y persistencia;
- `CartFilterNotifier` / `cartFilterProvider`;
- `cartItemsProvider`;
- integración de `CartScreen`;
- conservar totales y Checkout;
- coordinación de Detail → Cart.

Diego:

- pruebas de filtro, delete/undo y persistencia;
- QA de regresiones;
- apoyo en integración y CI.

## Arquitectura prevista

```text
CartFilter (inmutable, categoría)
        ↓
CartFilterNotifier / cartFilterProvider
        ↓
cartItemsProvider (AsyncNotifier, watch del filtro)
        ↓
CartRepository
        ↓
PersistentCartRepository
        ↓
shared_preferences (productId + quantity)
        ↓
mockProducts (reconstrucción)
```

## Requisitos

- filtro razonable por categoría;
- filtro NO modifica el total general;
- Checkout recibe TODOS los ítems, no el subconjunto filtrado;
- carrito vacío ≠ filtro sin resultados;
- `Dismissible(key: ValueKey(product.id))`;
- borrar primero en repositorio/persistencia;
- fallo => la fila vuelve;
- éxito => SnackBar con `Deshacer`;
- Deshacer restaura el mismo producto, cantidad e id;
- eliminar persiste tras reiniciar;
- deshacer persiste;
- conservar Cart → Checkout;
- no pagos reales ni persistencia remota.

Persistencia mínima:

```text
productId
quantity
```

Al cargar, reconstruir `GiftProduct` desde `mockProducts` por id.

## Lecturas obligatorias

```text
docs/equipo/lab-navegacion-filtros/00_CONTEXTO.md
docs/equipo/mvp/CATHERINE.md
docs/fases/FASE_5_MVP_LOCAL_INTEGRACION_QA.md
docs/bitacoras/CATHERINE.md
docs/bitacoras/DIEGO.md
giftify/lib/features/cart/
giftify/lib/features/products/screens/product_detail_screen.dart
giftify/test/cart_screen_test.dart
giftify/test/cart_checkout_flow_test.dart
giftify/test/checkout_screen_test.dart
```

## Archivos que puede modificar

```text
giftify/lib/features/cart/data/
giftify/lib/features/cart/providers/
giftify/lib/features/cart/screens/cart_screen.dart
giftify/lib/features/cart/screens/checkout_screen.dart (solo si es necesario)
giftify/lib/features/products/screens/product_detail_screen.dart (coordinado con Andrés, solo Detail → Cart)
giftify/test/cart_filter_test.dart
giftify/test/cart_items_provider_test.dart
giftify/test/cart_screen_test.dart
giftify/test/cart_checkout_flow_test.dart
docs/bitacoras/CATHERINE.md
docs/bitacoras/DIEGO.md
```

## Archivos prohibidos

```text
giftify/pubspec.yaml
giftify/lib/main.dart
giftify/lib/app/
giftify/lib/shared/
giftify/lib/features/products/ (salvo coordinación para Detail → Cart)
giftify/lib/features/search/
docs/bitacora-ia.md
```

## Pruebas

- filtro por categoría;
- total general no cambia al filtrar;
- Checkout recibe todos los ítems;
- carrito vacío vs filtro sin resultados;
- Dismissible key id;
- delete falla => fila permanece;
- éxito => SnackBar;
- Deshacer restaura mismo id, producto y cantidad;
- persistencia tras recrear repositorio;
- undo persiste;
- Cart → Checkout y totales;
- responsive 320×640.

## Bitácora

Actualizar la bitácora individual correspondiente. La bitácora IA transversal se
consolida al final.

## Git y PR

```powershell
git switch feat/<issue>-filtro-carrito
git merge origin/main

dart format lib test
flutter analyze
flutter test
git diff --check

git add <archivos propios>
git commit -m "feat: agregar filtro y deshacer en carrito"
git push origin feat/<issue>-filtro-carrito
```

PR con CI verde, review y respuesta a la pregunta de `Dismissible`.

## Criterios de cierre

```text
[ ] Filtro por categoría
[ ] Total general intacto
[ ] Checkout recibe todos los ítems
[ ] Carrito vacío ≠ filtro vacío
[ ] Dismissible key = id
[ ] Delete repository-first
[ ] Fallo restaura fila
[ ] Undo restaura mismos datos
[ ] Persistencia cerrar/reabrir
[ ] Undo persiste
[ ] Cart → Checkout intacto
[ ] Tests y CI verdes
[ ] Bitácora actualizada
[ ] PR con review
```
