# Giftify — Guía de desarrollo para Diego Barrios

## 1. Identificación de la tarea

**Proyecto:** Giftify  
**Tecnología principal:** Flutter + Dart  
**Integrante:** Diego Barrios  
**Rama de trabajo:** `diego`  
**Pantalla asignada:** Pantalla 1 — Registro de usuario  
**Zona principal de trabajo:** `giftify/lib/features/auth/`  
**Bitácora personal:** `docs/bitacoras/DIEGO.md`

Este documento sirve como **guía técnica, contexto del proyecto e instrucciones de trabajo para una IA de apoyo**, por ejemplo OpenCode conectado a una API.

La intención es que Diego pueda entregar este archivo a su IA al iniciar una sesión y que la herramienta comprenda:

- qué es Giftify;
- qué problema resuelve;
- cómo está organizado el repositorio;
- qué parte corresponde a Diego;
- qué archivos puede consultar;
- qué archivos puede modificar;
- qué archivos debe evitar;
- cómo debe funcionar la pantalla de registro;
- cómo simular de forma sencilla el comportamiento del backend;
- cómo probar el resultado;
- cómo dividir el trabajo en fases y commits con valor;
- cómo registrar lo realizado en la bitácora.

> **Regla principal:** este documento no autoriza a la IA a reorganizar el proyecto ni a trabajar fuera del alcance de Diego sin una justificación técnica explícita y aprobación humana.

---

# 2. Contexto general de Giftify

Giftify es una aplicación móvil orientada a apoyar la elección de regalos de forma personalizada.

La aplicación parte de un problema observado durante entrevistas: elegir un regalo no consiste únicamente en encontrar una idea, sino en tomar una decisión confiable bajo restricciones como:

- presupuesto;
- destinatario;
- ocasión;
- fecha límite;
- tamaño o facilidad de transporte;
- disponibilidad real;
- confiabilidad del vendedor;
- tiempo de entrega.

El recorrido general de la aplicación contempla siete pantallas:

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
6. Carrito
        ↓
7. Check-out
```

La pantalla de Diego corresponde al punto de entrada del usuario.

Su propósito no es resolver todo el flujo de autenticación de una aplicación real, sino permitir que Giftify disponga de una **experiencia de registro coherente con el prototipo**, con validaciones básicas y una transición clara hacia la pantalla principal.

---

# 3. Objetivo funcional de la Pantalla 1

La pantalla de registro debe permitir que un usuario cree un perfil básico mediante los campos definidos por el prototipo:

- nombre;
- correo electrónico;
- contraseña;
- fecha de nacimiento.

También debe contemplarse visualmente la alternativa:

```text
¿Ya tienes una cuenta? Inicia sesión aquí
```

Sin embargo, salvo que el equipo decida ampliar el alcance, **no es necesario implementar una autenticación real ni un sistema completo de login**.

El comportamiento esperado puede ser:

```text
Usuario abre Giftify
        ↓
Pantalla de registro
        ↓
Completa datos
        ↓
Validaciones locales
        ↓
Registro simulado
        ↓
Se construye un UserProfile
        ↓
Navegación a Home
```

---

# 4. Resultado esperado

Al finalizar el trabajo de Diego, debe existir una pantalla de registro que:

1. respete el estilo visual general de Giftify;
2. permita capturar los cuatro campos definidos;
3. valide los datos esenciales;
4. muestre mensajes de error claros;
5. permita seleccionar fecha de nacimiento;
6. simule un registro exitoso;
7. construya un `UserProfile` compatible con los modelos compartidos;
8. navegue hacia `HomeScreen` utilizando el router existente;
9. no dependa de un backend real;
10. pueda probarse mediante `flutter analyze`, `flutter test` y prueba manual.

---

# 5. Rama de trabajo

Diego debe trabajar únicamente en:

```text
diego
```

Antes de modificar cualquier archivo:

```powershell
git switch diego
git pull
git status
```

El estado esperado:

```text
On branch diego
nothing to commit, working tree clean
```

No debe desarrollarse directamente sobre `main`.

---

# 6. Estructura relevante del repositorio

La aplicación Flutter vive dentro de:

```text
giftify/
```

La estructura importante para esta tarea es:

```text
giftify/lib/
│
├── main.dart
│
├── app/
│   ├── app_router.dart
│   └── giftify_app.dart
│
├── core/
│   ├── backend/
│   │   ├── backend_client.dart
│   │   └── backend_config.dart
│   │
│   └── theme/
│       └── app_theme.dart
│
├── shared/
│   ├── data/
│   ├── enums/
│   └── models/
│       ├── cart_item.dart
│       ├── delivery_address.dart
│       ├── gift_product.dart
│       ├── gift_search_criteria.dart
│       └── user_profile.dart
│
└── features/
    ├── auth/
    │   └── screens/
    │       └── register_screen.dart
    ├── home/
    ├── search/
    ├── products/
    └── cart/
