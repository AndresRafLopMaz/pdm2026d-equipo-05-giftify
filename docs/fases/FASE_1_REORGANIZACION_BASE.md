# Giftify — Fase 1: Reorganización de la estructura base

## 1. Propósito de este documento

Este documento describe la lógica, objetivos, decisiones y resultado esperado de la **Fase 1 de reorganización estructural del proyecto Giftify**.

Su finalidad principal es servir como **contexto reutilizable para una IA, un integrante nuevo del equipo o una futura sesión de trabajo**, de forma que sea posible comprender por qué se reorganizó el proyecto, qué problemas intentaba resolver esa reorganización y cuáles son las reglas que deben respetarse después.

> **Importante:** esta fase no buscó desarrollar funcionalidades completas. Su objetivo fue transformar un proyecto Flutter inicialmente concentrado en pocos archivos en una base modular preparada para trabajo colaborativo entre cuatro integrantes.

---

# 2. Contexto general del proyecto

Giftify es una aplicación móvil desarrollada con **Flutter** para apoyar el proceso de búsqueda y selección de regalos.

El proyecto se organiza académicamente alrededor de siete pantallas principales:

1. Registro de usuario.
2. Pantalla principal / guía de uso.
3. Personalización de búsqueda.
4. Resultados personalizados.
5. Detalle de producto.
6. Carrito de compras.
7. Check-out.

La distribución de responsabilidades prevista es:

| Integrante | Responsabilidad |
|---|---|
| Diego Barrios | Pantalla 1 |
| Brayan Chaclan | Pantallas 2 y 3 |
| Andrés López | Pantallas 4 y 5 |
| Catherine Coti | Pantallas 6 y 7 |

La necesidad de reorganizar el repositorio surgió porque el proyecto Flutter existente concentraba gran parte de la interfaz en un archivo de gran tamaño, principalmente `home.dart`, lo cual aumentaba el riesgo de conflictos al trabajar con varias ramas.

---

# 3. Problema técnico detectado antes de esta fase

La estructura inicial de `lib/` era aproximadamente:

```text
lib/
├── app.dart
├── home.dart
├── main.dart
└── theme.dart
```

Esta estructura era suficiente para un prototipo inicial, pero no era adecuada para cuatro personas trabajando en paralelo.

Los principales riesgos eran:

- múltiples integrantes modificando el mismo archivo;
- conflictos frecuentes durante `merge`;
- dificultad para identificar qué código pertenece a cada pantalla;
- navegación definida de forma dispersa;
- componentes globales mezclados con componentes específicos;
- dificultad para dar instrucciones precisas a una IA de programación;
- crecimiento desordenado del proyecto.

La meta de esta fase fue reducir estos riesgos antes de crear las ramas personales.

---

# 4. Principio arquitectónico aplicado

La reorganización se realizó siguiendo una estructura **orientada a funcionalidades**.

Esto significa que las carpetas principales no se nombran por persona, sino por responsabilidad funcional.

La razón es que el código debe seguir teniendo sentido aunque cambien los integrantes del equipo.

Ejemplo correcto:

```text
features/
├── auth/
├── home/
├── search/
├── products/
└── cart/
```

Ejemplo que se evitó:

```text
features/
├── diego/
├── brayan/
├── andres/
└── catherine/
```

La segunda opción acoplaría la arquitectura del software a la organización temporal del equipo.

---

# 5. Rama utilizada para la reorganización

La reorganización se realizó en una rama temporal separada de `main`:

```text
chore/reorganizacion-base
```

La lógica de esta decisión es la siguiente:

```text
main
 │
 └── chore/reorganizacion-base
          │
          ├── reorganizar
          ├── validar
          ├── probar
          └── integrar posteriormente
```

De esta forma:

- `main` permanece estable;
- los cambios estructurales pueden revisarse antes de integrarlos;
- es posible revertir o corregir la reorganización sin afectar directamente la rama principal;
- las futuras ramas personales se crearán desde una base común ya validada.

