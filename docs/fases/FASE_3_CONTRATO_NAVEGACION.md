# Giftify — Fase 3: Contrato de navegación entre pantallas

## 1. Propósito de este documento

Este documento describe la lógica de la **Fase 3 de preparación técnica de Giftify**, cuyo objetivo es definir cómo deben conectarse las siete pantallas sin introducir todavía un gestor global de estado ni una arquitectura de navegación más compleja de lo necesario.

El principio principal de esta fase es:

> **Una aplicación modular necesita contratos de datos y contratos de navegación.**

La Fase 2 definió qué objetos comparte cada pantalla.  
La Fase 3 define cómo esos objetos viajan de una pantalla a otra.

---

# 2. Problema que esta fase resuelve

Aunque existan modelos comunes, cada integrante podría navegar de forma distinta.

Ejemplo de riesgo:

```text
Brayan usa Navigator.push
Andrés usa rutas con strings manuales
Catherine crea otro MaterialApp
```

Eso generaría una aplicación difícil de integrar.

Por esta razón se definió un único router global y se especificaron los argumentos que cada pantalla puede recibir.

---

# 3. Flujo funcional principal

```text
Pantalla 1
Registro
   ↓
Pantalla 2
Home
   ↓
Pantalla 3
Personalización
   ↓
Pantalla 4
Resultados
   ↓
Pantalla 5
Detalle
   ↓
Pantalla 6
Carrito
   ↓
Pantalla 7
Check-out
```

---

# 4. Flujo de datos entre pantallas

```text
Pantalla 3
    │
    │ GiftSearchCriteria
    ▼
Pantalla 4
    │
    │ GiftProduct
    ▼
Pantalla 5
    │
    │ GiftProduct / CartItem
    ▼
Pantalla 6
    │
    │ List<CartItem>
    ▼
Pantalla 7
```

---

# 5. Entrada prevista por pantalla

| Pantalla | Clase | Entrada |
|---|---|---|
| 1 | `RegisterScreen` | ninguna |
| 2 | `HomeScreen` | ninguna |
| 3 | `GiftSearchScreen` | ninguna |
| 4 | `ProductResultsScreen` | `GiftSearchCriteria?` |
| 5 | `ProductDetailScreen` | `GiftProduct?` |
| 6 | `CartScreen` | `List<CartItem>` |
| 7 | `CheckoutScreen` | `List<CartItem>` |

---

# 6. `ProductResultsScreen`

Ubicación:

```text
features/products/screens/product_results_screen.dart
```

Entrada:

```dart
final GiftSearchCriteria? criteria;
```

Responsabilidad futura:

- recibir criterios;
- filtrar o seleccionar datos mock;
- mostrar productos adecuados;
- permitir modificar o refinar búsqueda;
- abrir detalle de producto.

---

# 7. Navegación Pantalla 3 → Pantalla 4

Ejemplo:

```dart
final criteria = GiftSearchCriteria(
  occasion: selectedOccasion,
  recipient: selectedRecipient,
  maxBudget: selectedBudget,
);

Navigator.pushNamed(
  context,
  AppRoutes.productResults,
  arguments: criteria,
);
```

No se recomienda enviar un `Map` genérico si ya existe `GiftSearchCriteria`.

---

# 8. `ProductDetailScreen`

Ubicación:

```text
features/products/screens/product_detail_screen.dart
```

Entrada:

```dart
final GiftProduct? product;
```

Responsabilidad futura:

- imagen;
- nombre;
- precio;
- descripción;
- disponibilidad;
- entrega;
- vendedor;
- agregar al carrito.

---

# 9. Navegación Pantalla 4 → Pantalla 5

```dart
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: selectedProduct,
);
```

---

# 10. `CartScreen`

Ubicación:

```text
features/cart/screens/cart_screen.dart
```

Entrada inicial:

```dart
final List<CartItem> initialItems;
```

Responsabilidad futura:

- mostrar artículos;
- eliminar artículos;
- consultar detalles;
- calcular totales;
- continuar a check-out.

---

# 11. ¿Por qué `List<CartItem>`?

El carrito puede contener múltiples productos.

Por eso el contrato es:

```dart
List<CartItem>
```

y no `GiftProduct` ni un único `CartItem`.

---

# 12. Navegación Pantalla 5 → Pantalla 6

Ejemplo:

```dart
final item = CartItem(
  product: selectedProduct,
);

Navigator.pushNamed(
  context,
  AppRoutes.cart,
  arguments: [item],
);
```

---

# 13. `CheckoutScreen`

Ubicación:

```text
features/cart/screens/checkout_screen.dart
```

Entrada:

```dart
final List<CartItem> items;
```

Responsabilidad futura:

- dirección;
- método de pago;
- resumen;
- confirmación.

---

# 14. Navegación Pantalla 6 → Pantalla 7

```dart
Navigator.pushNamed(
  context,
  AppRoutes.checkout,
  arguments: cartItems,
);
```

---

# 15. Router global

Archivo:

```text
lib/app/app_router.dart
```

El router es el punto central para:

- registrar rutas;
- validar argumentos;
- construir pantallas;
- manejar rutas desconocidas.

---

# 16. Rutas centralizadas

Se utilizan:

```dart
AppRoutes.register
AppRoutes.home
AppRoutes.search
AppRoutes.productResults
AppRoutes.productDetail
AppRoutes.cart
AppRoutes.checkout
```

