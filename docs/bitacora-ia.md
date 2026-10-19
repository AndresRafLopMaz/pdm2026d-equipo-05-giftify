# Bitácora de uso de IA

Cada uso de IA que termina en el repo se registra aquí (el más reciente arriba).
El objetivo no es justificar el uso, sino demostrar **criterio**:
qué especificaste, qué revisaste y qué rechazaste.

| Campo | Qué escribir |
|---|---|
| Fecha / autor | `2026-10-15 · @usuario` |
| Herramienta | Claude, Copilot, ChatGPT, OpenCode… |
| Especificación | Qué pediste y con qué restricciones (pegar el prompt o resumirlo) |
| Resultado | Qué devolvió, en una frase |
| Aceptado | Qué quedó en el código y por qué |
| Rechazado / corregido | Qué cambiaste y por qué. **Esta es la columna más importante.** |
| Verificación | Cómo comprobaste que funciona (pruebas, dispositivo) |
| Commit / PR | Enlace |

---

## 2026-10-18 · @AndresRafLopMaz — Sincronización final con el MVP integrado

- **Herramienta:** OpenCode (asistente de código, modelo deepseek-flash).
- **Especificación:** "Sincronizar `feat/21-estados-resultados` con `main`, que
  ya contiene Diego, Catherine y Brayan. No resolver conflictos automáticamente,
  no abrir PR, no integrar a main y no agregar funcionalidades."
- **Resultado:** el merge de `main` hacia `feat/21` se completó sin conflictos y
  la suite global quedó en verde.
- **Aceptado:**
  - `origin/main` en `364acc7`, con las tres contribuciones integradas.
  - Merge `914ea02` de `main` hacia `feat/21-estados-resultados`.
  - Suite combinada con las pruebas de los cuatro integrantes.
- **Rechazado / corregido:**
  - No se eligió automáticamente una versión del conflicto porque no hubo
    conflicto.
  - No se modificó `main`, no se abrió PR y no se integró `feat/21`.
  - No se agregó backend, SQLite, HTTP, Riverpod ni persistencia.
  - No se marcó el laboratorio como terminado.
- **Verificación:** con Flutter 3.44.8 / Dart 3.12.2 en `giftify/`:
  `dart format --output=none --set-exit-if-changed lib test` → 40 archivos,
  0 cambios; `flutter analyze` → No issues found!; `flutter test` → 86 pruebas
  aprobadas; `git diff --check` limpio.
- **Commit / PR:** merge `914ea02` en `feat/21-estados-resultados`; PR final
  pendiente. Evidencias visuales, integración a `main` y FASE 5 pendientes.

---

## 2026-10-17 · @AndresRafLopMaz — Estados asíncronos de resultados (Issue #21)

- **Herramienta:** OpenCode (asistente de código, modelo deepseek-flash).
- **Especificación:** "Integrar `ProductRepository` en `ProductResultsScreen`,
  conservar `GiftSearchCriteria`, implementar loading, error con `Reintentar`,
  vacío con `Modificar búsqueda` y datos. Crear fake repository y pruebas.
  No tocar router, modelos, Search, Cart, Detail ni agregar backend, SQLite o
  Riverpod."
- **Resultado:** la pantalla consume el repositorio de forma asíncrona y muestra
  los cuatro estados con reintento manual.
- **Aceptado:**
  - `ProductResultsScreen` como `StatefulWidget` con repositorio opcional y
    `MockProductRepository` por defecto.
  - Future creado en `initState` y conservado entre builds.
  - Filtrado local dentro de `_loadResults()`.
  - Loading, error, empty y data.
  - `Reintentar` crea un nuevo Future y ejecuta una nueva consulta.
  - `Modificar búsqueda` usa `pop` o navega a Search sin tocar el router.
  - Fake con `success`, `empty`, `fail`, `failOnceThenSuccess` y contador
    `calls`.
- **Rechazado / corregido:**
  - No se agregó retry automático; solo el botón manual.
  - No se muestran detalles técnicos de la excepción.
  - No se modificó `app_router.dart`; se usó inyección por constructor.
  - No se modificaron modelos compartidos, Search, Cart, Detail ni
    `mockProducts`.
  - No se agregó backend, SQLite, HTTP ni Riverpod.
  - Se ajustó el subtítulo del error a `Inténtalo de nuevo.` porque el MVP es
    local y no depende de conectividad.
