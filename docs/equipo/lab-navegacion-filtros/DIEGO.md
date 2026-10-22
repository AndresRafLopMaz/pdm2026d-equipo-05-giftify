# Diego — Pareja 2: Cart (instrucciones futuras)

ESTADO: TRABAJO POSTERIOR — NO IMPLEMENTAR EN EL BLOQUE A

Rama prevista: `feat/<issue>-filtro-carrito`
Pareja: Diego + Catherine
Módulo de apoyo: pruebas y QA de `features/cart/`

## Objetivo

Asegurar con pruebas que el filtro, delete/undo y la persistencia del carrito no
rompen cantidades, totales ni Cart → Checkout.

## Responsabilidad individual

Diego:

- pruebas de filtro y de total general;
- pruebas de delete/undo y persistencia;
- QA de regresiones de Cart y Checkout;
- apoyo en la integración y en el CI.

Catherine:

- `CartRepository`;
- providers y persistencia;
- integración de `CartScreen`;
- coordinación de Detail → Cart.

## Arquitectura

```text
CartFilter
        ↓
CartFilterNotifier / cartFilterProvider
        ↓
cartItemsProvider (watch del filtro)
        ↓
CartRepository
        ↓
shared_preferences (productId + quantity)
        ↓
mockProducts
```

## Requisitos

- filtro por categoría;
- el total se calcula con todos los ítems, no con la lista filtrada;
- Checkout recibe todos los ítems;
- carrito vacío ≠ filtro sin resultados;
- `Dismissible(key: ValueKey(product.id))`;
- borrar primero en repositorio/persistencia;
- fallo => fila permanece;
- éxito => SnackBar con `Deshacer`;
- Deshacer restaura mismo id, producto y cantidad;
- persistencia tras cerrar/reabrir;
- undo persiste;
- no editar registros.

## Lecturas obligatorias

```text
docs/equipo/lab-navegacion-filtros/00_CONTEXTO.md
docs/equipo/lab-navegacion-filtros/CATHERINE.md
docs/fases/FASE_5_MVP_LOCAL_INTEGRACION_QA.md
docs/bitacoras/DIEGO.md
docs/bitacoras/CATHERINE.md
giftify/lib/features/cart/
giftify/lib/shared/models/cart_item.dart
giftify/test/cart_screen_test.dart
giftify/test/cart_checkout_flow_test.dart
```

## Archivos que puede modificar

```text
giftify/test/cart_filter_test.dart
giftify/test/cart_items_provider_test.dart
giftify/test/cart_screen_test.dart
giftify/test/cart_checkout_flow_test.dart
docs/bitacoras/DIEGO.md
```

## Archivos prohibidos

```text
giftify/lib/main.dart
giftify/lib/app/
giftify/lib/shared/
giftify/pubspec.yaml
giftify/lib/features/products/ (salvo coordinación)
giftify/lib/features/search/
docs/bitacora-ia.md
```

## Pruebas

- filtro y lista filtrada;
- total general sin cambios;
- Checkout con todos los ítems;
- carrito vacío vs filtro vacío;
- delete falla => fila permanece;
- delete éxito => SnackBar;
- undo restaura mismos datos/id;
- persistencia tras recrear repositorio;
- undo persiste;
- responsive 320×640.

## Bitácora

Actualizar `docs/bitacoras/DIEGO.md`. La bitácora IA transversal se consolida al
final.

## Git y PR

```powershell
git switch feat/<issue>-filtro-carrito
git merge origin/main

dart format lib test
flutter analyze
flutter test
git diff --check

git add <archivos propios>
git commit -m "test: cubrir filtros y deshacer en carrito"
git push origin feat/<issue>-filtro-carrito
```

PR con CI verde, review y respuesta a la pregunta de `Dismissible`.

## Criterios de cierre

```text
[ ] Filtro probado
[ ] Total general intacto
[ ] Checkout con todos los ítems
[ ] Delete/undo probados
[ ] Persistencia probada
[ ] Carrito vacío ≠ filtro vacío
[ ] Tests y CI verdes
[ ] Bitácora actualizada
[ ] PR con review
```