Una IA no debe escribir rutas manualmente si ya existe una constante.

---

# 17. Validación de argumentos

El router comprueba el tipo recibido.

Ejemplo conceptual:

```dart
final product = settings.arguments;

ProductDetailScreen(
  product: product is GiftProduct ? product : null,
)
```

Esto evita fallos inmediatos durante la etapa temprana.

---

# 18. Extracción de carrito

El router puede interpretar:

```text
List<CartItem>
```

y utilizar una lista vacía si el argumento no es válido.

El objetivo es mantener los placeholders funcionales mientras se desarrolla la integración real.

---

# 19. Ruta desconocida

El router incluye una pantalla básica para rutas no reconocidas.

Esto es preferible a una excepción sin manejar.

---

# 20. Gestión de estado: decisión deliberada

No se agregó:

```text
Provider
Riverpod
BLoC
Cubit
Redux
GetX
```

El mecanismo inicial es:

```text
pantalla
   ↓
Navigator
   ↓
arguments
   ↓
pantalla destino
```

---

# 21. Cuándo podría necesitarse estado global

Podría evaluarse si se necesita:

- carrito persistente;
- usuario global;
- favoritos;
- sincronización con backend;
- actualizaciones reactivas entre varias pantallas.

Hasta entonces, no debe agregarse solo por anticipación.

---

# 22. Navegación secundaria prevista

```text
Resultados → Detalle
Resultados → Carrito
Resultados → modificar criterios
Detalle → Carrito
Carrito → Detalle
Carrito → Check-out
```

Todas estas rutas deben utilizar el mismo router.

---

# 23. Pruebas de navegación

Archivo:

```text
test/navigation_contract_test.dart
```

La prueba debe verificar al menos:

1. `GiftProduct` llega a `ProductDetailScreen`;
2. `List<CartItem>` llega a `CartScreen`.

---

# 24. Razón para probar contratos

Una interfaz puede seguir compilando aunque un argumento deje de enviarse correctamente.

Las pruebas de navegación ayudan a detectar esas regresiones.

---

# 25. Validaciones de la fase

```powershell
dart format `
  lib/app/app_router.dart `
  lib/features/products/screens `
  lib/features/cart/screens `
  test/navigation_contract_test.dart

flutter analyze
flutter test
```

Resultados esperados:

```text
No issues found!
All tests passed!
```

---

# 26. Responsabilidades por integrante después de esta fase

## Diego

Zona principal:

```text
features/auth/
```

Debe navegar hacia Home utilizando el router existente.

## Brayan

Zonas principales:

```text
features/home/
features/search/
```

Debe construir `GiftSearchCriteria` antes de navegar a resultados.

## Andrés

Zona principal:

```text
features/products/
```

Debe recibir `GiftSearchCriteria` y trabajar con `GiftProduct`.

## Catherine

Zona principal:

```text
features/cart/
```

Debe trabajar con:

```text
CartItem
DeliveryAddress
PaymentMethodType
```

---

# 27. Archivos compartidos

Archivos como:

```text
app/app_router.dart
shared/
core/
```

no pertenecen exclusivamente a un integrante.

Cualquier cambio debe justificarse porque puede afectar múltiples módulos.

---

# 28. Reglas para una IA que reciba este documento

1. No crear un segundo router.
2. No crear un segundo `MaterialApp`.
3. No reemplazar rutas existentes sin necesidad.
4. Utilizar `AppRoutes`.
5. Utilizar los modelos compartidos.
6. No enviar mapas genéricos si existe un modelo.
7. No agregar estado global sin justificarlo.
8. No cambiar contratos compartidos sin evaluar impacto.
9. Mantener compatibilidad entre pantallas.
10. Ejecutar pruebas después de cambiar navegación.

---

# 29. Arquitectura conceptual después de esta fase

```text
                         GiftifyApp
                             │
                             ▼
                         AppRouter
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
      AUTH                 SEARCH             PRODUCTS
        │                    │                    │
        │                    │ GiftSearchCriteria │
        │                    └───────────────→    │
        │                                         │
        │                                    GiftProduct
        │                                         │
        │                                         ▼
        │                                       CART
        │                                         │
        │                                   List<CartItem>
        │                                         │
        └─────────────────────────────────────────▼
                                              CHECKOUT
```

---

# 30. Resultado global de las tres fases

Después de las tres fases, Giftify dispone de:

```text
estructura modular
       +
modelos compartidos
       +
datos simulados
       +
espacio básico de backend
       +
router central
       +
contrato de navegación
       +
pruebas básicas
```

Esto permite crear futuras ramas personales desde una base común.

---

# 31. Qué NO debe interpretarse de esta fase

La existencia de rutas y modelos no significa que:

- las siete pantallas estén terminadas;
- exista autenticación;
- el carrito sea persistente;
- exista API real;
- los pagos sean reales;
- exista backend funcional;
- los mocks sean definitivos.

Son únicamente contratos y estructura para desarrollo.

---

# 32. Resumen de la Fase 3

La lógica fue:

```text
modelos compartidos
       ↓
definir entradas por pantalla
       ↓
centralizar rutas
       ↓
validar argumentos
       ↓
probar navegación
       ↓
preparar integración entre ramas
```

El resultado es una base donde cada integrante puede implementar su módulo sin tener que inventar cómo conectarlo con el resto de la aplicación.
