# 🎁 Giftify

Aplicación móvil desarrollada con **Flutter** para apoyar la búsqueda, comparación y selección de regalos de acuerdo con el destinatario, la ocasión, el presupuesto y otras restricciones relevantes.

> Proyecto académico del curso **Programación de Dispositivos Móviles**, 8.º semestre de Ingeniería en Sistemas — Universidad Mesoamericana, Sección D, Equipo 05.

---

## 📌 Estado actual

Giftify se encuentra en una **fase temprana de desarrollo**, con énfasis actual en **frontend, arquitectura e integración entre pantallas**.

La base común del proyecto ya incluye:

- estructura modular por funcionalidades;
- tema visual compartido;
- navegación centralizada;
- modelos de datos compartidos;
- catálogo local de productos simulados;
- espacio básico reservado para backend;
- pruebas iniciales de arranque, modelos y navegación;
- bitácoras individuales por integrante;
- documentación técnica de las fases iniciales.

El backend real, autenticación, persistencia, pagos y consumo de API **todavía no forman parte de la implementación funcional actual**.

---

## 🎯 Problema que aborda

Al elegir un regalo con una fecha límite, una persona puede encontrar:

- información de disponibilidad desactualizada;
- diferencias entre lo publicado y el producto real;
- múltiples alternativas difíciles de comparar;
- información dispersa;
- respuestas tardías de vendedores;
- restricciones de presupuesto, tiempo, tamaño o entrega.

Giftify busca reducir esta incertidumbre mediante una experiencia de búsqueda personalizada y una comparación más clara de alternativas.

---

## 💡 Propuesta de valor

**Ayudar al usuario a encontrar y validar una opción de regalo adecuada antes de realizar la compra**, considerando criterios como:

- ocasión;
- destinatario;
- presupuesto;
- categoría;
- tamaño;
- disponibilidad;
- vendedor;
- calificación;
- tiempo estimado de entrega.

---

# 🧭 Flujo general de la aplicación

El prototipo contempla siete pantallas principales:

```text
1. Registro
      ↓
2. Inicio / guía
      ↓
3. Personalización de búsqueda
      ↓
4. Resultados personalizados
      ↓
5. Detalle del producto
      ↓
6. Carrito
      ↓
7. Check-out
```

También se contemplan recorridos secundarios, por ejemplo:

```text
Resultados → modificar criterios
Resultados → detalle
Resultados → carrito
Detalle → carrito
Carrito → detalle
Carrito → check-out
```

---

# 👥 Equipo y distribución de pantallas

El proyecto se desarrolla actualmente con **4 integrantes**.

| Integrante | Rama de trabajo | Pantallas | Módulo principal |
|---|---|---:|---|
| Diego Barrios | `diego` | 1 | `features/auth/` |
| Brayan Chaclan | `brayan` | 2 y 3 | `features/home/` y `features/search/` |
| Andrés López | `andres` | 4 y 5 | `features/products/` |
| Catherine Coti | `catherine` | 6 y 7 | `features/cart/` |

> Cada integrante tiene una zona principal de trabajo, pero algunos archivos son compartidos y deben modificarse con coordinación.

---

# 🧱 Tecnologías

## Principales

- **Flutter**
- **Dart**
- **Material 3**
- **Git**
- **GitHub**

## Estado actual de dependencias

El proyecto mantiene una configuración deliberadamente sencilla.

Por el momento **no se han incorporado** gestores de estado o clientes HTTP externos como:

- Provider;
- Riverpod;
- BLoC;
- Dio;
- Firebase;
- Supabase.

Estas tecnologías solo se agregarán cuando exista una necesidad concreta y acordada por el equipo.

---

# 🗂️ Arquitectura actual

La estructura principal se organiza por funcionalidades:

```text
pdm2026d-equipo-05-giftify/
│
├── docs/
│   ├── bitacoras/
│   │   ├── ANDRES.md
│   │   ├── BRAYAN.md
│   │   ├── CATHERINE.md
│   │   └── DIEGO.md
│   │
│   └── fases/
│       ├── FASE_1_REORGANIZACION_BASE.md
│       ├── FASE_2_MODELOS_MOCKS_BACKEND.md
│       └── FASE_3_CONTRATO_NAVEGACION.md
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
    │   │   │   └── mock_products.dart
    │   │   │
    │   │   ├── enums/
    │   │   │   ├── gift_availability.dart
    │   │   │   └── payment_method_type.dart
    │   │   │
    │   │   └── models/
    │   │       ├── cart_item.dart
    │   │       ├── delivery_address.dart
    │   │       ├── gift_product.dart
    │   │       ├── gift_search_criteria.dart
    │   │       └── user_profile.dart
    │   │
    │   └── features/
    │       ├── auth/
    │       │   └── screens/
    │       │       └── register_screen.dart
    │       │
    │       ├── home/
    │       │   └── screens/
    │       │       └── home_screen.dart
    │       │
    │       ├── search/
    │       │   └── screens/
    │       │       └── gift_search_screen.dart
    │       │
    │       ├── products/
    │       │   └── screens/
    │       │       ├── product_results_screen.dart
    │       │       └── product_detail_screen.dart
    │       │
    │       └── cart/
    │           └── screens/
    │               ├── cart_screen.dart
    │               └── checkout_screen.dart
    │
    ├── test/
    │   ├── app_smoke_test.dart
    │   ├── navigation_contract_test.dart
    │   └── shared_models_test.dart
    │
    └── pubspec.yaml
```

