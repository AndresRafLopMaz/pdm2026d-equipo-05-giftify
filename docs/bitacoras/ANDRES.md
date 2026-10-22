# Bitácora — Andrés López

Responsable de las **Pantallas 4 y 5** de Giftify (módulo `features/products/`).

---

## Sesión 2026-09-24

### Objetivo

Implementar y cerrar técnicamente el núcleo de decisión del usuario:

- Pantalla 4 — Resultados personalizados.
- Pantalla 5 — Detalle del producto.

Ambas pantallas trabajan únicamente con los contratos compartidos existentes
(`GiftSearchCriteria`, `GiftProduct`, `GiftAvailability`, `CartItem`), el
catálogo local `mockProducts` y el router central `AppRoutes`, sin backend
real ni estado global.

### Pantalla 4 — Resultados personalizados

Archivo: `giftify/lib/features/products/screens/product_results_screen.dart`.

- Recibe `GiftSearchCriteria?` mediante el contrato del router.
- Cuando `criteria == null` muestra el catálogo general completo con un orden
  determinista (calificación del vendedor, precio, id).
- Muestra un resumen breve de los criterios cuando existen.
- Maneja el estado sin resultados con un mensaje informativo.
- Usa `ListView.builder`/`ListView.separated` dentro de `SafeArea` y navega al
  detalle con `AppRoutes.productDetail` enviando `GiftProduct`.

### Estrategia de filtrado / priorización

Archivo: `giftify/lib/features/products/utils/product_filters.dart`
(funciones puras, testeables sin widgets).

- **Filtro obligatorio:** se excluyen productos con `price > maxBudget`.
- **Puntuación de preferencias** (no excluyente, para no vaciar la pantalla):
  - `category == giftType` → +2
  - `suggestedOccasions` contiene `occasion` → +2
  - `size == criteria.size` → +1
  - llega antes de `eventDate` → +1 (solo si existen `eventDate` y
    `estimatedDeliveryDays`)
- **Orden:** mayor puntuación, luego precio ascendente, luego id (desempate
  determinista).
- Comparación de textos con `trim().toLowerCase()` (sin eliminación de tildes).
- `recipient` **no** se usa para filtrar porque `GiftProduct` no contiene esa
  información; solo se muestra como contexto.

### Pantalla 5 — Detalle del producto

Archivo: `giftify/lib/features/products/screens/product_detail_screen.dart`.

- Recibe `GiftProduct?` por el contrato del router.
- Muestra imagen/placeholder, nombre, precio, descripción, disponibilidad,
  entrega (si existe), categoría, tamaño, vendedor y calificación.
- Precio, disponibilidad y entrega tienen jerarquía visual destacada.
- Sección "Detalles del vendedor" limitada a `sellerName` y `sellerRating`
  (no se inventan dirección, teléfono, reseñas ni políticas).
- Cuando `product == null` muestra un estado seguro con el mensaje
  "No se pudo cargar la información del producto." y permite volver.

### Manejo de disponibilidad

Se reutiliza `AvailabilityBadge` (texto + ícono, no solo color):

- `inStock` → "Disponible"; agregar habilitado.
- `lowStock` → "Pocas unidades"; agregar habilitado.
- `outOfStock` → "Agotado"; agregar deshabilitado.
- `unknown` → "Por confirmar"; política conservadora: se muestra una
  advertencia, no se asegura disponibilidad y agregar queda deshabilitado.
- No se representa stock numérico inexistente.

### Integración temporal con CartItem y Cart

- Al agregar: `final item = CartItem(product: product);`
- Navegación: `Navigator.pushNamed(context, AppRoutes.cart, arguments: [item]);`
- Se respeta el contrato existente del router. No se creó carrito global ni
  persistencia. No se modificó `CartScreen`.

### Archivos principales creados / modificados

Creados:

- `giftify/lib/features/products/utils/product_filters.dart`
- `giftify/lib/features/products/widgets/availability_badge.dart`
- `giftify/lib/features/products/widgets/product_card.dart`
- `giftify/test/product_filters_test.dart`
- `giftify/test/product_results_screen_test.dart`
- `giftify/test/product_detail_screen_test.dart`

Modificados:

- `giftify/lib/features/products/screens/product_results_screen.dart`
- `giftify/lib/features/products/screens/product_detail_screen.dart`

### Pruebas realizadas

- Unitarias de `filterAndPrioritizeProducts`: presupuesto, categoría, ocasión,
  tamaño, entrega antes de `eventDate`, independencia de `recipient`,
  `criteria == null` y resultado vacío.