```

---

# 7. Archivos que la IA debe leer antes de programar

Antes de modificar código, la IA debe revisar como mínimo:

```text
README.md
docs/fases/FASE_1_REORGANIZACION_BASE.md
docs/fases/FASE_2_MODELOS_MOCKS_BACKEND.md
docs/fases/FASE_3_CONTRATO_NAVEGACION.md
giftify/lib/app/app_router.dart
giftify/lib/app/giftify_app.dart
giftify/lib/core/theme/app_theme.dart
giftify/lib/shared/models/user_profile.dart
giftify/lib/features/auth/screens/register_screen.dart
giftify/lib/features/home/screens/home_screen.dart
```

También debe revisar:

```text
giftify/test/
```

para entender el estilo de pruebas existente.

---

# 8. Archivos que Diego puede modificar normalmente

Zona principal:

```text
giftify/lib/features/auth/
```

Especialmente:

```text
giftify/lib/features/auth/screens/register_screen.dart
```

Si la implementación lo justifica, puede crear archivos adicionales dentro de su módulo, por ejemplo:

```text
giftify/lib/features/auth/
├── screens/
├── widgets/
└── data/
```

Sin embargo, debe mantenerse simple.

No crear subcarpetas innecesarias únicamente por “arquitectura”.

Una estructura razonable podría ser:

```text
features/auth/
├── screens/
│   └── register_screen.dart
└── widgets/
    └── auth_text_field.dart
```

solo si realmente existe reutilización.

---

# 9. Archivos compartidos que puede modificar solo si es necesario

Estos archivos pueden afectar a otros integrantes:

```text
giftify/lib/app/app_router.dart
giftify/lib/app/giftify_app.dart
giftify/lib/core/theme/app_theme.dart
giftify/lib/shared/models/user_profile.dart
```

Regla:

> Si Diego necesita modificar alguno de estos archivos, la IA debe explicar primero por qué el cambio es necesario y qué impacto puede tener.

No modificar un archivo compartido solo para resolver un detalle visual local.

---

# 10. Archivos que Diego no debe modificar como parte normal de su trabajo

Evitar cambios en:

```text
giftify/lib/features/home/
giftify/lib/features/search/
giftify/lib/features/products/
giftify/lib/features/cart/
```

Estas carpetas pertenecen a otros módulos.

También evitar:

```text
linux/
macos/
windows/
android/
ios/
web/
```

salvo que exista una necesidad de plataforma explícita.

---

# 11. Stack técnico

## Flutter

Framework principal de interfaz.

## Dart

Lenguaje utilizado por Flutter.

## Material 3

Sistema visual base de la aplicación.

## Navigator / rutas nombradas

La navegación se centraliza con:

```text
AppRouter
AppRoutes
```

## Estado local

Para esta pantalla, usar primero estado local de Flutter:

```dart
StatefulWidget
TextEditingController
setState()
```

No agregar Provider, Riverpod, BLoC, GetX u otro gestor de estado sin necesidad.

## Datos locales

El registro inicial puede resolverse con lógica local simulada.

No se requiere una API real.

---

# 12. Estilo visual

La pantalla debe conservar la identidad visual de Giftify.

Antes de elegir colores directamente, revisar:

```text
giftify/lib/core/theme/app_theme.dart
```

La pantalla debe intentar reutilizar los colores y estilos disponibles.

El prototipo original contempla una estética clara, con presencia de:

- verde;
- rosa;
- amarillo;
- fondos claros;
- campos de entrada suaves;
- botones grandes y visibles.

No es necesario copiar el prototipo al píxel.

La prioridad es mantener:

- jerarquía visual;
- consistencia;
- legibilidad;
- espaciado adecuado;
- adaptabilidad a pantallas pequeñas.

---

# 13. Campos del formulario

## Nombre

Tipo:

```text
Texto
```

Validación mínima:

- obligatorio;
- no aceptar una cadena vacía;
- puede exigirse un mínimo razonable de caracteres.

Ejemplo de error:

```text
Ingresa tu nombre.
```

---

## Correo electrónico

Validación mínima:

- obligatorio;
- formato básico de correo;
- eliminar espacios externos.

No es necesario implementar validación compleja RFC.

Ejemplo:

```text
usuario@correo.com
```

---

## Contraseña

Validación mínima recomendada:

- obligatoria;
- mínimo 6 u 8 caracteres;
- permitir ocultar/mostrar contraseña.

No se debe:

- guardar en `UserProfile`;
- imprimir en consola;
- registrar en la bitácora;
- guardar en mocks.

La contraseña existe solamente para simular el formulario de autenticación.

---

## Fecha de nacimiento

Usar preferiblemente:

```dart
showDatePicker()
```

Consideraciones:

- no permitir una fecha futura;
- mostrar la fecha seleccionada de forma comprensible;
- dejar claro cuándo no se ha elegido una fecha.

No es necesario crear un selector personalizado.

---

# 14. Comportamiento del botón de registro

El botón debe:

1. validar el formulario;
2. comprobar que exista fecha de nacimiento;
3. evitar múltiples envíos simultáneos;
4. simular el proceso de registro;
5. construir un `UserProfile`;
6. navegar a Home.

Ejemplo conceptual:

```dart
final profile = UserProfile(
  id: 'local-user',
  name: name,
  email: email,
  birthDate: birthDate,
);
```

La contraseña no se incluye.

---

# 15. Backend mínimo / simulación

El proyecto ya contiene:

```text
core/backend/
```

pero Diego no necesita implementar una API real.

La solución más sencilla es simular el registro localmente.

Ejemplo conceptual:

```text
Formulario
   ↓