- **Verificación:** con Flutter 3.44.8 / Dart 3.12.2 en `giftify/`:
  `dart format lib test` → 37 archivos, 2 formateados en la primera pasada;
  `flutter analyze` → No issues found!; `flutter test` → 70 pruebas aprobadas.
- **Commit / PR:** commit funcional `91c6b3f` en
  `feat/21-estados-resultados`; push realizado a
  `origin/feat/21-estados-resultados`. PR pendiente; integración a `main`
  pendiente; evidencias visuales pendientes; FASE 5 pendiente. Issue #21.

---

## 2026-10-17 · @AndresRafLopMaz — Preparación local del repositorio de productos

- **Herramienta:** OpenCode (asistente de código, modelo deepseek-flash).
- **Especificación:** "Entregar el MVP completamente local: crear
  `ProductRepository` y `MockProductRepository`, agregar pruebas unitarias,
  documentar la guía de estados, la FASE 4 completada y la FASE 6 futura. No
  implementar backend remoto, SQLite ni Riverpod. No modificar todavía
  `ProductResultsScreen`."
- **Resultado:** se creó la frontera de repositorio local, su implementación
  mock, cuatro pruebas unitarias y la documentación de la tarea y de las fases.
- **Aceptado:**
  - `ProductRepository` con `Future<List<GiftProduct>> fetchProducts()`.
  - `MockProductRepository` con catálogo por defecto, lista alternativa, lista
    vacía, error configurable y latencia simulada.
  - Pruebas unitarias de catálogo, lista configurada, vacío y error.
  - Documentación `21_ESTADOS_RESULTADOS.md`, FASE 4 completada y FASE 6
    planificada.
- **Rechazado / corregido:**
  - No se implementó backend remoto ni se configuraron Supabase, Firebase o API
    REST.
  - No se agregó SQLite: es persistencia local, no backend, y no es necesaria
    para este MVP.
  - No se agregó Riverpod; la pantalla se preparará con FutureBuilder en la
    siguiente etapa.
  - No se modificó `ProductResultsScreen` en esta sesión; los cuatro estados se
    implementarán en BUILD 5B.
  - No se modificaron `GiftProduct`, Cart, Checkout ni Search.
  - No se agregaron dependencias.
- **Verificación:** con Flutter 3.44.8 / Dart 3.12.2 en `giftify/`:
  `dart format lib test` → 36 archivos, 1 formateado; `flutter analyze` →
  No issues found!; `flutter test` → 63 pruebas aprobadas.
- **Commit / PR:** commit `cb59067` (BUILD 5A) integrado en la rama publicada
  `origin/feat/21-estados-resultados`; PR pendiente. Issue de referencia: #21
  (solo trazabilidad).

---

## 2026-10-17 · @AndresRafLopMaz — Verificación del laboratorio de CI y corrección de CODEOWNERS

- **Herramienta:** OpenCode (asistente de código, modelo deepseek-flash).
- **Especificación:** "Revisar el PR #19 contra los requisitos del laboratorio de CI:
  triggers, versión de Flutter, `working-directory`, pasos de formato, análisis y
  pruebas, nombre del check, plantilla de PR, CODEOWNERS y bitácora de IA. Corregir
  solo CODEOWNERS y la bitácora; no modificar `ci.yml`, la plantilla ni el código.
  No fusionar."
- **Resultado:** el workflow cumple el laboratorio; se amplió CODEOWNERS a los cuatro
  integrantes y se completó el registro del PR #19.
- **Aceptado:**
  - `ci.yml` se mantiene sin cambios: triggers `pull_request`, `push` a `main` y
    `workflow_dispatch`; `working-directory: giftify`; Flutter 3.44.8; check exacto
    `Formato, análisis y pruebas`; sin `continue-on-error`.
  - CODEOWNERS con los cuatro integrantes, para que cualquier revisor distinto del
    autor pueda satisfacer la revisión de Code Owners.
  - La plantilla de PR existente se considera suficiente para esta etapa.
