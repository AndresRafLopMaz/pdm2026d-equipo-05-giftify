# 🎁 Giftify

Giftify es una aplicación móvil desarrollada con **Flutter** orientada a facilitar la elección de regalos personalizados mediante una experiencia de búsqueda guiada, comparación de opciones y consulta de información relevante antes de realizar una selección.

El proyecto surge de la necesidad de reducir la incertidumbre que puede aparecer al buscar un regalo cuando existen restricciones de presupuesto, destinatario, fecha, disponibilidad, características del producto y tiempo de entrega.

---

## 📌 Descripción general

Giftify busca apoyar al usuario durante todo el recorrido de selección de un regalo:

1. identificar la ocasión;
2. identificar al destinatario;
3. definir criterios de búsqueda;
4. consultar opciones recomendadas;
5. comparar productos;
6. revisar los detalles de una opción;
7. agregar productos al carrito;
8. completar un proceso de check-out.

La intención principal es que la aplicación no se limite a mostrar un catálogo general, sino que utilice información contextual para presentar alternativas más adecuadas a la necesidad del usuario.

---

## 🎯 Problema que aborda

Durante la búsqueda de un regalo pueden presentarse dificultades como:

- información de disponibilidad desactualizada;
- diferencias entre lo publicado y el producto real;
- dificultad para comparar varias alternativas;
- restricciones de presupuesto;
- tiempos de entrega limitados;
- características específicas del destinatario;
- información dispersa entre diferentes fuentes.

Giftify busca concentrar la información necesaria para apoyar una decisión más clara y estructurada.

---

## 💡 Propuesta de valor

Giftify propone una experiencia de búsqueda personalizada donde el usuario pueda establecer criterios y recibir opciones que se ajusten mejor a su contexto.

Entre los criterios considerados se encuentran:

- ocasión;
- destinatario;
- presupuesto máximo;
- fecha prevista;
- categoría del regalo;
- tamaño;
- disponibilidad;
- información del vendedor;
- calificación;
- tiempo estimado de entrega.

---

# 🧭 Flujo general de la aplicación

El diseño contempla siete pantallas principales:

```text
1. Registro de usuario
        ↓
2. Pantalla principal / guía
        ↓
3. Personalización de búsqueda
        ↓
4. Resultados personalizados
        ↓
5. Detalle del producto
        ↓
6. Carrito de compras
        ↓
7. Check-out
```

Además del recorrido principal, la aplicación contempla navegación secundaria como:

```text
Resultados → modificar búsqueda
Resultados → detalle de producto
Resultados → carrito
Detalle → carrito
Carrito → detalle
Carrito → check-out
```

---

# 🧱 Tecnologías principales

El proyecto utiliza principalmente:

- **Flutter** para el desarrollo de la aplicación móvil;
- **Dart** como lenguaje de programación;
- **Material 3** como base del sistema visual;
- **Git** para control de versiones;
- **GitHub** para almacenamiento, integración y colaboración.

La arquitectura se mantiene deliberadamente sencilla y modular para permitir que pueda evolucionar sin agregar complejidad innecesaria.

---

# 🗂️ Estructura general del repositorio

```text
pdm2026d-equipo-05-giftify/
│
├── docs/
│   ├── bitacoras/
│   └── fases/
│
└── giftify/
    ├── lib/
    │   ├── main.dart
    │   │
    │   ├── app/
    │   │   ├── app_router.dart
    │   │   └── giftify_app.dart
    │   │
    │   ├── core/
    │   │   ├── backend/
    │   │   │   ├── backend_client.dart
    │   │   │   └── backend_config.dart
    │   │   │
    │   │   └── theme/
    │   │       └── app_theme.dart
    │   │
    │   ├── shared/
    │   │   ├── data/
    │   │   ├── enums/
    │   │   └── models/
    │   │
    │   └── features/
    │       ├── auth/
    │       ├── home/
    │       ├── search/
    │       ├── products/
    │       └── cart/
    │
    ├── test/
    └── pubspec.yaml
```

---

# 🧩 Organización arquitectónica

La aplicación se divide en cuatro bloques principales:

```text
app/
core/
shared/
features/
```

Cada uno tiene una responsabilidad específica.

---

## `app/`

Contiene la configuración global de la aplicación.

Incluye:

- inicialización de `MaterialApp`;
- configuración de rutas;
- navegación centralizada;
- definición de la aplicación principal.

Archivos relevantes:

```text
app/giftify_app.dart
app/app_router.dart
```

