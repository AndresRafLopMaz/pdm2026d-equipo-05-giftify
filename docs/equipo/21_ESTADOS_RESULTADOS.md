# 21 — Estados asíncronos en resultados de productos

## 1. Objetivo

Preparar `ProductResultsScreen` para consumir productos mediante una frontera
`ProductRepository`, manteniendo el MVP completamente local, y representar de
forma explícita los estados:

- carga;
- error con acción de reintento;
- vacío con acción útil;
- datos.

El Issue #21 existe únicamente como trazabilidad. La guía operativa es este
documento.

## 2. Contexto del MVP local

Giftify es un MVP Flutter con siete pantallas integradas. Los productos siguen
viniendo de `giftify/lib/shared/data/mock_products.dart`.

Flujo actual:

```text
ProductResultsScreen
        ↓
ProductRepository
        ↓
MockProductRepository
        ↓
mockProducts
```

No se implementa backend remoto en esta tarea. La planificación futura vive en
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.

## 3. Rama, Issue y responsables

- Rama de trabajo: `feat/21-estados-resultados`.
- Issue de referencia: **#21**.
- Responsables principales: **Andrés + Brayan**.
- Andrés: módulo `features/products/` y repositorio.
- Brayan: contrato Search → Results, validación de criterios y acción
  “Modificar búsqueda”.
- No se trabaja directamente sobre `main`.

## 4. Lecturas obligatorias antes de tocar código

```text
docs/equipo/00_REGLAS_COMUNES.md
docs/equipo/ANDRES.md
docs/equipo/BRAYAN.md
docs/equipo/INTEGRACION_Y_QA.md
docs/bitacoras/ANDRES.md
docs/bitacoras/BRAYAN.md
docs/bitacora-ia.md
giftify/lib/features/products/screens/product_results_screen.dart
giftify/lib/features/products/utils/product_filters.dart
giftify/lib/shared/models/gift_product.dart
giftify/lib/shared/models/gift_search_criteria.dart
giftify/lib/shared/data/mock_products.dart
giftify/lib/app/app_router.dart
giftify/test/product_results_screen_test.dart
giftify/test/product_filters_test.dart
```

## 5. Arquitectura de la tarea

```text
ProductResultsScreen
        ↓
FutureBuilder<List<GiftProduct>>
        ↓
ProductRepository (interfaz)
        ↓
MockProductRepository
        ↓
mockProducts
```

Responsabilidades:

- `ProductResultsScreen`: renderiza estados, mantiene el `Future`, ejecuta el
  reintento y navega al detalle. No conoce HTTP, JSON ni SQL.
- `FutureBuilder`: expone carga, error, vacío y datos.
- `ProductRepository`: contrato `fetchProducts()`.
- `MockProductRepository`: latencia simulada, datos locales y error opcional.
- `filterAndPrioritizeProducts`: se conserva como lógica local y pura.

## 6. Contrato del repositorio

```dart
abstract class ProductRepository {
  Future<List<GiftProduct>> fetchProducts();
}
```

Reglas:

- No agregar criterios al contrato en esta tarea.
- No agregar dependencias HTTP.
- No agregar SQLite.
- No agregar Riverpod.

## 7. `MockProductRepository`

Debe:

- implementar `ProductRepository`;
- usar `mockProducts` por defecto;
- aceptar opcionalmente una lista de productos para pruebas;
- permitir una lista vacía;
- permitir lanzar un error configurable;
- simular latencia con `Future.delayed`;
- devolver `Future<List<GiftProduct>>`;
- no conocer widgets, HTTP ni SQLite.

Ubicación:

```text
giftify/lib/features/products/data/mock_product_repository.dart
```

## 8. Estados de la pantalla

### Loading

```text
Cargando…
```

Con indicador visible. No mostrar la lista mientras se espera.

### Error

```text
No pudimos cargar los productos.
Reintentar
```

El botón debe ejecutar una nueva consulta, no reutilizar el futuro fallido.

### Empty

```text
No encontramos productos.
Modificar búsqueda
```

Acción recomendada:

- volver a Search con `pop` si es posible, conservando el formulario;
- si no es posible, usar `pushReplacementNamed(AppRoutes.search)`.

### Data

Lista normal de `ProductCard`, conservando el resumen de criterios y la
navegación a `AppRoutes.productDetail`.

## 9. Reintento

Implementación esperada:

```dart
late Future<List<GiftProduct>> _resultsFuture;

Future<List<GiftProduct>> _loadResults() async {
  final products = await _repository.fetchProducts();
  return filterAndPrioritizeProducts(products, widget.criteria);
}

void _retry() {
  setState(() {
    _resultsFuture = _loadResults();
  });
}
```

El filtrado debe ocurrir dentro del futuro para que el `FutureBuilder` también
capture errores de filtrado.

## 10. Pruebas con fake repository

Crear un fake configurable en `giftify/test/helpers/fake_product_repository.dart`:

```text
FakeProductRepository.success(mockProducts)
FakeProductRepository.empty()
FakeProductRepository.error()
FakeProductRepository.failOnceThenSuccess(mockProducts)
```

Debe exponer un contador `calls` para demostrar que `Reintentar` ejecuta una
nueva consulta.

Cobertura mínima:

```text
[ ] loading visible antes de completar el futuro
[ ] error muestra mensaje humano
[ ] error no provoca crash
[ ] existe y funciona el botón Reintentar
[ ] Reintentar incrementa calls
[ ] tras un fallo y un reintento exitoso aparecen datos
[ ] vacío muestra "No encontramos productos." y "Modificar búsqueda"
[ ] datos muestra ProductCard y permite navegar al detalle
[ ] no hay overflow en pantalla pequeña
```

Adaptar los tests existentes de `product_results_screen_test.dart` al nuevo
estado asíncrono.

## 11. Validación obligatoria

Desde `giftify/`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

El check del CI debe seguir llamándose `Formato, análisis y pruebas`.

## 12. Bitácoras

Actualizar:

```text
docs/bitacoras/ANDRES.md
docs/bitacoras/BRAYAN.md
docs/bitacora-ia.md
```

Registrar solo lo realizado: repositorio, estados, retry, pruebas y decisiones.
No declarar backend, SQLite ni Riverpod.

## 13. Commits

Máximo aproximado: **3 commits significativos**.

```text
feat: agregar repositorio local de productos
feat: implementar estados de carga error vacio y datos
test: cubrir estados asincronos y reintento con repositorio falso
```

Los mensajes finales deben reflejar el contenido real del commit.

## 14. Fuera de alcance

No implementar:

- backend remoto;
- Supabase;
- Firebase;
- API REST;
- SQLite;
- Riverpod;
- autenticación;
- persistencia;
- cambios en `GiftProduct`;
- cambios en `CartScreen` o `CheckoutScreen`.

Tampoco:

- agregar dependencias;
- modificar Search, Cart o Checkout;
- cerrar el Issue #21 antes de integrar el PR;
- trabajar directamente en `main`.

## 15. Estado de avance

- BUILD 5A: repositorio local, mock y pruebas unitarias.
- BUILD 5B: integración en `ProductResultsScreen`, cuatro estados, retry y
  pruebas de widget con fake.
- FASE 5 se documentará al terminar la integración y el QA.