Validar
   ↓
espera breve opcional
   ↓
crear UserProfile
   ↓
navegar
```

Si se quiere representar una operación asíncrona:

```dart
await Future.delayed(
  const Duration(milliseconds: 500),
);
```

Esto es suficiente para probar:

- loading;
- bloqueo de botón;
- transición exitosa.

No confundir esto con un backend real.

---

# 16. Posible separación mínima de lógica

Si la pantalla crece demasiado, puede considerarse una clase local simple, por ejemplo:

```text
features/auth/data/mock_auth_service.dart
```

con algo como:

```dart
Future<UserProfile> register(...)
```

Pero esto es opcional.

La preferencia es:

> mantener el módulo simple mientras el código siga siendo comprensible.

No crear repositories, datasources, DTOs y adapters únicamente para simular un formulario.

---

# 17. Navegación esperada

La aplicación ya define:

```dart
AppRoutes.home
```

La pantalla debe usar el router existente.

Ejemplo:

```dart
Navigator.pushReplacementNamed(
  context,
  AppRoutes.home,
);
```

`pushReplacementNamed` es apropiado si no se desea volver al registro con el botón atrás.

La IA debe revisar el comportamiento del router antes de decidir.

---

# 18. Enlace “Inicia sesión aquí”

El prototipo muestra esta opción.

Como no existe un flujo de login definido todavía, existen opciones simples:

### Opción A
Mostrar el texto como elemento visual no funcional.

### Opción B
Mostrar un `SnackBar`:

```text
Inicio de sesión disponible próximamente.
```

### Opción C
Crear una pantalla de login únicamente si el equipo lo solicita explícitamente.

La IA **no debe inventar una pantalla completa de login por iniciativa propia**.

---

# 19. Responsive

La interfaz debe funcionar razonablemente en teléfonos con diferentes alturas.

Recomendaciones:

- utilizar `SafeArea`;
- utilizar `SingleChildScrollView`;
- evitar alturas fijas excesivas;
- utilizar `Padding`;
- respetar teclado visible;
- evitar overflow vertical.

Se debe probar al menos en un dispositivo o emulador móvil.

---

# 20. Estados mínimos de interfaz

La pantalla debe considerar:

## Estado inicial

Formulario vacío.

## Estado con errores

Campos inválidos muestran mensajes.

## Estado de envío

Botón deshabilitado o indicador de progreso.

## Estado exitoso

Navegación a Home.

No es necesario diseñar un sistema de errores de red porque no existe backend real.

---

# 21. Manejo de errores

Evitar:

```dart
try {
  ...
} catch (_) {}
```

sin información.

Si la simulación local llegara a lanzar un error, mostrar un mensaje comprensible.

No mostrar stack traces al usuario.

---

# 22. Accesibilidad básica

Considerar:

- labels visibles;
- contraste suficiente;
- tamaño legible;
- botones con áreas táctiles razonables;
- campos con `keyboardType` apropiado;
- `TextInputAction`;
- no depender únicamente del color para comunicar error.

---

# 23. Fases recomendadas de trabajo

La guía no pretende forzar un paso a paso rígido.

Se sugieren pocas fases con resultados concretos.

---

## Fase A — Comprensión y preparación

Objetivo:

- revisar documentación;
- revisar arquitectura;
- entender `UserProfile`;
- revisar tema;
- revisar router;
- confirmar rama `diego`.

Resultado:

- plan corto de implementación;
- ningún cambio innecesario.

No requiere commit si no se modifica código.

---

## Fase B — Construcción del frontend

Objetivo:

- implementar estructura visual;
- campos;
- selector de fecha;
- botón;
- enlace de inicio de sesión;
- responsive básico.

Commit sugerido:

```text
feat: implementar interfaz de registro de usuario
```

---

## Fase C — Validaciones y flujo simulado

Objetivo:

- validación del formulario;
- loading;
- construcción de `UserProfile`;
- navegación a Home;
- errores comprensibles.

Commit sugerido:

```text
feat: agregar validaciones y flujo de registro simulado
```

---

## Fase D — Pruebas y ajustes

Objetivo:

- pruebas de widget;
- revisar responsive;
- corregir errores;
- limpiar código.

Commit sugerido:

```text
test: cubrir validaciones principales del registro
```

Si solo se realizan correcciones menores junto con las pruebas, pueden formar parte de este mismo commit.

---

# 24. Cantidad de commits

No se busca producir muchos commits.

Un rango razonable para este módulo:

```text
2 a 4 commits
```

Ejemplo:

```text
feat: implementar interfaz de registro de usuario
feat: agregar validaciones y flujo de registro simulado
test: cubrir validaciones principales del registro
```

Evitar commits como:

```text
cambiar color
arreglar botón
agregar padding
otro cambio
fix
fix2
```

---

# 25. Pruebas recomendadas

## Flutter Analyze

```powershell
flutter analyze
```

Debe finalizar con:

```text
No issues found!
```

---

## Flutter Test

```powershell
flutter test
```

Todos los tests existentes deben continuar pasando.

---

## Widget tests

Diego debería considerar pruebas para:

- renderizado del formulario;
- validación de campos vacíos;
- correo inválido;
- contraseña corta;
- registro válido;
- navegación exitosa si es práctico probarla.

No es necesario probar cada propiedad visual.

---

# 26. Casos manuales mínimos

### Caso 1 — formulario vacío

Esperado:

- no permite registro;
- aparecen mensajes claros.

### Caso 2 — correo inválido

Entrada:

```text
diego@
```

Esperado:

- error de formato.

### Caso 3 — contraseña corta

Esperado:

- error de longitud.

### Caso 4 — fecha futura

Esperado:

- no debería poder seleccionarse o debe rechazarse.

### Caso 5 — datos válidos

Esperado:

- loading breve;
- se crea perfil local;
- navegación a Home.

### Caso 6 — teclado abierto

Esperado:

- no debe producir overflow.

---

# 27. Comandos de validación

Desde:

```text
giftify/
```

ejecutar:

```powershell
dart format lib test
flutter analyze
flutter test
```

Desde la raíz:

```powershell
git status
git diff --check
git diff --name-status
```

Antes del commit:

```powershell
git diff
```

La IA debe explicar los cambios relevantes antes de recomendar un commit.

---

# 28. Uso recomendado de OpenCode / IA

## Modalidad inicial: Plan

Al comenzar una sesión importante, la IA debe trabajar primero en modo de análisis o Plan.

Prompt conceptual:

```text
Lee la guía de Diego, README, documentación de fases, router, tema,
UserProfile y register_screen.dart.