- Widget de Resultados: catálogo general, criterios + resumen, estado vacío,
  navegación al detalle y ausencia de desbordamiento en pantalla móvil (320×640).
- Widget de Detalle: nombre/precio/descripción, vendedor y calificación,
  disponibilidad (`inStock`, `lowStock`, `outOfStock`, `unknown`), producto
  nulo, producto sin imagen, sin `estimatedDeliveryDays`, habilitación/deshabilitación
  del botón, navegación con `CartItem` y ausencia de desbordamiento en móvil.
- Comandos ejecutados desde `giftify/`: `dart format lib test`,
  `flutter analyze`, `flutter test`.

### Limitaciones actuales

- No existe backend real; los datos provienen de `mockProducts`.
- No existe carrito global ni persistencia; el carrito recibe listas por
  argumentos de navegación.
- Todos los `mockProducts` tienen `imageAsset == null`, por lo que se muestra
  el placeholder; no se declararon assets.
- No se aplican reglas de descarte por `eventDate`; la entrega solo influye en
  la priorización.

### Dependencia con Search (Brayan)

La Pantalla 4 depende de que `GiftSearchScreen` construya y envíe
`GiftSearchCriteria` por `AppRoutes.productResults`. Mientras Search sea
placeholder, los resultados se validan con criterios inyectados manualmente.
No se modificó Search.

### Dependencia con Cart (Catherine)

La Pantalla 5 envía `[CartItem]` a `AppRoutes.cart` según el contrato de la
Fase 3. Si en el futuro se requiere un carrito global o compartido, debe
coordinarse como decisión de equipo. No se modificó Cart.

### Ausencia de backend real

No se implementaron peticiones HTTP, dependencias de red, ni persistencia.
`core/backend/` permanece como espacio reservado para una integración futura.

### Pendientes de integración

- Conectar el flujo real Search → Resultados cuando Brayan lo habilite.
- Definir el comportamiento del acceso al carrito desde Resultados (no se
  implementó en esta fase para evitar un estado global prematuro).
- Ampliación de assets para imágenes de producto (requiere coordinar
  `pubspec.yaml`).

---

## Sesión 2026-10-17 — Preparación local de datos para estados asíncronos

### Objetivo

Desacoplar la pantalla de resultados de `mockProducts` mediante una frontera
`ProductRepository`, manteniendo el MVP completamente local y preparando la
integración de estados asíncronos en una tarea posterior.

### Trabajo realizado

- Se creó `ProductRepository` con el contrato mínimo:
  `Future<List<GiftProduct>> fetchProducts()`.
- Se creó `MockProductRepository` como implementación local.
- El mock permite:
  - usar `mockProducts` por defecto;
  - recibir una lista alternativa;
  - devolver una lista vacía;
  - lanzar un error configurable;
  - simular latencia con `Future.delayed`.
- Se agregaron pruebas unitarias del repositorio.
- Se documentó la guía `docs/equipo/21_ESTADOS_RESULTADOS.md`.
- Se documentó la fase completada de frontend en
  `docs/fases/FASE_4_DESARROLLO_FRONTENDS_EQUIPO.md`.
