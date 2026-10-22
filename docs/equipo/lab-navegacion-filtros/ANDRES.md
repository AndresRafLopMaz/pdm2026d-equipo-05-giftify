# Andrés — Pareja 1: Products (instrucciones futuras)

ESTADO: TRABAJO POSTERIOR — NO IMPLEMENTAR EN EL BLOQUE A

Rama prevista: `feat/<issue>-filtro-productos`
Pareja: Andrés + Brayan
Módulo principal: `giftify/lib/features/products/`

## Objetivo

Agregar filtro reactivo, borrado con Deshacer y persistencia local a la lista de
resultados de productos, conservando loading/error/retry/empty/data y la
navegación Results → Detail.

## Responsabilidad individual

Andrés:

- `ProductRepository` y `MockProductRepository`;
- persistencia de productos eliminados;
- `productsProvider` / `ProductsNotifier`;
- delete/restore en repositorio y provider;
- integración de la pantalla;
- revisión de estados y navegación.

Brayan:

- barra/controles de filtro;
- pruebas de cambio de filtro y empty;
- verificación de `GiftSearchCriteria` y navegación;
- QA de la integración Search → Results.

## Arquitectura prevista

```text
ProductFilter (inmutable)
        ↓
ProductFilterNotifier / productFilterProvider
        ↓
productsProvider (AsyncNotifier, watch del filtro)
        ↓
ProductRepository
        ↓
MockProductRepository
        ↓
mockProducts
```

Persistencia:

```text
SharedPreferencesDeletedProductsStore
        ↓
IDs eliminados
        ↓
filtrado al cargar
```

## Requisitos

- `ProductFilter` inmutable con al menos:
  - `category`;
  - `availability`.
- `ProductFilterNotifier` con `setCategory`, `setAvailability`, `clear`.
- `productsProvider` hace `ref.watch(productFilterProvider)`.
- Cambiar filtro vuelve a consultar automáticamente.
- No existe botón “Recargar”.
- Conservar loading, error, `Reintentar`, empty y data.
- Empty por filtro ofrece limpiar filtros; empty por criterios ofrece
  `Modificar búsqueda`.
- `Dismissible(key: ValueKey(product.id))`.
- Borrar primero en repositorio/persistencia.
- Fallo de borrado: la fila vuelve.
- Éxito: SnackBar con `Deshacer`.
- Deshacer restaura el producto idéntico y el mismo id.
- El producto eliminado persiste al cerrar/reabrir.
- Deshacer también persiste.
- No implementar edición.

Riverpod 3: desactivar retry automático en providers asíncronos.

## Lecturas obligatorias

```text
docs/equipo/00_REGLAS_COMUNES.md
docs/equipo/lab-navegacion-filtros/00_CONTEXTO.md
docs/equipo/mvp/00_CONTEXTO_MVP_LOCAL.md
docs/fases/FASE_5_MVP_LOCAL_INTEGRACION_QA.md
docs/bitacoras/ANDRES.md
docs/bitacoras/BRAYAN.md
giftify/lib/features/products/
giftify/lib/shared/data/mock_products.dart
giftify/lib/shared/models/gift_product.dart
giftify/lib/app/app_tab_notifier.dart
giftify/lib/app/main_shell.dart
giftify/test/product_results_screen_test.dart
giftify/test/helpers/fake_product_repository.dart
```

## Archivos que puede modificar

```text
giftify/lib/features/products/data/
giftify/lib/features/products/providers/
giftify/lib/features/products/screens/product_results_screen.dart
giftify/lib/features/products/widgets/
giftify/test/product_filter_test.dart
giftify/test/products_provider_test.dart
giftify/test/product_results_screen_test.dart
giftify/test/helpers/fake_product_repository.dart
docs/bitacoras/ANDRES.md
docs/bitacoras/BRAYAN.md
```

## Archivos prohibidos

```text
giftify/pubspec.yaml
giftify/lib/main.dart
giftify/lib/app/
giftify/lib/shared/
giftify/lib/features/search/
giftify/lib/features/cart/
giftify/lib/features/products/screens/product_detail_screen.dart
docs/bitacora-ia.md
```

Si se necesita un archivo compartido, detenerse y coordinar.

## Pruebas

- filtro cambia lista y vuelve a consultar;
- sin botón Recargar;
- empty por filtro;
- Dismissible con id;
- delete falla => fila permanece;
- delete éxito => SnackBar;
- Deshacer restaura mismo id y datos;
- persistencia tras recrear repositorio (SharedPreferences mock);
- undo persiste;
- loading/error/retry/data siguen funcionando;
- Results → Detail;
- responsive 320×640.

## Bitácora

Actualizar `docs/bitacoras/ANDRES.md` y `docs/bitacoras/BRAYAN.md` con
responsabilidades reales. No tocar `docs/bitacora-ia.md` durante el trabajo;
se consolida al integrar.

## Git y PR

```powershell
git fetch --all --prune
git switch feat/<issue>-filtro-productos
git merge origin/main
dart format lib test
flutter analyze
flutter test
git diff --check
git add <archivos propios>
git commit -m "feat: agregar filtro y deshacer en productos"
git push origin feat/<issue>-filtro-productos
```

PR hacia `main` con CI verde y review. Responder la pregunta de `Dismissible`.

## Criterios de cierre

```text
[ ] Filtro inmutable y provider reactivo
[ ] Cambio de filtro reconsulta
[ ] Loading/error/retry/empty/data
[ ] Dismissible key = id
[ ] Delete repository-first
[ ] Fallo restaura fila
[ ] Undo restaura mismo id/datos
[ ] Persistencia cerrar/reabrir
[ ] Undo persiste
[ ] Tests y CI verdes
[ ] Bitácoras actualizadas
[ ] PR con review
```