---

# 🧩 Responsabilidad de las capas

## `app/`

Configuración global de Giftify.

Incluye:

- `MaterialApp`;
- rutas;
- navegación central;
- configuración de arranque.

No deben crearse otros routers globales ni otros `MaterialApp` sin una decisión explícita del equipo.

---

## `core/`

Infraestructura transversal.

Actualmente contiene:

### `theme/`

Tema visual compartido.

### `backend/`

Espacio mínimo reservado para una futura API.

> La existencia de `backend/` **no significa que Giftify ya tenga backend funcional**.

---

## `shared/`

Elementos utilizados por más de un módulo.

Contiene:

- modelos;
- enums;
- datos mock.

Antes de crear un nuevo modelo debe verificarse que no exista ya uno equivalente en esta carpeta.

---

## `features/`

Contiene el desarrollo específico de cada funcionalidad o pantalla.

Esta separación permite que los integrantes trabajen en paralelo con menor riesgo de conflictos de Git.

---

# 🔄 Contratos de datos entre pantallas

El proyecto ya define modelos compartidos para evitar que cada módulo utilice estructuras incompatibles.

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

## Modelos principales

### `GiftSearchCriteria`

Contiene criterios como:

- ocasión;
- destinatario;
- presupuesto;
- fecha;
- tipo de regalo;
- tamaño.

### `GiftProduct`

Representa un producto recomendado.

Incluye:

- nombre;
- descripción;
- precio;
- categoría;
- tamaño;
- disponibilidad;
- vendedor;
- calificación;
- ocasiones sugeridas;
- tiempo estimado de entrega.

### `CartItem`

Relaciona un `GiftProduct` con una cantidad.

### `DeliveryAddress`

Representa una dirección de entrega.

### `UserProfile`

Representa información general del usuario.

No contiene contraseñas, CVV, PIN ni números completos de tarjeta.

---

# 🧪 Datos mock

Durante el desarrollo frontend se utiliza:

```text
lib/shared/data/mock_products.dart
```

Este archivo permite trabajar sin depender de una API real.

Los mocks incluyen distintos escenarios:

- disponible;
- poco stock;
- agotado;
- disponibilidad desconocida;
- distintos precios;
- distintos vendedores;
- diferentes tiempos de entrega.

La intención es sustituir o adaptar esta fuente cuando exista backend real.

---

# 🌐 Backend

Giftify está actualmente enfocado en frontend.

Se preparó únicamente:

```text
core/backend/
├── backend_client.dart
└── backend_config.dart
```

La URL futura podrá proporcionarse mediante:

```powershell
flutter run --dart-define=GIFTIFY_API_BASE_URL=https://api.ejemplo.com
```

Actualmente `BackendClient` **no realiza solicitudes HTTP**.

No se deben realizar llamadas de red directamente desde widgets.

---

# 🧭 Navegación

Todas las rutas se concentran en:

```text
lib/app/app_router.dart
```

Se utilizan constantes como:

```dart
AppRoutes.register
AppRoutes.home
AppRoutes.search
AppRoutes.productResults
AppRoutes.productDetail
AppRoutes.cart
AppRoutes.checkout
```

Ejemplo recomendado:

```dart
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: selectedProduct,
);
```

Evitar escribir rutas manualmente si ya existe una constante.

---

# 🌿 Estrategia de ramas

`main` representa la base integrada y estable.

El trabajo individual se realizará en:

```text
main
├── diego
├── brayan
├── andres
└── catherine
```

## Regla principal

> **No desarrollar directamente sobre `main`.**

Cada integrante trabaja en su rama y posteriormente integra mediante Pull Request.

Flujo recomendado:

```text
Actualizar rama
      ↓
Desarrollar
      ↓
Revisar git diff
      ↓
flutter analyze
      ↓
flutter test
      ↓
Actualizar bitácora
      ↓
Commit
      ↓
Push
      ↓
Pull Request
      ↓
Revisión
      ↓
Merge a main
```

---

# 📝 Bitácoras de trabajo

Cada integrante dispone de un archivo en:

```text
docs/bitacoras/
```

Correspondencia:

