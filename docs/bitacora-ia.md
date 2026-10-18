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