- Se documentó el backend remoto como fase futura en
  `docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.

### Archivos creados

- `giftify/lib/features/products/data/product_repository.dart`
- `giftify/lib/features/products/data/mock_product_repository.dart`
- `giftify/test/product_repository_test.dart`
- `docs/equipo/21_ESTADOS_RESULTADOS.md`
- `docs/fases/FASE_4_DESARROLLO_FRONTENDS_EQUIPO.md`
- `docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`

### Decisiones técnicas

- El MVP continúa local; no se implementó backend remoto.
- El repositorio vive en `features/products/data/` porque es una
  responsabilidad exclusiva del módulo de productos.
- El contrato no recibe criterios todavía; el filtrado sigue siendo local en
  `product_filters.dart`.
- No se agregó SQLite.
- No se agregó Riverpod.
- No se modificaron `ProductResultsScreen`, `GiftProduct`, Search, Cart ni
  Checkout en esta sesión.
- No se agregaron dependencias.

### Pruebas realizadas

- `dart format lib test` — 36 archivos, 1 archivo formateado.
- `flutter analyze` — No issues found!
- `flutter test` — 63 pruebas aprobadas.
- Se agregaron 4 pruebas de `MockProductRepository`: catálogo por defecto,
  lista configurada, lista vacía y error configurable.

### Pendientes

- BUILD 5B: integrar el repositorio en `ProductResultsScreen`.
- Implementar loading, error con Reintentar, vacío con acción y datos.
- Agregar widget tests con repositorio falso.
- Documentar FASE 5 al cerrar integración y QA.
- No cerrar el Issue #21 hasta integrar el PR.

### Impacto para otros módulos

- No se modificaron Search, Cart, Checkout, `GiftProduct` ni el router.
- La UI todavía sigue usando `mockProducts` directamente; el desacople completo
  se hará en BUILD 5B.
- El backend remoto queda planificado, no implementado.

---

## Sesión 2026-10-17 — Estados asíncronos de resultados (BUILD 5B)

### Objetivo

Integrar `ProductRepository` en `ProductResultsScreen` y representar los cuatro
estados del laboratorio, manteniendo el MVP completamente local.

### Trabajo realizado

- `ProductResultsScreen` pasó a `StatefulWidget`.
- Acepta `GiftSearchCriteria? criteria` y `ProductRepository? repository`.
- Si no se inyecta repositorio, usa `MockProductRepository`.
- El `Future` se crea en `initState` y se conserva entre builds.
- `_loadResults()` obtiene productos y aplica
  `filterAndPrioritizeProducts` antes de entregar el resultado.
- Se implementaron:
  - loading con `CircularProgressIndicator` y `Cargando…`;
  - error con `No pudimos cargar los productos.` y `Reintentar`;
  - vacío con `No encontramos productos.` y `Modificar búsqueda`;
  - datos con `ProductCard`, resumen de criterios y navegación al detalle.
- `Reintentar` crea un nuevo `Future` y ejecuta una nueva llamada a
  `fetchProducts()`.
- `Modificar búsqueda` usa `Navigator.pop` cuando es posible y, si no, navega a
  `AppRoutes.search` sin modificar el router.
- Se creó `giftify/test/helpers/fake_product_repository.dart` con modos
  `success`, `empty`, `fail` y `failOnceThenSuccess`, y contador `calls`.
- Se adaptaron los 5 tests existentes y se agregaron pruebas de loading, error,
  retry, empty con acción y responsive.

### Archivos modificados / creados

- `giftify/lib/features/products/screens/product_results_screen.dart`
- `giftify/test/product_results_screen_test.dart`
- `giftify/test/helpers/fake_product_repository.dart`

### Decisiones técnicas

- Se usó `FutureBuilder` sin agregar Riverpod.
- El repositorio se inyecta por constructor; el valor por defecto conserva la
  compatibilidad con `AppRouter`.
- No se modificó `app_router.dart`.
- No se muestran detalles técnicos de la excepción al usuario.
- No existe retry automático; solo el botón `Reintentar`.
- El subtítulo del error se ajustó a `Inténtalo de nuevo.` porque el MVP es local
  y no depende de conectividad.
- El MVP continúa local; no se agregó backend, SQLite, HTTP ni persistencia.

### Pruebas realizadas

- `dart format lib test` — 37 archivos, 2 formateados en la primera pasada.
- `flutter analyze` — No issues found!
- `flutter test` — 70 pruebas aprobadas.
- `product_results_screen_test.dart` quedó con 12 pruebas.
- Se cubren loading, error sin crash, retry con incremento de `calls`, empty con
  acción, data, navegación a Detail y responsive.

### Estado de cierre local y pendientes

- Commit funcional realizado: `91c6b3f4df9a2495b500198a14ec27f1d7f93814`.
- Push realizado a `origin/feat/21-estados-resultados`.
- PR final de Issue #21: pendiente.
- Integración a `main`: pendiente.
- Evidencias visuales de loading, error, empty y data: pendientes.
- FASE 5: pendiente de completar al cerrar integración y QA.

### Impacto para otros módulos

- No se modificaron Search, Cart, Checkout, `GiftProduct`, `ProductDetailScreen`
  ni el router.
- La pantalla ahora depende de `ProductRepository`, no de `mockProducts`
  directamente.
- No se agregaron dependencias.

---

## Sesión 2026-10-18 — Sincronización final con el MVP integrado

### Objetivo

Incorporar a `feat/21-estados-resultados` el `main` que ya contiene las
contribuciones de Diego, Catherine y Brayan, y validar la suite global.

### Trabajo realizado

- Se verificó `origin/main` en
  `364acc7b191be2a71d2a800476d61dd22bdd2463`.
- Se ejecutó `git merge origin/main` sobre `feat/21-estados-resultados`.
- El merge se completó sin conflictos en el commit
  `914ea02` (merge de main hacia la rama).
- La rama resultante contiene simultáneamente:
  - corrección responsive de Register y su test 320×640;
  - tests de Home y Search;
  - test de integración Cart → Checkout;
  - repositorio local de productos, estados asíncronos y fake repository.

### Validación global

- `dart format --output=none --set-exit-if-changed lib test` — 40 archivos,
  0 cambios.
- `flutter analyze` — No issues found!
- `flutter test` — 86 pruebas aprobadas, `All tests passed!`.
- `git diff --check` — sin errores.

### Estado de cierre local y pendientes

- PR final de Issue #21: pendiente.
- Integración a `main`: pendiente.
- Evidencias visuales de loading, error, empty y data: pendientes.
- FASE 5: pendiente de completar al cerrar integración y QA.

### Impacto para otros módulos

- El merge incorporó los cambios ya validados de los otros módulos sin
  modificarlos.
- No se agregaron funcionalidades ni dependencias.
- El MVP continúa local; no se agregó backend, SQLite, HTTP ni Riverpod.

---

## Sesión 2026-10-19 — Cierre del laboratorio y QA global

### Objetivo

Cerrar el MVP local, documentar FASE 5 y verificar el estado final de `main`
después de integrar el PR de estados asíncronos.

### Trabajo realizado

- Se verificó `origin/main` con el squash merge del PR #24:
  `1741d01fe87aca6731038a03ce5ee86eb97db31e`.
- Se comprobó que `main` contiene las contribuciones de Diego, Brayan,
  Catherine y Andrés.
- Se ejecutó el QA global sobre `main`:
  - formato;
  - analyze;
  - suite completa;
  - `git diff --check`.
- Se documentó `docs/fases/FASE_5_MVP_LOCAL_INTEGRACION_QA.md`.
- Se registró que las evidencias visuales fueron tomadas fuera del repositorio y
  que el entrypoint temporal fue eliminado sin versionarse.

### Resultado del QA

- `dart format --output=none --set-exit-if-changed lib test` — 40 archivos,
  0 cambios.
- `flutter analyze` — No issues found!
- `flutter test` — 86 pruebas aprobadas, `All tests passed!`.
- `git diff --check` — sin errores.

### Estado del laboratorio

- PR #24 integrado mediante squash en `main`.
- Issue #21 cerrado automáticamente por el PR.
- CI del PR final: `Formato, análisis y pruebas` en verde.
- Evidencias visuales: loading, error + Reintentar, recuperación, empty y data.
- FASE 5 completada.
- Backend remoto continúa como fase futura.
- La aprobación adicional de otro integrante no se realizó en el cierre
  inmediato; queda pendiente de proceso.
- La reactivación/verificación manual del ruleset queda pendiente.

### Impacto para otros módulos

- El cierre es documental y de QA; no se modificó código funcional.
- No se agregaron dependencias ni backend.
- El MVP local queda completo.

---

## Sesión 2026-10-20 — Navegación principal del nuevo laboratorio

### Objetivo

Implementar el Bloque A del laboratorio de navegación, filtros y Deshacer:
infraestructura común de Riverpod, `MainShell`, tabs e instrucciones para las
parejas.

### Trabajo realizado

- Se agregaron `flutter_riverpod` 3.0.0 y `shared_preferences` 2.5.0.
- Se envolvió `GiftifyApp` en `ProviderScope`.
- Se crearon:
  - `AppTab`;
  - `AppTabNotifier`;
  - `appTabProvider`;
  - `MainShell` con `IndexedStack` y `NavigationBar`;
  - `ComingSoonScreen`.
- `AppRouter.home` ahora abre `MainShell`.
- Home usa el provider para:
  - `Encontrar tu regalo` → Search;
  - `Ver todo` → Catálogo;
  - accesos sin pantalla → Próximamente.
- Results conserva `pop` para rutas y cambia a Search cuando está dentro del
  shell.
- Se agregaron claves de scroll y pruebas de navegación.

### Decisiones

- Riverpod 3 + Notifier + IndexedStack.
- `go_router` rechazado.
- `shared_preferences` para la persistencia local obligatoria.
- SQLite rechazado.
- Backend remoto rechazado.
- Ruleset de `main` conservado activo.
- Filtros y delete/undo quedan para las parejas; no se implementaron en este
  bloque.

### Pruebas

- `dart format lib test` — 45 archivos, 1 formateado en la primera pasada.
- `flutter analyze` — No issues found!
- `flutter test` — 93 pruebas aprobadas.
- `git diff --check` — sin errores.

### Pendientes

- PR de navegación con CI y review.
- Issues y ramas de Pareja 1 y Pareja 2.
- Implementar filtros, delete/undo y persistencia.
- Completar FASE 7.

### Impacto para otros módulos

- Cambios en `main.dart`, `app/`, Home y Results.
- `Detail`, `Cart` y `Checkout` conservan sus rutas.
- No se modificaron modelos compartidos ni backend.
