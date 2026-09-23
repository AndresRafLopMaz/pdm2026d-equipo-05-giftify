# Giftify — Fase 2: Modelos compartidos, datos mock y espacio básico de backend

## 1. Propósito de este documento

Este documento explica la lógica de la **Fase 2 del proyecto Giftify**.

Su objetivo fue definir un conjunto de estructuras de datos compartidas que permitan que las siete pantallas intercambien información de forma coherente, además de preparar datos simulados para el desarrollo frontend y reservar un espacio mínimo para una futura integración con backend.

Esta fase se diseñó deliberadamente bajo el principio:

> **Frontend primero, backend preparado pero no implementado.**

---

# 2. Problema que esta fase intenta resolver

Una arquitectura modular por carpetas no es suficiente si cada integrante crea sus propios modelos.

Ejemplo de problema:

```text
Brayan crea:
Map<String, dynamic>

Andrés crea:
class Product

Catherine crea:
class CartProduct
```

Aunque cada pantalla funcione por separado, posteriormente podrían existir incompatibilidades.

Por esta razón se establecieron **contratos de datos comunes**.

---

# 3. Concepto de contrato compartido

Un contrato es una estructura acordada que define qué información intercambian dos módulos.

Ejemplo:

```text
Pantalla 3
     │
     │ GiftSearchCriteria
     ▼
Pantalla 4
```

Ambas pantallas conocen el mismo tipo de objeto.

Esto evita que una pantalla envíe datos con una estructura y otra espere una diferente.

---

# 4. Estructura creada

La nueva estructura principal fue:

```text
lib/
├── core/
│   └── backend/
│       ├── backend_client.dart
│       └── backend_config.dart
│
└── shared/
    ├── data/
    │   └── mock_products.dart
    │
    ├── enums/
    │   ├── gift_availability.dart
    │   └── payment_method_type.dart
    │
    └── models/
        ├── cart_item.dart
        ├── delivery_address.dart
        ├── gift_product.dart
        ├── gift_search_criteria.dart
        └── user_profile.dart
```

También se agregó:

```text
test/shared_models_test.dart
```

---

# 5. ¿Por qué `shared/`?

`shared/` contiene elementos que son usados por múltiples funcionalidades.

Ejemplo:

```text
GiftProduct
```

es utilizado por:

- resultados;
- detalle del producto;
- carrito;
- potencialmente checkout.

Por lo tanto, no debe pertenecer exclusivamente a `features/products/` ni a `features/cart/`.

La ubicación correcta es:

```text
shared/models/gift_product.dart
```

---

# 6. `GiftSearchCriteria`

Archivo:

```text
shared/models/gift_search_criteria.dart
```

Representa los criterios definidos por el usuario antes de buscar regalos.

Campos principales:

```text
occasion
recipient
maxBudget
eventDate
giftType
size
```

Uso previsto:

```text
Pantalla 3
Personalización
     │
     │ GiftSearchCriteria
     ▼
Pantalla 4
Resultados
```

---

# 7. `copyWith`

El modelo incluye un método:

```dart
copyWith()
```

Su finalidad es permitir modificar parte de un objeto sin reconstruir manualmente todos sus valores.

Ejemplo:

```dart
final updated = criteria.copyWith(
  maxBudget: 400,
);
```

Esto será útil cuando el usuario ajuste los filtros de búsqueda.

---

# 8. `GiftAvailability`

Archivo:

```text
shared/enums/gift_availability.dart
```

Estados definidos:

```dart
GiftAvailability.inStock
GiftAvailability.lowStock
GiftAvailability.outOfStock
GiftAvailability.unknown
```

| Estado | Significado |
|---|---|
| `inStock` | disponible |
| `lowStock` | pocas unidades |
| `outOfStock` | agotado |
| `unknown` | disponibilidad sin confirmar |

Este enum responde a uno de los problemas principales detectados en Giftify: la incertidumbre sobre la disponibilidad real.

---

# 9. `GiftProduct`

Archivo:

```text
shared/models/gift_product.dart
```

Es el modelo central para representar un regalo.

Campos principales:

```text
id
name
description
price
category
size
availability
sellerName
sellerRating
suggestedOccasions
estimatedDeliveryDays
imageAsset
```

También incluye una propiedad calculada:

```dart
isAvailable
```

---

# 10. Razón de los campos de `GiftProduct`

Los campos cubren necesidades del prototipo y del alcance:

- precio;
- disponibilidad;
- vendedor;
- calificación;
- categoría;
- tamaño;
- ocasión sugerida;
- tiempo estimado de entrega.

Especialmente importantes:

```text
precio
disponibilidad
tiempo de entrega
```

---

# 11. `CartItem`

Archivo:

```text
shared/models/cart_item.dart
```

Representa un producto dentro del carrito.

Campos:

```text
product
quantity
```

Incluye:

```dart
double get subtotal
```

que calcula:

```text
precio × cantidad
```

---

# 12. `DeliveryAddress`

Archivo:

```text
shared/models/delivery_address.dart
```

Representa una dirección utilizada durante el check-out.

Campos:

```text
id
label
recipientName
addressLine
city
department
reference
```

---

# 13. `UserProfile`

Archivo:

```text
shared/models/user_profile.dart
```

Representa información general del usuario.

Campos:

```text
id
name
email
birthDate
addresses
```

---

# 14. Decisiones de seguridad en `UserProfile`

El modelo deliberadamente NO contiene:

