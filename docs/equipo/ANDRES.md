# Andrés — módulo `products/`

Rama personal: `andres`
Módulo principal: `giftify/lib/features/products/`

## Estado real integrado

### Resultados

Archivo: `giftify/lib/features/products/screens/product_results_screen.dart`

- Recibe `GiftSearchCriteria?` mediante `AppRoutes.productResults`.
- Si `criteria == null`, muestra el catálogo completo con orden determinista.
- Filtra con `filterAndPrioritizeProducts` desde
  `giftify/lib/features/products/utils/product_filters.dart`.
- Usa `mockProducts` como fuente local.
- Muestra resumen de criterios cuando existen.
- Estado vacío actual:
  `No encontramos opciones que cumplan todos los criterios.`
- Navega al detalle con `AppRoutes.productDetail` enviando `GiftProduct`.
- Reutiliza `ProductCard` y `AvailabilityBadge`.
- No tiene estados de carga ni de error porque la consulta es síncrona.

### Detalle

Archivo: `giftify/lib/features/products/screens/product_detail_screen.dart`

- Recibe `GiftProduct?` mediante el router.
- Muestra nombre, precio, descripción, disponibilidad, entrega, categoría,
  tamaño, vendedor y calificación.
- Maneja `inStock`, `lowStock`, `outOfStock` y `unknown` sin inventar stock.
- Si `product == null`, muestra un estado seguro:
  `No se pudo cargar la información del producto.`
- Al agregar, crea `CartItem(product: product)` y navega a `AppRoutes.cart`
  con `[item]`.
- No existe carrito global ni persistencia.

### Filtrado

`product_filters.dart` contiene funciones puras:

- excluye productos por encima de `maxBudget`;
- prioriza categoría, ocasión, tamaño y entrega antes de `eventDate`;
- ordena por puntuación, precio e id;
- `recipient` no filtra porque `GiftProduct` no contiene esa información.

Pruebas existentes:

- `product_filters_test.dart` (8 pruebas).
- `product_results_screen_test.dart` (5 pruebas).
- `product_detail_screen_test.dart` (12 pruebas).

## Enfoque de la siguiente etapa

`ProductResultsScreen` es la pantalla candidata natural para el laboratorio de
cuatro estados porque ya representa una lista de datos. La arquitectura objetivo,
cuando el equipo lo apruebe, es:

```text
ProductResultsScreen
        |
   Provider/Future
        |
ProductRepository
        |
MockProductRepository
        |
   mockProducts
```

Contrato conceptual:

```dart
abstract class ProductRepository {
  Future<List<GiftProduct>> fetchProducts();
}
```

La implementación local debe poder:

- esperar con `Future.delayed`;
- devolver `mockProducts`;
- devolver una lista vacía;
- lanzar una excepción configurable para pruebas.

Estados obligatorios de la pantalla:

```text
Cargando…                           -> indicador visible
No pudimos cargar los productos.    -> botón Reintentar
No encontramos productos.           -> acción Modificar búsqueda
Datos                               -> lista normal
```

El botón `Reintentar` debe ejecutar realmente una nueva consulta.

## Reglas específicas

- No agregar Riverpod, SQLite ni HTTP sin decisión explícita del equipo.
- No modificar `features/cart/` sin coordinar con Catherine.
- No duplicar `GiftProduct`, `CartItem` ni `GiftSearchCriteria`.
- No inventar campos de producto que el modelo no tenga.
- Mantener el filtrado en funciones puras y testeables.
- La prueba del estado de error debe usar un repositorio falso que lance una
  excepción; no debe depender de la red.

## Coordinación

- Dependencia directa: Brayan (`search/`), por el contrato
  `GiftSearchCriteria -> Results`.
- Dependencia directa: Catherine (`cart/`), por `CartItem` y la navegación al
  carrito.
- Dependencia de contrato: `shared/models/gift_product.dart` y
  `shared/data/mock_products.dart`.

## Validación antes de cerrar una tarea

Desde `giftify/`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/product_filters_test.dart
flutter test test/product_results_screen_test.dart
flutter test test/product_detail_screen_test.dart
flutter test
```

Actualizar:

- `docs/bitacoras/ANDRES.md`
- `docs/bitacora-ia.md` si se usó IA