---

## `core/`

Contiene infraestructura transversal que puede ser utilizada por diferentes partes del sistema.

Actualmente se consideran dos áreas principales:

```text
core/
├── backend/
└── theme/
```

### `core/theme/`

Centraliza la configuración visual de la aplicación.

La intención es que colores, estilos generales y elementos comunes no se definan de forma diferente en cada pantalla.

### `core/backend/`

Reserva un espacio común para una futura comunicación con servicios externos.

La configuración se concentra en:

```text
backend_config.dart
backend_client.dart
```

Esto permite evitar que la configuración de una futura API quede distribuida directamente dentro de las pantallas.

---

## `shared/`

Contiene elementos que pueden ser utilizados por múltiples módulos.

Se divide en:

```text
shared/
├── data/
├── enums/
└── models/
```

### `shared/data/`

Contiene fuentes de datos compartidas.

Por ejemplo, un catálogo simulado puede utilizarse para desarrollar y probar la interfaz sin depender de un servicio externo.

### `shared/enums/`

Contiene enumeraciones utilizadas por diferentes módulos.

Ejemplos:

```text
GiftAvailability
PaymentMethodType
```

### `shared/models/`

Contiene los modelos principales que permiten intercambiar información entre las diferentes pantallas.

---

# 📦 Modelos principales

## `GiftSearchCriteria`

Representa los criterios utilizados para personalizar una búsqueda.

Puede incluir información como:

```text
occasion
recipient
maxBudget
eventDate
giftType
size
```

Su propósito principal es transportar los criterios de búsqueda entre la pantalla de personalización y la pantalla de resultados.

---

## `GiftProduct`

Representa una opción de regalo.

Incluye información como:

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

Este modelo puede ser utilizado por resultados, detalle de producto y carrito.

---

## `CartItem`

Representa un producto agregado al carrito.

Relaciona:

```text
GiftProduct
+
quantity
```

y permite calcular el subtotal correspondiente.

---

## `DeliveryAddress`

Representa información necesaria para una dirección de entrega.

Puede contener:

```text
label
recipientName
addressLine
city
department
reference
```

---

## `UserProfile`

Representa información general de un usuario.

Ejemplos:

```text
name
email
birthDate
addresses
```

Los datos sensibles de autenticación o pago no deben almacenarse directamente dentro de este modelo.

---

# 🔄 Relación entre pantallas y datos

La arquitectura busca que las pantallas intercambien objetos definidos previamente, en lugar de estructuras improvisadas.

Ejemplo conceptual:

```text
Pantalla de personalización
        │
        │ GiftSearchCriteria
        ▼
Pantalla de resultados
        │
        │ GiftProduct
        ▼
Pantalla de detalle
        │
        │ CartItem / GiftProduct
        ▼
Carrito
        │
        │ List<CartItem>
        ▼
Check-out
```

Esto permite que cada parte de la aplicación tenga un contrato de datos predecible.

---

# 🧭 Navegación

La navegación se concentra en:

```text
lib/app/app_router.dart
```

Las rutas se identifican mediante constantes como:

```dart
AppRoutes.register
AppRoutes.home
AppRoutes.search
AppRoutes.productResults
AppRoutes.productDetail
AppRoutes.cart
AppRoutes.checkout
```

Ejemplo de navegación:

```dart
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: selectedProduct,
);
```

Centralizar las rutas evita mantener cadenas duplicadas o diferentes sistemas de navegación dentro de cada pantalla.

---

# 🧪 Datos simulados

La aplicación contempla el uso de datos locales para facilitar el desarrollo y las pruebas.

El archivo:

```text
shared/data/mock_products.dart
```

puede contener productos con diferentes condiciones, como:

- disponible;
- pocas unidades;
- agotado;
- disponibilidad desconocida;
- distintos precios;
- diferentes vendedores;
- diferentes tiempos de entrega.

La finalidad de estos datos es desacoplar el desarrollo visual de una API externa.

---

# 🌐 Integración futura con backend

La arquitectura reserva el espacio:

```text
core/backend/
```

para una futura integración con servicios externos.

La idea es mantener un flujo conceptual como:

```text
Interfaz
   ↓
Modelos
   ↓
Capa de acceso a datos
   ↓
BackendClient
   ↓
API
```

La URL base puede configurarse mediante una variable de compilación:

```powershell
flutter run --dart-define=GIFTIFY_API_BASE_URL=https://api.ejemplo.com
```

