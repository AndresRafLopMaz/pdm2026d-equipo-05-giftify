# Brayan — Pareja 1: Products (instrucciones futuras)

ESTADO: TRABAJO POSTERIOR — NO IMPLEMENTAR EN EL BLOQUE A

Rama prevista: `feat/<issue>-filtro-productos`
Pareja: Brayan + Andrés
Módulos de apoyo: `features/search/` y pruebas de Products

## Objetivo

Aportar el filtro visible, las pruebas de interacción y la verificación del
contrato Search → Results, sin romper el repositorio ni los estados existentes.

## Responsabilidad individual

Brayan:

- barra/controles de filtro;
- pruebas de cambio de filtro, empty y responsive;
- verificación de que `GiftSearchCriteria` sigue llegando a Results;
- QA de navegación Search → Results.

Andrés:

- repositorio, persistencia y provider de productos;
- delete/restore;
- integración de la pantalla.

## Arquitectura

```text
ProductFilter
        ↓
ProductFilterNotifier / productFilterProvider
        ↓
productsProvider (watch del filtro)
        ↓
ProductRepository
        ↓
MockProductRepository
```

## Requisitos

- filtro inmutable con categoría y disponibilidad;
- controles de filtro visibles en Catálogo;
- cambiar filtro actualiza la lista automáticamente;
- sin botón Recargar;
- empty por filtro con acción de limpiar;
- loading/error/retry/empty/data conservados;
- no modificar `ProductResultsScreen` fuera del filtro/lista sin coordinar con
  Andrés;
- Dismissible y delete/undo son responsabilidad compartida; Brayan revisa que
  la key sea `product.id`;
- no editar registros.

## Lecturas obligatorias

```text
docs/equipo/lab-navegacion-filtros/00_CONTEXTO.md
docs/equipo/lab-navegacion-filtros/ANDRES.md
docs/fases/FASE_5_MVP_LOCAL_INTEGRACION_QA.md
docs/bitacoras/BRAYAN.md
giftify/lib/features/products/screens/product_results_screen.dart
giftify/lib/features/products/utils/product_filters.dart
giftify/lib/features/search/screens/gift_search_screen.dart
giftify/lib/shared/models/gift_search_criteria.dart
giftify/test/gift_search_screen_test.dart
giftify/test/product_results_screen_test.dart
```

## Archivos que puede modificar

```text
giftify/lib/features/products/widgets/
giftify/lib/features/products/screens/product_results_screen.dart (coordinado)
giftify/test/product_filter_test.dart
giftify/test/product_results_screen_test.dart
docs/bitacoras/BRAYAN.md
```

## Archivos prohibidos

```text
giftify/pubspec.yaml
giftify/lib/main.dart
giftify/lib/app/
giftify/lib/shared/
giftify/lib/features/search/ (salvo coordinación)
giftify/lib/features/cart/
docs/bitacora-ia.md
```

## Pruebas

- cambiar filtro actualiza la lista;
- se incrementa la consulta del fake;
- no existe botón Recargar;
- empty por filtro;
- filtro + criterios de Search;
- Dismissible key id;
- delete/undo;
- responsive;
- Search → Results conserva `RouteSettings.arguments`.

## Bitácora

Actualizar `docs/bitacoras/BRAYAN.md` con el trabajo real. La bitácora
transversal se consolida al integrar.

## Git y PR

```powershell
git switch feat/<issue>-filtro-productos
git merge origin/main

dart format lib test
flutter analyze
flutter test
git diff --check

git add <archivos propios>
git commit -m "test: cubrir filtros y deshacer en productos"
git push origin feat/<issue>-filtro-productos
```

PR con CI verde, review y respuesta a la pregunta de `Dismissible`.

## Criterios de cierre

```text
[ ] Filtro visible y reactivo
[ ] Sin botón Recargar
[ ] Empty por filtro
[ ] Loading/error/retry/data
[ ] Dismissible key = id
[ ] Delete/undo probados
[ ] Search → Results intacto
[ ] Tests y CI verdes
[ ] Bitácora actualizada
[ ] PR con review
```