---

# 6. Estructura objetivo creada en esta fase

La estructura principal preparada fue:

```text
giftify/
└── lib/
    ├── main.dart
    │
    ├── app/
    │   ├── app_router.dart
    │   └── giftify_app.dart
    │
    ├── core/
    │   └── theme/
    │       └── app_theme.dart
    │
    └── features/
        ├── auth/
        │   └── screens/
        │       └── register_screen.dart
        │
        ├── home/
        │   └── screens/
        │       └── home_screen.dart
        │
        ├── search/
        │   └── screens/
        │       └── gift_search_screen.dart
        │
        ├── products/
        │   └── screens/
        │       ├── product_results_screen.dart
        │       └── product_detail_screen.dart
        │
        └── cart/
            └── screens/
                ├── cart_screen.dart
                └── checkout_screen.dart
```

---

# 7. Responsabilidad de cada carpeta

## `lib/main.dart`

Es el punto de entrada de la aplicación.

Su responsabilidad debe mantenerse mínima:

```dart
void main() {
  runApp(const GiftifyApp());
}
```

No debe contener:

- lógica de negocio;
- navegación compleja;
- widgets de pantallas;
- datos mock;
- configuración específica de productos.

## `lib/app/`

Contiene elementos globales de la aplicación.

### `giftify_app.dart`

Responsable de configurar:

- `MaterialApp`;
- tema;
- ruta inicial;
- router general;
- título de la aplicación.

La aplicación se renombró de forma consistente como **Giftify**.

### `app_router.dart`

Centraliza las rutas de navegación.

Su objetivo es evitar que cada integrante implemente su propio sistema de rutas.

## `lib/core/`

Contiene infraestructura transversal.

En esta fase se movió aquí:

```text
core/theme/app_theme.dart
```

El tema no pertenece a una pantalla específica y debe ser compartido por toda la aplicación.

## `lib/features/`

Cada subcarpeta corresponde a una funcionalidad específica.

### `auth/`
Pantalla 1. Responsable principal: **Diego Barrios**.

### `home/`
Pantalla 2. Responsable principal: **Brayan Chaclan**.

### `search/`
Pantalla 3. Responsable principal: **Brayan Chaclan**.

### `products/`
Pantallas 4 y 5. Responsable principal: **Andrés López**.

### `cart/`
Pantallas 6 y 7. Responsable principal: **Catherine Coti**.

---

# 8. Reutilización de la pantalla existente

El archivo original:

```text
lib/home.dart
```

contenía una gran parte del prototipo existente.

En lugar de eliminar ese trabajo, se movió a:

```text
lib/features/home/screens/home_screen.dart
```

También se ajustó el nombre de la clase:

```text
MainScreen
```

a:

```text
HomeScreen
```

La intención fue conservar el trabajo visual existente, pero ubicarlo en una arquitectura compatible con el desarrollo modular.

---

# 9. Creación de placeholders

Para las pantallas que todavía no estaban desarrolladas se crearon archivos mínimos o **placeholders**.

Un placeholder es una pantalla temporal cuya función es:

- reservar la ubicación definitiva del archivo;
- definir el nombre de la clase;
- permitir que el router compile;
- evitar que cada integrante cree estructuras incompatibles;
- preparar la navegación antes del desarrollo completo.

Estos placeholders **no representan la implementación final**.

---

# 10. Centralización de navegación

Se creó:

```text
lib/app/app_router.dart
```

junto con constantes como:

```dart
AppRoutes.register
AppRoutes.home
AppRoutes.search
AppRoutes.productResults
AppRoutes.productDetail
AppRoutes.cart
AppRoutes.checkout
```

El objetivo es que ninguna pantalla escriba rutas manualmente si ya existe una constante central.

---

# 11. Decisión sobre la ruta inicial

Durante esta fase se mantuvo:

```dart
initialRoute: AppRoutes.home
```

