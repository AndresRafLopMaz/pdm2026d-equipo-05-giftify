## Sesión 2026-09-24

### Objetivo
Implementar la Pantalla 1 — Registro de usuario de Giftify, con interfaz,
validaciones locales, simulación de registro, navegación y pruebas.

### Trabajo realizado
- Implementación completa de RegisterScreen.
- Formulario con nombre, correo, contraseña y fecha de nacimiento.
- Selector de fecha mediante showDatePicker.
- Opción para mostrar/ocultar contraseña.
- Validaciones locales.
- Contraseña mínima de 8 caracteres.
- Prevención de fechas futuras.
- Estado de envío y protección contra doble envío.
- Simulación local del registro.
- Construcción de UserProfile sin almacenar contraseña.
- Navegación hacia AppRoutes.home después del registro.
- SnackBar temporal para el enlace de inicio de sesión.
- Cambio de la ruta inicial de la aplicación a AppRoutes.register.
- Pruebas de widget del flujo de registro.

### Archivos modificados
- `giftify/lib/features/auth/screens/register_screen.dart`
- `giftify/lib/app/giftify_app.dart`
- `giftify/test/register_screen_test.dart`
- `giftify/test/app_smoke_test.dart`
- `docs/bitacoras/DIEGO.md`

### Decisiones técnicas
- Uso de estado local con StatefulWidget.
- Sin gestor de estado adicional.
- Sin backend real.
- Registro simulado mediante Future.delayed.
- Reutilización de UserProfile existente.
- La contraseña no se almacena en UserProfile.
- Uso del router existente.
- El enlace de login queda temporalmente como SnackBar.
- Cambio de initialRoute a AppRoutes.register para que Registro sea el punto
  de entrada de la aplicación.
- Corrección detectada por pruebas: se ajustó el orden de validación en
  `_submit` para asegurar que `form.validate()` se ejecute incluso cuando no se
  haya seleccionado fecha de nacimiento.

### Pruebas realizadas
- `dart format lib test` — OK
- `flutter analyze` — No issues found!
- `flutter test` — 14/14 pruebas aprobadas
- `git diff --check` — OK

Se agregaron 8 pruebas específicas para RegisterScreen, cubriendo:
- renderizado;
- formulario vacío;
- correo inválido;
- contraseña corta;
- mostrar/ocultar contraseña;
- selector de fecha;
- registro válido y navegación;
- enlace de inicio de sesión.

### Pendientes
- Integración futura con autenticación/backend real, fuera del alcance actual.
- El inicio de sesión real permanece fuera del alcance actual.

### Impacto para otros módulos
- La aplicación ahora inicia en RegisterScreen en lugar de HomeScreen.
- Después de un registro válido continúa hacia HomeScreen.
- No se modificaron módulos de Home, Search, Products o Cart.
- app_router.dart, app_theme.dart y user_profile.dart fueron reutilizados sin
  modificaciones.

## Sesión 2026-10-18

### Objetivo
Cerrar la tarea P1 de Registro del MVP local: agregar una prueba responsive a
320×640, verificar la fila "¿Ya tienes una cuenta?" + "Inicia sesión aquí",
comprobar ausencia de overflow y confirmar el acceso al formulario y al botón
mediante scroll.

### Trabajo realizado
- Se confirmó la rama `diego` sincronizada con `origin/main` (`a3471d0`).
- Línea base ejecutada antes de modificar: formato correcto, análisis sin
  issues y 59 pruebas aprobadas.
- Se agregó una única prueba responsive en `register_screen_test.dart` que:
  - configura `tester.view.physicalSize` en 320×640 y
    `devicePixelRatio` en 1.0;
  - restaura ambos valores con `addTearDown` y las funciones
    `resetPhysicalSize` / `resetDevicePixelRatio`;
  - verifica que no haya excepciones ni overflow;
  - comprueba que ambos textos de la fila de login existan y permanezcan
    dentro del ancho del formulario;
  - comprueba que el formulario siga dentro de `SingleChildScrollView`;
  - desplaza hasta el botón con `ensureVisible` y verifica que sea
    `hitTestable` y que quede dentro de la altura de la pantalla.
- Las 8 pruebas existentes de Registro se conservaron sin cambios.
- `app_smoke_test.dart` se conservó sin cambios.

### Problema encontrado y ajuste aplicado
La prueba nueva falló inicialmente con:
`A RenderFlex overflowed by 307 pixels on the right.`
El error correspondía a la fila de inicio de sesión en
`register_screen.dart:246`, que usaba un `Row` con hijos sin flexibilidad.
Se aplicó el ajuste visual mínimo aprobado: cambiar `Row` por `Wrap` con
`crossAxisAlignment: WrapCrossAlignment.center`. No se modificaron textos,
estilos, validaciones, navegación ni la estructura general de la pantalla.