```text
password
PIN
CVV
número completo de tarjeta
```

La razón es evitar mezclar credenciales o datos sensibles con un modelo general de perfil.

---

# 15. `PaymentMethodType`

Archivo:

```text
shared/enums/payment_method_type.dart
```

Valores iniciales:

```dart
PaymentMethodType.card
PaymentMethodType.cashOnDelivery
```

En esta fase son únicamente opciones de interfaz.

No existe integración real con una pasarela de pago.

---

# 16. Datos simulados

Archivo:

```text
shared/data/mock_products.dart
```

Se creó:

```dart
const List<GiftProduct> mockProducts
```

El propósito es que las pantallas puedan desarrollarse sin depender de una API.

---

# 17. ¿Por qué usar mocks?

Durante las primeras etapas, un frontend debe poder construirse y probarse aunque:

- no exista servidor;
- no exista base de datos;
- la API no esté lista;
- no haya conexión;
- otro módulo todavía no esté terminado.

Flujo actual:

```text
UI
 ↓
modelos compartidos
 ↓
mockProducts
```

Flujo futuro:

```text
UI
 ↓
modelos compartidos
 ↓
servicio/repositorio
 ↓
BackendClient
 ↓
API
```

---

# 18. Escenarios representados por los mocks

Los datos simulados contemplan:

- productos disponibles;
- poco stock;
- agotados;
- disponibilidad desconocida;
- diferentes precios;
- diferentes categorías;
- vendedores distintos;
- calificaciones;
- distintos tiempos de entrega.

---

# 19. Espacio básico para backend

Se creó:

```text
core/backend/
```

con:

```text
backend_config.dart
backend_client.dart
```

La intención no fue implementar un backend, sino **reservar un punto de entrada coherente**.

---

# 20. `BackendConfig`

Permite definir una futura URL mediante:

```text
GIFTIFY_API_BASE_URL
```

Ejemplo:

```powershell
flutter run --dart-define=GIFTIFY_API_BASE_URL=https://api.ejemplo.com
```

Esto evita escribir URLs directamente dentro de cada pantalla.

---

# 21. `BackendClient`

Su responsabilidad actual es mínima.

Puede:

- conocer la URL base;
- verificar si existe configuración;
- construir una `Uri`.

No puede:

- ejecutar GET;
- ejecutar POST;
- autenticarse;
- persistir datos;
- comunicarse realmente con un servidor.

---

# 22. Dependencias que NO se agregaron

No se agregó:

```text
http
dio
firebase
supabase
graphql
```

La razón fue evitar infraestructura prematura.

---

# 23. Regla para futuras integraciones de backend

Una futura IA o integrante no debe realizar llamadas HTTP directamente desde widgets.

Dirección recomendada:

```text
UI
 ↓
capa de acceso a datos
 ↓
BackendClient
 ↓
API
```

Esa capa todavía no debe crearse hasta que exista una necesidad real.

---

# 24. Pruebas de modelos

Archivo:

```text
test/shared_models_test.dart
```

Verifica aspectos como:

- catálogo mock no vacío;
- subtotal del carrito;
- funcionamiento de `copyWith`.

---

# 25. Validación realizada

Comandos principales:

```powershell
dart format lib/shared lib/core/backend test/shared_models_test.dart
flutter analyze
flutter test
```

Resultados esperados:

```text
No issues found!
All tests passed!
```

---

# 26. Relación entre integrantes y modelos

## Diego

Principal modelo:

```text
UserProfile
```

## Brayan

Principal modelo:

```text
GiftSearchCriteria
```

## Andrés

Principales modelos:

```text
GiftSearchCriteria
GiftProduct
GiftAvailability
```

## Catherine

Principales modelos:

```text
GiftProduct
CartItem
DeliveryAddress
PaymentMethodType
UserProfile
```

---

# 27. Regla de no duplicación

Una IA no debe crear modelos alternativos si ya existe uno compartido.

Antes de crear un nuevo modelo debe revisar:

```text
lib/shared/models/
lib/shared/enums/
```

---

# 28. Estado de arquitectura después de esta fase

```text
lib/
├── app/
├── core/
│   ├── backend/
│   └── theme/
├── features/
└── shared/
    ├── data/
    ├── enums/
    └── models/
```

Separación conceptual:

```text
app      → configuración global
core     → infraestructura
features → funcionalidades
shared   → contratos y datos comunes
```

---

# 29. Reglas para una IA que reciba este documento

1. Priorizar frontend.
2. No implementar backend completo sin solicitud explícita.
3. Utilizar los modelos existentes.
4. No duplicar `GiftProduct`.
5. No duplicar `GiftSearchCriteria`.
6. No almacenar datos sensibles en `UserProfile`.
7. Utilizar `mockProducts` durante el desarrollo inicial.
8. Mantener `BackendClient` simple hasta que exista una API real.
9. No agregar paquetes de red sin justificar la necesidad.
10. Ejecutar `flutter analyze` y `flutter test` después de modificar contratos.

---

# 30. Resumen de la Fase 2

La lógica completa fue:

```text
pantallas separadas
      ↓
necesidad de compartir datos
      ↓
definir contratos
      ↓
crear modelos comunes
      ↓
crear enums comunes
      ↓
crear datos simulados
      ↓
reservar backend mínimo
      ↓
crear pruebas
      ↓
validar
```

Esta fase permite que los cuatro integrantes desarrollen sus pantallas utilizando el mismo lenguaje de datos.