No modifiques archivos todavía.

Analiza el estado actual de la rama diego y propón un plan breve para
implementar la pantalla 1 respetando la arquitectura existente.
Indica qué archivos necesitas modificar y cuáles no debes tocar.
```

---

## Modalidad de implementación: Build

Después de revisar y aprobar el plan:

```text
Implementa únicamente la fase acordada.

No cambies arquitectura global.
No instales dependencias.
No modifiques módulos ajenos.
Ejecuta format, analyze y tests.
Muestra el resumen de git diff.
```

---

# 29. Reglas estrictas para la IA

La IA debe:

1. verificar que la rama sea `diego`;
2. leer el contexto antes de editar;
3. trabajar principalmente en `features/auth/`;
4. utilizar `UserProfile`;
5. utilizar `AppRoutes`;
6. reutilizar el tema existente;
7. evitar dependencias nuevas;
8. evitar duplicar modelos;
9. evitar crear otro router;
10. evitar crear otro `MaterialApp`;
11. evitar tocar módulos ajenos;
12. ejecutar pruebas;
13. revisar `git diff`;
14. actualizar la bitácora.

---

# 30. Qué NO debe hacer la IA

No debe:

- reorganizar el repositorio;
- mover carpetas globales;
- instalar Firebase;
- implementar login real;
- implementar base de datos;
- implementar backend completo;
- almacenar contraseña en texto plano;
- crear otra clase equivalente a `UserProfile`;
- modificar productos, carrito o búsqueda;
- borrar tests para conseguir que pasen;
- hacer commits automáticamente salvo que el usuario se lo solicite;
- realizar merge hacia `main`.

---

# 31. Bitácora obligatoria

Al finalizar una sesión relevante, actualizar:

```text
docs/bitacoras/DIEGO.md
```

No eliminar contenido anterior.

Formato sugerido:

```markdown
## Sesión YYYY-MM-DD