### Archivos modificados
- `giftify/lib/features/auth/screens/register_screen.dart`
- `giftify/test/register_screen_test.dart`
- `docs/bitacoras/DIEGO.md`

### Decisiones técnicas
- Se usó `Wrap` en lugar de `Flexible` porque permite que el enlace pase a una
  segunda línea cuando el texto es ancho, sin comprimir ni recortar el label.
- No se modificaron archivos compartidos, módulos ajenos, `pubspec.yaml` ni
  `docs/bitacora-ia.md`.
- No se agregaron dependencias ni funcionalidades nuevas.

### Pruebas realizadas (resultados reales)
- `dart format lib test` — 33 archivos revisados, 0 cambios.
- `flutter analyze` — `No issues found!`
- `flutter test test/register_screen_test.dart test/app_smoke_test.dart` —
  10 pruebas aprobadas.
- `flutter test` — 60 pruebas aprobadas, `All tests passed!`
- `git diff --check` — sin errores.

### Pendientes
- P2: aserción explícita del texto de la fecha de nacimiento.
- P2: refactorizar el camino de error del registro simulado.
- Fuera de alcance: autenticación real, persistencia y backend.

### Impacto para otros módulos
- Sin cambios funcionales en Registro: mismas validaciones, mismo flujo de
  envío y misma navegación a Home.
- No se modificaron `app_router.dart`, `giftify_app.dart`, `shared/` ni los
  módulos de otros integrantes.
- El cambio de `Row` a `Wrap` solo afecta la disposición visual de la fila de
  inicio de sesión en pantallas estrechas.

### Uso de IA (para consolidación posterior del equipo)
- Se solicitó un plan y luego la implementación de la tarea P1 de Registro en
  modo BUILD, con alcance cerrado a prueba responsive y ajuste condicional.
- La IA leyó la documentación indicada, verificó la rama y ejecutó la línea
  base antes de editar.
- Se aceptó la prueba responsive propuesta y el cambio `Row` → `Wrap`, que fue
  justificado por un overflow real detectado por la prueba.
- Se rechazó cualquier cambio preventivo de UI antes de ejecutar la prueba, así
  como modificaciones a archivos compartidos o módulos ajenos.
- No se actualizó `docs/bitacora-ia.md` durante el trabajo paralelo; esta
  sección queda para la consolidación final del equipo.

### Cierre de la tarea

- Commit funcional: `4c712d1738943038ab6085dc9ba5a1d2ed7ef39a`.
- Mensaje: `test: cubrir registro en pantalla movil estrecha`.
- Push realizado a `origin/diego`.
- Resultado: la prueba 320×640 detectó un overflow real.
- Corrección: `Row` → `Wrap` en la fila de inicio de sesión.
- Formato: 33 archivos revisados, 0 cambios.
- Analyze: `No issues found!`.
- Tests de la rama en esa validación: 60 aprobadas.
- `git diff --check`: sin errores.

## Sesión 2026-10-25 — QA del Issue #27 (filtro, borrado y Deshacer en Cart)

### Objetivo
Completar la responsabilidad de Diego en el Issue #27: ampliar la cobertura
automatizada del filtro, delete/undo, persistencia, estados asíncronos,
integración con Checkout y responsive 320×640, sin duplicar la implementación
de Catherine.

### Base utilizada
- Rama: `feat/27-filtro-carrito`.
- Commit base de Catherine: `18f5ab389516cc1397deaa3be7f4940b8c207c3f`.
- `HEAD` y `origin/feat/27-filtro-carrito` coincidieron en ese commit durante
  toda la sesión.
- El commit de Catherine es ancestro de `HEAD`; la rama está 1 commit por
  delante de `origin/main` (`2e3689d`).
- No se modificó código de producción de Cart, Products, Router, `shared/`,
  `main.dart` ni `pubspec.yaml`.

### Archivos de pruebas modificados
- `giftify/test/cart_filter_test.dart`
- `giftify/test/cart_items_provider_test.dart`
- `giftify/test/cart_screen_test.dart`
- `giftify/test/cart_checkout_flow_test.dart`

### Archivos de documentación modificados
- `docs/bitacoras/DIEGO.md`

### Escenarios agregados
Pruebas de filtro:
- filtro sin coincidencias con lista inmutable y sin alterar el original;
- filtro por categoría en UI, cambio reactivo de categoría y conservación del
  total general;
