# FASE 5 — Integración, estados asíncronos y QA del MVP local

ESTADO: COMPLETADA

## Objetivo

Cerrar Giftify como un MVP completamente local y verificable: siete pantallas
integradas, navegación completa, datos locales, estados asíncronos en Results y
suite global en verde.

## Alcance

- integración de las ramas personales;
- CI y protección de `main`;
- estados asíncronos de `ProductResultsScreen`;
- repositorio local de productos;
- pruebas automatizadas;
- QA del flujo completo;
- evidencias visuales del laboratorio.

## Integración del equipo

### Diego

- Registro responsive.
- Corrección `Row` → `Wrap` en la fila de inicio de sesión.
- Prueba responsive 320×640.

### Brayan

- Home y Search.
- `home_screen_test.dart`.
- `gift_search_screen_test.dart`.
- Cobertura de `GiftSearchCriteria` y navegación Search → Results.

### Andrés

- Results y Detail.
- `ProductRepository` y `MockProductRepository`.
- Estados asíncronos, retry, empty con acción y data.
- Fake repository y pruebas de estados.

### Catherine

- Cart → Checkout.
- `cart_checkout_flow_test.dart`.
- Verificación de cantidades, subtotales, total y lista actualizada.

## Arquitectura local final

```text
UI
 ↓
Repository
 ↓
Mock / local data
```

Para Products:

```text
ProductResultsScreen
        ↓
ProductRepository
        ↓
MockProductRepository
        ↓
mockProducts
```

No existe backend remoto, SQLite ni persistencia.

## Estados

- **Loading:** `CircularProgressIndicator` y `Cargando…`.
- **Error:** `No pudimos cargar los productos.` y `Reintentar`.
- **Retry:** nueva llamada a `fetchProducts()` y recuperación con datos.
- **Empty:** `No encontramos productos.` y `Modificar búsqueda`.
- **Data:** catálogo local con `ProductCard`.

El retry es manual; no existe retry automático.

## Flujo completo

```text
Register → Home → Search → Results → Detail → Cart → Checkout
```

Contratos principales:

```text
GiftSearchCriteria → Results
GiftProduct → Detail
CartItem → Cart
List<CartItem> → Checkout
```

## Validación

Resultados reales al cierre:

```text
dart format --output=none --set-exit-if-changed lib test
Formatted 40 files (0 changed)

flutter analyze
No issues found!

flutter test
86 pruebas aprobadas
All tests passed!

git diff --check
CHECK_EXIT=0
```

## CI y GitHub

- Workflow de CI configurado con formato, análisis y pruebas.
- Check requerido: `Formato, análisis y pruebas`.
- CODEOWNERS configurado.
- Protección de `main` configurada y probada previamente.
- Evidencia de push directo a `main` rechazado.
- Evidencia de PR bloqueado sin aprobación.
- Issue #21 utilizado como trazabilidad.
- PR final de estados asíncronos: **#24**.
- Commit squash integrado en `main`: `1741d01`.
- CI del PR final: `Formato, análisis y pruebas` en verde.

La aprobación adicional prevista por el procedimiento del laboratorio no se
realizó en el cierre inmediato por restricción de tiempo y queda como pendiente
de proceso.

## Evidencias visuales

Se conservaron capturas, fuera del repositorio, de:

1. Loading.
2. Error + `Reintentar`.
3. Recuperación después de `Reintentar`.
4. Empty + `Modificar búsqueda`.
5. Data.

El entrypoint temporal utilizado para las capturas fue eliminado y nunca fue
versionado.

## Limitaciones actuales

- Backend remoto no implementado.
- Datos mock/locales.
- Registro simulado.
- Carrito y direcciones en memoria.
- Pagos simulados.
- Sin persistencia real.
- Aprobación adicional del PR final pendiente de proceso.
- Reactivación/verificación manual del ruleset de `main` pendiente.

## Fase futura

La planificación de backend remoto vive en
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.

El backend es una fase opcional/futura y no es necesario para el MVP local
actual.
