# Andrés — cierre de Results y Detail

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `andres`
Rama de tarea: `feat/21-estados-resultados`

## 1. Objetivo

Cerrar `features/products/` para un MVP local estable, incorporando los estados
asíncronos de Resultados sin backend remoto.

## 2. Estado actual que NO debe reimplementarse

BUILD 5A ya existe en `feat/21-estados-resultados`:

```text
giftify/lib/features/products/data/product_repository.dart
giftify/lib/features/products/data/mock_product_repository.dart
giftify/test/product_repository_test.dart
```

Ya están implementados:

- `ProductRepository` con `Future<List<GiftProduct>> fetchProducts()`;
- `MockProductRepository` con catálogo por defecto, lista alternativa, lista
  vacía, error configurable y latencia simulada;
- pruebas unitarias del repositorio;
- filtrado y priorización en `product_filters.dart`;
- `ProductDetailScreen` estable, con 12 pruebas;
- `ProductResultsScreen` con datos y estado vacío básico;
- 5 pruebas actuales de Results.

No volver a crear el repositorio ni el mock.

## 3. Trabajo requerido

### P0

1. `ProductResultsScreen` debe dejar de depender directamente de
   `mockProducts`.
2. Debe recibir un `ProductRepository` opcional y usar
   `MockProductRepository` por defecto.
3. Mantener `GiftSearchCriteria? criteria`.
4. Implementar un flujo asíncrono persistente.
5. Implementar loading, error humano, `Reintentar`, empty con
   `Modificar búsqueda`, y data.
6. Crear un fake repository.
7. Adaptar los 5 tests actuales.
8. Agregar widget tests de los cuatro estados y del reintento.

### P1

- Loading, error y empty en 320×640.
- Resumen de criterios sin overflow.
- Mantener Results → Detail.

### Fuera de alcance

- Backend remoto.
- Cambios en `GiftProduct`.
- Cambios en `app_router.dart`.
- Cambios en Search, Cart o Checkout.
- Cambios funcionales en Detail.

## 4. Flujo funcional y arquitectura

```text
GiftSearchScreen
      ↓
GiftSearchCriteria
      ↓
ProductResultsScreen
      ↓
ProductRepository
      ↓
MockProductRepository
      ↓
mockProducts
```

Dentro de la pantalla:

```text
initState
  ↓
_loadResults()
  ↓
repository.fetchProducts()
  ↓
filterAndPrioritizeProducts(products, criteria)
  ↓
FutureBuilder<List<GiftProduct>>
  ↓
loading / error / empty / data
```

`fetchProducts()` **no debe ejecutarse directamente dentro de `build`**.

## 5. Archivos que debe leer

```text
docs/equipo/00_REGLAS_COMUNES.md
docs/equipo/mvp/00_CONTEXTO_MVP_LOCAL.md
docs/equipo/21_ESTADOS_RESULTADOS.md
docs/bitacoras/ANDRES.md
giftify/lib/features/products/data/product_repository.dart
giftify/lib/features/products/data/mock_product_repository.dart
giftify/lib/features/products/screens/product_results_screen.dart
giftify/lib/features/products/screens/product_detail_screen.dart
giftify/lib/features/products/utils/product_filters.dart
giftify/test/product_results_screen_test.dart
giftify/test/product_repository_test.dart
giftify/test/product_detail_screen_test.dart
```

## 6. Archivos que puede modificar

```text
giftify/lib/features/products/screens/product_results_screen.dart
giftify/lib/features/products/data/
giftify/test/product_results_screen_test.dart
giftify/test/product_repository_test.dart
giftify/test/helpers/fake_product_repository.dart
docs/bitacoras/ANDRES.md
```

## 7. Archivos que NO debe modificar

```text
giftify/lib/shared/models/
giftify/lib/app/app_router.dart
giftify/lib/features/search/
giftify/lib/features/cart/
giftify/lib/features/products/screens/product_detail_screen.dart
giftify/pubspec.yaml
giftify/lib/core/backend/
```

Motivo: modelos y router son contratos compartidos; Detail ya está estable; el
resto pertenece a otros módulos.

Si necesita inyectar el repositorio desde el router, **detenerse y coordinar**.
La ruta recomendada es un parámetro opcional con `MockProductRepository` por
defecto.

## 8. Implementación esperada

1. Convertir `ProductResultsScreen` en `StatefulWidget`.
2. Agregar:

```dart
final GiftSearchCriteria? criteria;
final ProductRepository? repository;
```

3. En `initState`:

```dart
late final ProductRepository _repository;
late Future<List<GiftProduct>> _resultsFuture;

_repository = widget.repository ?? MockProductRepository();
_resultsFuture = _loadResults();
```

4. Implementar:

```dart
Future<List<GiftProduct>> _loadResults() async {
  final products = await _repository.fetchProducts();
  return filterAndPrioritizeProducts(products, widget.criteria);
}
```

5. `FutureBuilder<List<GiftProduct>>` debe decidir:

```text
ConnectionState.waiting -> loading
snapshot.hasError       -> error
data vacía              -> empty
data con elementos      -> lista
```

