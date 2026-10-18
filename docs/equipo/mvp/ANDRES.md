# Andrés — cierre de Results y Detail

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `andres`
Rama de tarea: `feat/21-estados-resultados`

## 1. Objetivo

Cerrar `features/products/` para un MVP local estable, incorporando los estados
asíncronos de Resultados sin backend remoto.

## 2. Trabajo actual: Issue #21

```text
Issue: #21
Rama: feat/21-estados-resultados
Pantalla: ProductResultsScreen
```

El trabajo ya comenzó en esa rama. BUILD 5A agregó:

```text
ProductResultsScreen
        ↓
ProductRepository
        ↓
MockProductRepository
        ↓
mockProducts
```

Archivos ya creados:

```text
giftify/lib/features/products/data/product_repository.dart
giftify/lib/features/products/data/mock_product_repository.dart
giftify/test/product_repository_test.dart
```

`ProductRepository` solo expone:

```dart
Future<List<GiftProduct>> fetchProducts();
```

`MockProductRepository` permite catálogo por defecto, lista alternativa, lista
vacía, error configurable y latencia simulada.

## 3. Estado real pendiente

`ProductResultsScreen` todavía es síncrona:

- usa `mockProducts` directamente;
- no tiene loading;
- no tiene error;
- el estado vacío no tiene acción;
- no tiene `Reintentar`.

`ProductDetailScreen` ya está estable y tiene 12 pruebas de widget. No debe
romperse.

## 4. Tareas pertinentes

1. Integrar `ProductRepository` en `ProductResultsScreen`.
2. Conservar el constructor `ProductResultsScreen({criteria})` y permitir
   inyectar el repositorio para pruebas.
3. Convertir la pantalla a `StatefulWidget` con `FutureBuilder` o equivalente
   simple.
4. Implementar:
   - loading: `Cargando…`;
   - error: `No pudimos cargar los productos.` + `Reintentar`;
   - empty: `No encontramos productos.` + `Modificar búsqueda`;
   - data: lista de `ProductCard`.
5. `Reintentar` debe ejecutar una nueva consulta.
6. El filtrado debe ejecutarse dentro del futuro, usando
   `filterAndPrioritizeProducts`, para capturar también errores de filtrado.
7. Crear un fake configurable para widget tests.
8. Actualizar los 5 tests actuales de Results al comportamiento asíncrono.
9. Mantener Results → Detail y la navegación con `GiftProduct`.
10. Mantener Detail sin cambios funcionales; solo corregir si una prueba revela
    un defecto real.

## 5. Lecturas obligatorias

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

## 6. Archivos permitidos

```text
giftify/lib/features/products/data/product_repository.dart
giftify/lib/features/products/data/mock_product_repository.dart
giftify/lib/features/products/screens/product_results_screen.dart
giftify/test/product_results_screen_test.dart
giftify/test/product_repository_test.dart
giftify/test/helpers/fake_product_repository.dart
docs/bitacoras/ANDRES.md
```

## 7. Archivos compartidos o restringidos

Requieren coordinación:

```text
giftify/lib/app/app_router.dart
giftify/lib/shared/models/gift_product.dart
```

No modificar sin coordinación:

```text
giftify/lib/features/search/
giftify/lib/features/cart/
giftify/lib/features/products/screens/product_detail_screen.dart
```

No cambiar `GiftProduct` en esta tarea. No añadir backend, HTTP, SQLite ni
Riverpod.

## 8. Criterios de aceptación

```text
[ ] ProductResultsScreen consume ProductRepository
[ ] Ya no importa mockProducts directamente
[ ] Loading visible
[ ] Error con mensaje humano
[ ] Reintentar ejecuta una nueva consulta
[ ] Empty con "No encontramos productos." y "Modificar búsqueda"
[ ] Data muestra la lista y navega al detalle
[ ] Un fake permite success, empty, error y failOnceThenSuccess
[ ] La prueba de error no provoca crash
[ ] El reintento exitoso muestra datos
[ ] No hay overflow a 320×640
[ ] Detail sigue estable
[ ] dart format, flutter analyze y flutter test pasan
```

## 9. Pruebas necesarias

- loading;
- error sin crash;
- botón `Reintentar`;
- reintento exitoso con contador de llamadas;
- vacío con acción;
- datos;
- navegación al detalle;
- responsive.

Los 5 tests actuales de Results deben adaptarse, no eliminarse.

## 10. Bitácora

Actualizar `docs/bitacoras/ANDRES.md` con el trabajo de BUILD 5B. Registrar IA
en `docs/bitacora-ia.md` si aplica.

## 11. Resultado esperado del PR

PR desde `feat/21-estados-resultados` hacia `main`, con referencia al Issue #21,
sin backend remoto y con el check `Formato, análisis y pruebas` en verde. No
cerrar el Issue hasta integrar el PR.

FASE 5 se documentará al cerrar integración y QA; no marcarla como terminada en
este PR.