Esto evita escribir direcciones del servidor directamente dentro de cada pantalla.

---

# 🎨 Organización de funcionalidades

La carpeta:

```text
features/
```

separa el código por responsabilidad funcional.

```text
features/
├── auth/
├── home/
├── search/
├── products/
└── cart/
```

## `auth/`

Contiene las pantallas y lógica relacionadas con acceso o registro de usuario.

## `home/`

Contiene la pantalla principal y elementos relacionados con la introducción o navegación inicial.

## `search/`

Contiene la personalización de criterios de búsqueda.

## `products/`

Contiene resultados de búsqueda y detalle de producto.

## `cart/`

Contiene carrito y check-out.

Esta organización evita concentrar toda la aplicación dentro de archivos grandes o carpetas genéricas.

---

# 🧪 Pruebas

El proyecto contempla pruebas en:

```text
giftify/test/
```

Entre las pruebas iniciales pueden encontrarse:

```text
app_smoke_test.dart
shared_models_test.dart
navigation_contract_test.dart
```

Estas pruebas ayudan a verificar:

- arranque de la aplicación;
- comportamiento de modelos compartidos;
- transferencia de argumentos entre rutas.

Comando principal:

```powershell
flutter test
```

---

# ✅ Validación del código

Para verificar la calidad estática del proyecto:

```powershell
flutter analyze
```

Para aplicar formato:

```powershell
dart format lib test
```

Y para ejecutar las pruebas:

```powershell
flutter test
```

---

# 📚 Documentación interna

El repositorio contiene:

```text
docs/
```

con dos grupos principales.

## `docs/fases/`

Contiene documentación técnica de decisiones arquitectónicas y de organización.

Puede utilizarse como contexto adicional para comprender por qué se tomaron determinadas decisiones.

## `docs/bitacoras/`

Contiene archivos individuales destinados a registrar cambios relevantes y facilitar la comunicación técnica entre sesiones de trabajo.

---

# 🔐 Consideraciones de seguridad

La arquitectura evita incluir datos sensibles directamente dentro de modelos compartidos.

No deberían almacenarse como parte de modelos de interfaz:

- contraseñas;
- CVV;
- PIN;
- números completos de tarjeta;
- tokens;
- API keys;
- secretos de servicios.

Una futura implementación de autenticación o pagos deberá utilizar mecanismos especializados para estos datos.

---

# 🚀 Ejecución local

## 1. Clonar el repositorio

```powershell
git clone https://github.com/AndresRafLopMaz/pdm2026d-equipo-05-giftify.git
```

## 2. Entrar al proyecto Flutter

```powershell
cd pdm2026d-equipo-05-giftify\giftify
```

## 3. Descargar dependencias

```powershell
flutter pub get
```

## 4. Verificar Flutter

```powershell
flutter doctor
```

## 5. Ejecutar la aplicación

```powershell
flutter run
```

---

# 📐 Principios de diseño del proyecto

Giftify se plantea bajo los siguientes principios:

1. **Modularidad**  
   Cada funcionalidad debe vivir en su propio espacio.

2. **Separación de responsabilidades**  
   Navegación, tema, modelos, datos y pantallas no deben mezclarse innecesariamente.

3. **Contratos claros entre pantallas**  
   Los datos deben intercambiarse mediante modelos conocidos.

4. **Frontend desacoplado**  
   La interfaz debe poder desarrollarse y probarse sin depender completamente de un backend.

5. **Evolución incremental**  
   La arquitectura debe permitir incorporar persistencia, autenticación, APIs o manejo de estado cuando realmente sean necesarios.

6. **Reutilización**  
   Elementos compartidos deben ubicarse en `shared/` o `core/`, evitando duplicación.

7. **Validación continua**  
   El proyecto debe mantenerse compatible con `flutter analyze` y `flutter test`.

---

# 🧠 Visión técnica

La arquitectura general puede resumirse así:

```text
                    GiftifyApp
                        │
                        ▼
                    AppRouter
                        │
            ┌───────────┼───────────┐
            ▼           ▼           ▼
        Features      Shared       Core
            │           │           │
            │           │           ├── Theme
            │           │           └── Backend
            │           │
            │           ├── Models
            │           ├── Enums
            │           └── Data
            │
            ├── Auth
            ├── Home
            ├── Search
            ├── Products
            └── Cart
```

La intención es mantener Giftify como una aplicación **comprensible, extensible y fácil de integrar**, evitando complejidad innecesaria durante sus primeras etapas de construcción.