6. Loading:

```text
CircularProgressIndicator
Cargando…
```

7. Error:

```text
No pudimos cargar los productos.
Reintentar
```

8. `Reintentar`:

```dart
setState(() {
  _resultsFuture = _loadResults();
});
```

Debe crear un **nuevo Future** y una **nueva llamada** a `fetchProducts()`.
No debe existir reintento automático.

9. Empty:

```text
No encontramos productos.
Modificar búsqueda
```

Acción recomendada:

- `Navigator.pop(context)` si puede regresar a Search;
- si no puede, ir a `AppRoutes.search` con un fallback que no modifique
  `app_router.dart`.

10. Data: conservar `ProductCard`, resumen de criterios y navegación a
    `AppRoutes.productDetail`.

## 9. Fake repository

Crear:

```text
giftify/test/helpers/fake_product_repository.dart
```

Debe soportar de forma determinista:

```text
success
empty
fail
failOnceThenSuccess
```

Debe exponer un contador `calls` para comprobar que `Reintentar` ejecuta una
nueva consulta. No usar `Future.delayed` largo dentro de los tests salvo para el
caso de loading.

## 10. Casos que debe cubrir

- Loading visible antes de completar.
- Error sin crash.
- Mensaje humano de error.
- `Reintentar` visible.
- `Reintentar` incrementa `calls`.
- `failOnceThenSuccess` muestra datos después.
- Empty con mensaje.
- `Modificar búsqueda` navega o regresa a Search.
- Data con `ProductCard`.
- Results → Detail con `GiftProduct`.
- 320×640 sin overflow.

## 11. Pruebas

Tests obligatorios:

```text
[ ] loading
[ ] error sin crash
[ ] mensaje humano
[ ] Reintentar visible
[ ] Reintentar incrementa calls
[ ] failOnceThenSuccess muestra datos
[ ] empty
[ ] Modificar búsqueda
[ ] data
[ ] Results → Detail
[ ] adaptar los 5 tests actuales
```

Los tests actuales deben adaptarse, no eliminarse.

## 12. Validación visual

- Loading, error y empty a 320×640.
- Data con resumen de criterios.
- Sin overflow en textos largos.

## 13. Validación técnica

Desde `giftify/`:

```powershell
dart format lib test
flutter analyze
flutter test
```

Desde la raíz:

```powershell
git diff --check
```

## 14. Registro en bitácora

Actualizar `docs/bitacoras/ANDRES.md` con:

- integración del repositorio;
- estados implementados;
- fake y pruebas;
- resultados;
- pendientes.

Andrés es el único que conserva la entrada de Issue #21 en
`docs/bitacora-ia.md`. No consolidar aún las entradas de los demás.

## 15. Git

```powershell
git fetch --all --prune
git switch feat/21-estados-resultados
git pull --ff-only origin feat/21-estados-resultados
git merge origin/main

# trabajo y validación

git status
git diff --stat
git add giftify/lib/features/products/screens/product_results_screen.dart
git add giftify/lib/features/products/data/
git add giftify/test/product_results_screen_test.dart
git add giftify/test/product_repository_test.dart
git add giftify/test/helpers/fake_product_repository.dart
git add docs/bitacoras/ANDRES.md
git diff --cached --name-status
git diff --cached --check
git commit -m "feat: implementar estados asincronos en resultados"
git push origin feat/21-estados-resultados
```

El PR final de Issue #21 se abre después de validar el desarrollo local. No
hacer merge todavía.

## 16. Evidencias

- Salida de `flutter analyze`.
- Total de tests y `All tests passed`.
- `git diff --check` limpio.
- `git status` final.
- SHA del commit.
- Capturas de:
  - loading;
  - error + `Reintentar`;
  - empty + `Modificar búsqueda`;
  - data.

## 17. Criterios de cierre

```text
[ ] Results usa ProductRepository
[ ] Ya no importa mockProducts directamente
[ ] Loading visible
[ ] Error con mensaje humano
[ ] Reintentar ejecuta nueva consulta
[ ] Empty con Modificar búsqueda
[ ] Data con lista y navegación
[ ] Fake repository con success/empty/fail/failOnceThenSuccess
[ ] Error no provoca crash
[ ] Reintento exitoso muestra datos
[ ] 5 tests actuales adaptados
[ ] Responsive 320×640
[ ] Detail sigue estable
[ ] dart format lib test correcto
[ ] flutter analyze sin issues
[ ] flutter test verde
[ ] git diff --check limpio
[ ] Bitácora actualizada
[ ] Commit y push a feat/21-estados-resultados
```

## 18. Prohibiciones

- No backend remoto, Supabase, Firebase, API REST, SQLite ni Riverpod.
- No cambiar `GiftProduct`.
- No tocar `app_router.dart` sin coordinación.
- No modificar Search, Cart o Checkout.
- No modificar Detail funcionalmente.
- No agregar dependencias.
- No cerrar Issue #21 antes de integrar el PR.
- No marcar FASE 5 como terminada en este PR.