La razón fue evitar que la aplicación comenzara en una pantalla de registro todavía no implementada.

Posteriormente, cuando exista autenticación real o simulada, podrá evaluarse un flujo como:

```text
¿Existe sesión?
    │
 ┌──┴──┐
 │     │
No    Sí
 │     │
Registro
       │
       └── Home
```

---

# 12. Normalización de finales de línea

Durante la reorganización aparecieron advertencias relacionadas con:

```text
LF
CRLF
```

Para evitar diferencias innecesarias entre sistemas operativos se agregó:

```text
.gitattributes
```

Propósito:

- reducir cambios falsos en Git;
- evitar que cientos de líneas aparezcan modificadas solo por saltos de línea;
- mejorar la integración entre equipos Windows/Linux/macOS;
- facilitar el trabajo con herramientas automáticas.

---

# 13. Archivos generados por Flutter

Durante comandos como:

```powershell
flutter pub get
```

Flutter puede modificar archivos generados en:

```text
linux/flutter/
macos/Flutter/
windows/flutter/
```

Estos cambios no estaban relacionados con la reorganización y fueron restaurados.

Regla para futuras sesiones:

> No incluir archivos generados automáticamente en un commit si el cambio no está relacionado con ellos.

---

# 14. Prueba de arranque

Se agregó una prueba básica:

```text
test/app_smoke_test.dart
```

Un **smoke test** verifica que la aplicación pueda iniciar correctamente sin errores estructurales.

La prueba debe centrarse en widgets estructurales como `MaterialApp` y `HomeScreen`, no en textos visuales demasiado específicos.

---

# 15. Validaciones utilizadas

La reorganización debe considerarse segura únicamente después de ejecutar:

```powershell
flutter analyze
flutter test
git diff --check
```

Resultados esperados:

```text
No issues found!
All tests passed!
```

---

# 16. Decisiones deliberadamente NO tomadas

En esta fase no se agregó:

- Firebase;
- REST API;
- Dio;
- `http`;
- Riverpod;
- Provider;
- BLoC;
- base de datos;
- autenticación;
- repositorios;
- servicios complejos.

La razón fue mantener el proyecto en una etapa temprana y enfocada en frontend.

---

# 17. Resultado arquitectónico de la fase

Antes:

```text
lib/
├── app.dart
├── home.dart
├── main.dart
└── theme.dart
```

Después:

```text
lib/
├── main.dart
├── app/
├── core/
└── features/
```

El principal beneficio no es solamente estético.

La reorganización permite que:

```text
Diego      → auth/
Brayan     → home/ + search/
Andrés     → products/
Catherine  → cart/
```

trabajen con menor probabilidad de editar los mismos archivos.

---

# 18. Reglas para una IA que reciba este documento

1. No volver a concentrar múltiples pantallas en un archivo global.
2. No mover carpetas sin justificar el cambio.
3. No crear otro router.
4. No crear otro tema global si `app_theme.dart` ya cubre la necesidad.
5. No reemplazar la arquitectura `features/` sin una decisión explícita del equipo.
6. No desarrollar funcionalidades de otros integrantes de forma automática.
7. Antes de agregar dependencias, explicar por qué son necesarias.
8. Mantener `main.dart` mínimo.
9. Ejecutar `flutter analyze` y `flutter test` después de cambios estructurales.
10. Mostrar `git diff` antes de recomendar un commit.

---

# 19. Resumen de la Fase 1

La Fase 1 convirtió Giftify de un prototipo concentrado en pocos archivos en una base modular.

La lógica principal fue:

```text
proyecto monolítico inicial
        ↓
identificar responsabilidades
        ↓
separar infraestructura
        ↓
separar funcionalidades
        ↓
crear rutas centrales
        ↓
crear placeholders
        ↓
validar
```

Esta fase es la base sobre la que se construyeron posteriormente los modelos compartidos, los datos simulados y el contrato de navegación.