- **Rechazado / corregido:**
  - Se corrigió CODEOWNERS, que solo tenía a `@AndresRafLopMaz` y habría bloqueado
    los PR autorados por él al exigir revisión de Code Owners.
  - Se rechazó copiar pasos de SQLite (`libsqlite3-dev`) heredados de Inkash.
  - No se agregó persistencia local innecesaria ni SQLite.
  - No se agregó Riverpod todavía; la decisión queda para la fase de estados
    asíncronos.
  - No se modificó `ci.yml` porque ya cumple el laboratorio.
  - Se corrigió el registro histórico para enlazar el commit y el PR reales.
- **Verificación:** con Flutter 3.44.8 / Dart 3.12.2 en `giftify/`:
  `dart format --output=none --set-exit-if-changed lib test` → 33 archivos,
  0 cambios; `flutter analyze` → No issues found!; `flutter test` → 59 pruebas
  aprobadas. El PR #19 tenía el check `Formato, análisis y pruebas` en verde.
- **Commit / PR:** corrección sobre la rama `chore/ci`; PR #19:
  https://github.com/AndresRafLopMaz/pdm2026d-equipo-05-giftify/pull/19

---

## 2026-10-15 · @DiegoBarriosCifuentes — Parte A de S14: CI, plantilla de PR y CODEOWNERS

- **Herramienta:** OpenCode (asistente de código, modelo deepseek-flash).
- **Especificación:** "Implementar solo la Parte A: CI con GitHub Actions, plantilla de
  Pull Request, CODEOWNERS y bitácora de IA. La app Flutter está en `giftify/` y la raíz
  del repo es el repositorio Git. Rama `chore/ci`. Adaptar el workflow a `giftify/`
  (pub get, dart format, flutter analyze, flutter test), sin pasos de SQLite. Mantener el
  job `Formato, análisis y pruebas`. Usar solo usuarios reales en CODEOWNERS. No agregar
  funcionalidades nuevas, no hacer push ni merge."
- **Resultado:** se crearon `.github/workflows/ci.yml`, `.github/pull_request_template.md`,
  `.github/CODEOWNERS` y `docs/bitacora-ia.md` adaptados a Giftify.
- **Aceptado:**
  - Workflow con los triggers del docente (`pull_request` y `push` a `main`,
    `workflow_dispatch`) y el nombre de job exacto `Formato, análisis y pruebas`.
  - `defaults.run.working-directory: giftify` para no duplicar la ruta en cada paso.
  - `flutter-version: 3.44.8` (misma minor que el Flutter local 3.44.5 / Dart 3.12.2,
    compatible con `sdk: ^3.12.2`).
  - Job `apk` conservado, adaptado a `giftify/`: artefacto `giftify-apk-<sha>` y ruta
    `giftify/build/app/outputs/flutter-apk/app-debug.apk`.
  - Checklist del PR reescrito con criterios de Giftify (rutas en `app_router.dart`,
    modelos en `lib/shared/`, `BackendClient` sin HTTP real).
- **Rechazado / corregido durante el trabajo:**
  - Se descartaron del workflow los pasos de SQLite (`libsqlite3-dev`) de Inkash: Giftify
    no usa `sqflite` ni base de datos local.
  - Se descartaron las condiciones exclusivas de Inkash en la plantilla (dinero en
    centavos `int`, `occurredOn`, `AppDatabase`): no aplican a este proyecto.
  - No se pudo verificar por CLI la lista de colaboradores con permiso de escritura (no
    hay `gh` instalado). Por eso CODEOWNERS solo lista a `@AndresRafLopMaz`, en lugar de
    inventar usuarios; los demás equipos deben agregarse solo si GitHub confirma permiso.
- **Verificación:** ejecutado en `giftify/` con Flutter 3.44.5 / Dart 3.12.2:
  `dart format --output=none --set-exit-if-changed lib test` → 33 archivos, 0 cambiados;
  `flutter analyze` → No issues found!; `flutter test` → 59 pruebas, todas aprobadas.
- **Commit / PR:** commit `50b0a4e` · PR #19:
  https://github.com/AndresRafLopMaz/pdm2026d-equipo-05-giftify/pull/19