### Objetivo
...

### Trabajo realizado
- ...

### Archivos modificados
- `...`

### Decisiones técnicas
- ...

### Pruebas realizadas
- `flutter analyze` — OK
- `flutter test` — OK

### Pendientes
- ...

### Impacto para otros módulos
- ...
```

La bitácora debe ser breve pero útil.

---

# 32. Información que NO debe ir en la bitácora

Nunca escribir:

- contraseñas;
- tokens;
- claves API;
- secretos;
- credenciales;
- datos personales reales innecesarios.

---

# 33. Criterios de terminado

La tarea puede considerarse lista para revisión cuando:

- la pantalla refleja el prototipo de forma coherente;
- los cuatro campos están implementados;
- existe validación básica;
- la fecha de nacimiento funciona;
- el formulario no presenta overflow;
- el botón de registro tiene feedback;
- se crea un `UserProfile`;
- el flujo continúa hacia Home;
- no existe dependencia de backend real;
- `flutter analyze` pasa;
- `flutter test` pasa;
- los tests relevantes del módulo pasan;
- `git diff --check` está limpio;
- la bitácora está actualizada;
- no se modificaron módulos ajenos sin justificación.

---

# 34. Definición de éxito del módulo

La pantalla de Diego no necesita ser una solución completa de identidad.

Su éxito consiste en proporcionar un **registro frontend funcional, validado, coherente con Giftify y preparado para integrarse con una autenticación real en el futuro sin bloquear el desarrollo actual**.

Arquitectura esperada:

```text
RegisterScreen
      │
      ├── Form
      │   ├── nombre
      │   ├── correo
      │   ├── contraseña
      │   └── fecha nacimiento
      │
      ├── validaciones
      │
      ├── simulación local
      │
      ├── UserProfile
      │
      └── AppRoutes.home
```

---

# 35. Resumen para la IA

Si una IA solo retiene una parte de este documento, debe conservar lo siguiente:

```text
Proyecto: Giftify
Rama: diego
Responsabilidad: Pantalla 1 — Registro
Zona principal: giftify/lib/features/auth/
Modelo principal: UserProfile
Navegación destino: AppRoutes.home
Backend: simulado/local, NO API real
Estado: local con Flutter
Dependencias nuevas: evitar
Arquitectura global: no modificar
Pruebas: format + analyze + flutter test + widget tests útiles
Bitácora: docs/bitacoras/DIEGO.md
```

La prioridad es implementar un frontend sencillo, claro, validado y fácil de integrar.
