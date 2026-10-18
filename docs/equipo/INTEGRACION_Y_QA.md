# Integración y QA — Giftify

Este documento describe cómo validar el MVP real y qué exigir antes de integrar
la siguiente fase.

## 1. Recorrido manual obligatorio

```text
Registro
  -> Home
  -> Personalización
  -> Resultados
  -> Detalle
  -> Carrito
  -> Checkout
```

Contratos reales:

| Paso | Origen | Argumento / destino |
|---|---|---|
| Registro -> Home | `RegisterScreen` | `pushReplacementNamed(AppRoutes.home)` |
| Home -> Search | `HomeScreen` | `pushNamed(AppRoutes.search)` |
| Search -> Results | `GiftSearchScreen` | `GiftSearchCriteria` -> `AppRoutes.productResults` |
| Results -> Detail | `ProductResultsScreen` | `GiftProduct` -> `AppRoutes.productDetail` |
| Detail -> Cart | `ProductDetailScreen` | `[CartItem]` -> `AppRoutes.cart` |
| Cart -> Checkout | `CartScreen` | `List<CartItem>` -> `AppRoutes.checkout` |

## 2. Checklist de integración

```text
[ ] Registro navega a Home después de un registro válido
[ ] Registro no navega con el formulario inválido
[ ] Home navega a Search con el CTA "Encontrar tu regalo"
[ ] Search valida ocasión, destinatario y presupuesto
[ ] Search construye GiftSearchCriteria con los campos correctos
[ ] Results recibe los criterios y muestra el resumen
[ ] Results muestra el catálogo general cuando criteria es null
[ ] Results abre Detail enviando un GiftProduct
[ ] Detail muestra nombre, precio, descripción y vendedor
[ ] Detail representa la disponibilidad con texto, no solo con color
[ ] Detail crea CartItem y navega al carrito
[ ] Cart recibe los items y calcula subtotales y total
[ ] Cart permite aumentar, disminuir y eliminar productos
[ ] Cart no permite cantidad menor que 1
[ ] Cart muestra el estado vacío cuando corresponde
[ ] Checkout recibe List<CartItem>
[ ] Checkout valida los cuatro campos obligatorios de entrega
[ ] Checkout exige método de pago
[ ] Checkout bloquea dobles envíos mientras procesa
[ ] Los totales de Cart y Checkout coinciden
[ ] No hay overflow en pantalla móvil pequeña
[ ] No hay excepciones en el recorrido manual
[ ] dart format pasa
[ ] flutter analyze pasa
[ ] flutter test pasa
```

## 3. Estados asíncronos exigidos para el laboratorio

La pantalla seleccionada debe representar explícitamente:

### Cargando

```text
Cargando…
```

Indicador visible, por ejemplo `CircularProgressIndicator` con texto.

### Error

```text
No pudimos cargar los productos.
```

Debe incluir un botón `Reintentar` que ejecute una nueva consulta real.

### Vacío

```text
No encontramos productos.
```

Debe incluir una acción relevante, por ejemplo `Modificar búsqueda`.

### Datos

Lista normal de productos, con navegación al detalle.

Reglas:

- No simular el error solo con un texto estático.
- No usar `continue-on-error` en el CI.
- Probar el estado de error con un repositorio falso que lance una excepción.
- Verificar que la aplicación no colapse y que `Reintentar` sea accionable.
- Si se usa Riverpod, desactivar su reintento automático para que el botón sea
  la única forma de reintentar y documentar dónde se configuró.

## 4. Repositorios de datos

Patrón esperado para preparar el backend sin implementarlo todavía:

```text
Pantalla
   |
Future / Provider
   |
Repository (interfaz)
   |
Implementación mock o remota
```

Ejemplo conceptual:

```dart
abstract class ProductRepository {
  Future<List<GiftProduct>> fetchProducts();
}
```

La implementación mock debe permitir configurar:

- datos normales;
- lista vacía;
- excepción;
- demora controlada.

No se agrega SQLite ni HTTP real en esta fase. `BackendClient` y
`BackendConfig` siguen siendo solo configuración.

## 5. CI

El workflow debe:

- activarse en `pull_request`, `push` a `main` y `workflow_dispatch`;
- ejecutar en `giftify/`;
- usar una versión de Flutter compatible con `sdk: ^3.12.2`;
- ejecutar `flutter pub get`, `dart format`, `flutter analyze` y
  `flutter test`;
- exponer un check estable llamado `Formato, análisis y pruebas`.

El PR debe estar en verde antes de integrarse. La integración se hace con
revisión de otro integrante y sin `force push`.

## 6. Comandos de QA

Desde `giftify/`:

```powershell
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Desde la raíz:

```powershell
git status
git diff --check
git diff --stat
```

## 7. Evidencias para el laboratorio

- Captura del check `Formato, análisis y pruebas` en verde.
- Captura de la configuración del ruleset de `main`.
- Captura de un push directo rechazado.
- Captura del PR con plantilla completa y aprobación de otro integrante.
- Captura de la pantalla mostrando carga, error con `Reintentar`, vacío y datos.
- Salida de `flutter test` con el total de pruebas.
- Entrada actualizada en `docs/bitacora-ia.md`.

## 8. Reglas de integración

- No integrar un PR sin revisión.
- No integrar con checks rojos.
- No corregir conflictos escogiendo automáticamente una versión.
- No modificar módulos ajenos sin justificarlo en el PR.
- No eliminar pruebas para reducir fallos.
- No agregar dependencias sin justificación.
- Cualquier problema de integración se corrige en una rama temporal, no
  directamente en `main`.