```text
Andrés    → ANDRES.md
Brayan    → BRAYAN.md
Catherine → CATHERINE.md
Diego     → DIEGO.md
```

Cada integrante debe actualizar **únicamente su propia bitácora**.

La bitácora debe conservar el historial y registrar, como mínimo:

- fecha o sesión;
- objetivo;
- trabajo realizado;
- archivos modificados;
- decisiones técnicas;
- pruebas ejecutadas;
- pendientes;
- cambios que afecten a otros módulos.

No deben registrarse:

- contraseñas;
- tokens;
- API keys;
- credenciales;
- secretos.

---

# 📚 Documentación técnica

Las primeras decisiones arquitectónicas se documentan en:

```text
docs/fases/
```

Actualmente existen:

1. `FASE_1_REORGANIZACION_BASE.md`
2. `FASE_2_MODELOS_MOCKS_BACKEND.md`
3. `FASE_3_CONTRATO_NAVEGACION.md`

Estos documentos sirven como contexto para integrantes o asistentes de IA antes de realizar cambios estructurales.

---

# 🤖 Uso de inteligencia artificial

Se permite utilizar IA como apoyo durante el desarrollo.

Ejemplos:

- OpenCode;
- ChatGPT;
- otras herramientas compatibles con el flujo de trabajo del equipo.

La IA debe utilizarse como **asistente**, no como sustituto de la revisión técnica.

## Reglas mínimas para una IA

Antes de modificar código debe:

1. revisar la estructura existente;
2. identificar la rama activa;
3. identificar el módulo del integrante;
4. revisar los modelos compartidos;
5. evitar crear estructuras duplicadas;
6. proponer un plan antes de cambios amplios.

Después de modificar código debe:

1. ejecutar o solicitar `dart format`;
2. ejecutar `flutter analyze`;
3. ejecutar `flutter test`;
4. revisar `git diff`;
5. indicar qué archivos fueron modificados;
6. actualizar la bitácora del integrante correspondiente.

La IA **no debe modificar módulos de otros integrantes de forma innecesaria**.

---

# ✅ Validación mínima antes de un commit

Desde la carpeta `giftify/`:

```powershell
dart format lib test
flutter analyze
flutter test
```

Desde la raíz del repositorio:

```powershell
git status
git diff --check
git diff --name-status
```

El objetivo es obtener:

```text
No issues found!
All tests passed!
```

---

# 🚀 Ejecutar el proyecto

## 1. Clonar

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

## 4. Verificar entorno

```powershell
flutter doctor
```

## 5. Ejecutar

```powershell
flutter run
```

---

# 🧪 Pruebas

Ejecutar:

```powershell
flutter test
```

Las pruebas iniciales cubren:

- arranque de Giftify;
- modelos compartidos;
- contrato básico de navegación.

---

# 🎨 Estado de las pantallas

| # | Pantalla | Responsable | Estado base |
|---:|---|---|---|
| 1 | Registro | Diego | estructura preparada |
| 2 | Inicio | Brayan | implementación inicial existente |
| 3 | Personalización | Brayan | estructura preparada |
| 4 | Resultados | Andrés | estructura preparada |
| 5 | Detalle | Andrés | estructura preparada |
| 6 | Carrito | Catherine | estructura preparada |
| 7 | Check-out | Catherine | estructura preparada |

> “Estructura preparada” significa que existen los archivos, rutas y contratos necesarios; no implica que la interfaz final esté implementada.

---

# ⚠️ Consideraciones actuales

- El foco inmediato es **frontend**.
- Los datos actuales son simulados.
- No existe autenticación real.
- No existe backend funcional.
- No existe persistencia de carrito.
- Los pagos no son reales.
- Los Issues existentes de GitHub pueden reflejar temporalmente una versión anterior del alcance y serán actualizados posteriormente.
- Los cambios en `app/`, `core/` o `shared/` deben tratarse como cambios de integración y revisarse con especial cuidado.

---

# 📌 Próximos pasos

1. Crear y publicar las ramas:
   - `diego`
   - `brayan`
   - `andres`
   - `catherine`
2. Preparar las instrucciones específicas de trabajo para cada integrante.
3. Actualizar posteriormente los Issues al nuevo alcance.
4. Desarrollar las siete pantallas de forma paralela.
5. Integrar mediante Pull Requests.
6. Mantener actualizadas las bitácoras.
7. Evaluar backend y estado global únicamente cuando sean necesarios.

---

## 👨‍💻 Filosofía de desarrollo

Giftify debe crecer de forma incremental:

```text
Prototipo
   ↓
Arquitectura común
   ↓
Frontend modular
   ↓
Integración
   ↓
Validación
   ↓
Backend cuando sea necesario
```

La prioridad es mantener una base **comprensible, modular, verificable y fácil de integrar** para todos los integrantes del equipo.