- ausencia de botón `Recargar` en cambios normales de filtro;
- filtro sin resultados frente a carrito realmente vacío;
- acción `Limpiar filtro` y recuperación de la lista completa;
- verificación de que filtrar no modifica los datos persistidos.

Pruebas de estados asíncronos:
- loading con un `CartStore` que difiere la carga;
- data después de completar la carga;
- error visible con `Reintentar`;
- recuperación manual después de reintentar;
- ausencia de reintento automático con `retry` desactivado.

Pruebas de `Dismissible`, borrado y Deshacer:
- `ValueKey(product.id)` en todos los `Dismissible`, sin keys por índice;
- conservación de la identidad al borrar la fila intermedia;
- swipe de eliminación;
- borrado primero en repositorio y luego en UI;
- fallo de borrado: la fila permanece y se comunica el error;
- SnackBar con `Deshacer` después de un borrado exitoso;
- Deshacer restaura el mismo producto, id, cantidad y total;
- fallo de Deshacer: se comunica el error y no se muestra un estado persistido
  falso;
- fallo de actualización de cantidad: el valor mostrado no cambia.

Pruebas de persistencia:
- carga inicial que se fusiona con el carrito persistido y suma cantidades por
  id;
- eliminación persistida al recrear repositorio y contenedor;
- Deshacer persistido al recrear repositorio y contenedor;
- conservación de cantidades tras reapertura;
- verificación de que un filtro activo no altera los datos persistidos.

Pruebas de Cart y Checkout:
- Checkout recibe `allItems`, incluidos los elementos ocultos por un filtro;
- cantidades y total completo en Checkout con filtro activo;
- flujo real ProductDetail → Cart → Checkout con el mismo producto y total;
- flujo responsive 320×640 con filtros, borrado, SnackBar `Deshacer`, total y
  navegación a Checkout sin overflow.

### Errores encontrados y correcciones
- No se encontraron defectos en el código de producción de Catherine.
- Error propio en una prueba nueva: `find.byType(Dismissible)` incluía el
  `Dismissible` interno del SnackBar. Se corrigió la prueba dentro de
  `giftify/test/cart_screen_test.dart`, acotando la búsqueda a la lista del
  carrito mediante `PageStorageKey('cart-list')`. No fue necesario modificar
  código de producción.
- No se modificaron archivos fuera del alcance autorizado por `DIEGO.md`.

### Pruebas realizadas
- Línea base confirmada antes de los cambios: **120 pruebas aprobadas**, 0
  fallidas y 0 omitidas.
- Pruebas dirigidas de los cuatro archivos de Cart: **36 aprobadas**.
- Suite completa final: **137 pruebas aprobadas**, 0 fallidas y 0 omitidas.
- Pruebas nuevas: **17** (1 en filtro, 3 en provider, 12 en widget de Cart y 1
  en flujo ProductDetail → Cart → Checkout).
- `dart format --output=none --set-exit-if-changed` solo sobre los cuatro
  archivos Dart modificados: sin cambios.
- `flutter analyze`: `No issues found!`.
- `git diff --check`: sin errores.

### Pruebas manuales realizadas y no realizadas
- No se ejecutó la app en emulador ni dispositivo físico durante esta sesión.
- Por lo tanto, **no se declara validado manualmente** el ciclo real de
  cerrar/reabrir la aplicación en un dispositivo.
- La persistencia se validó con `SharedPreferences` simulado en pruebas
  automatizadas, recreando repositorio y contenedor de Riverpod.
- Queda pendiente la QA manual en emulador o dispositivo con evidencia visual.

### Pendientes reales
- Ejecutar QA manual en emulador o dispositivo, incluida la persistencia real
  de cerrar/reabrir, con evidencias.
- Revisar el resultado de QA con Catherine y abrir el PR cuando el equipo lo
  autorice.
- Abrir PR cuando el equipo lo autorice, con CI, review y respuesta a la
  pregunta del `Dismissible`.
- Coordinar la actualización de `docs/fases/FASE_7_NAVEGACION_FILTROS_DESHACER.md`;
  en esta sesión no se modificó porque no está en los archivos autorizados para
  Diego. FASE 7 no se declara completada.
- Registrar la consolidación final en `docs/bitacora-ia.md`, fuera del alcance
  individual actual.

### Estado
- Cobertura automatizada del Issue #27 completada localmente.
- Commit y push preparados al cierre de la sesión; PR pendiente de autorización.
- Issue #27, FASE 7, CI y review permanecen pendientes de cierre conjunto.