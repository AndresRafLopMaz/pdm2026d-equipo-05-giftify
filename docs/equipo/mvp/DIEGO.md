# Diego — cierre del módulo Registro

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `diego`

## 1. Objetivo

Cerrar `features/auth/` para un MVP local estable, sin autenticación remota.
El módulo ya funciona; el trabajo restante es una verificación responsive.

## 2. Estado actual que NO debe reimplementarse

`RegisterScreen` ya tiene:

- formulario con nombre, correo, contraseña y fecha de nacimiento;
- validaciones locales;
- selector de fecha sin fechas futuras;
- mostrar/ocultar contraseña;
- registro simulado con `Future.delayed` de 600 ms;
- `UserProfile` sin almacenar contraseña;
- bloqueo del botón durante el envío;
- navegación Register → Home con `pushReplacementNamed`;
- ruta inicial `AppRoutes.register`;
- 8 pruebas de Registro más `app_smoke_test.dart`.

No volver a implementar nada de esa lista.

## 3. Trabajo requerido

### P0

Ninguno. El módulo cumple el comportamiento funcional del MVP local.

### P1

1. Agregar una prueba responsive a 320×640.
2. Verificar específicamente la fila:

```text
"¿Ya tienes una cuenta?" + "Inicia sesión aquí"
```

3. Corregir la UI **solo si la prueba demuestra overflow**. No rediseñar la
   pantalla.

### Fuera de alcance

- Aserción explícita del texto de la fecha (P2).
- Refactorizar el camino de error del registro simulado (P2).
- Autenticación real, persistencia o backend.

## 4. Flujo funcional

```text
AppRoutes.register
        ↓
RegisterScreen
        ↓
validación local
        ↓
registro simulado (600 ms)
        ↓
AppRoutes.home
```

## 5. Archivos que debe leer

```text
docs/equipo/00_REGLAS_COMUNES.md
docs/equipo/mvp/00_CONTEXTO_MVP_LOCAL.md
docs/bitacoras/DIEGO.md
giftify/lib/features/auth/screens/register_screen.dart
giftify/lib/app/giftify_app.dart
giftify/lib/app/app_router.dart
giftify/lib/shared/models/user_profile.dart
giftify/test/register_screen_test.dart
giftify/test/app_smoke_test.dart
```

## 6. Archivos que puede modificar

```text
giftify/lib/features/auth/screens/register_screen.dart
giftify/test/register_screen_test.dart
docs/bitacoras/DIEGO.md
```

## 7. Archivos que NO debe modificar

```text
giftify/lib/app/app_router.dart
giftify/lib/app/giftify_app.dart
giftify/lib/shared/models/user_profile.dart
giftify/lib/features/home/
giftify/lib/features/search/
giftify/lib/features/products/
giftify/lib/features/cart/
giftify/pubspec.yaml
docs/bitacora-ia.md
```

Motivo: son áreas compartidas, dependen de otros módulos o no forman parte de
esta tarea. Si un defecto real exige tocarlas, detenerse y coordinar.

## 8. Implementación esperada

1. Sincronizar `diego` con `origin/main`.
2. Ejecutar la línea base:
   ```powershell
   dart format lib test
   flutter analyze
   flutter test
   ```
3. En `register_screen_test.dart`, configurar la vista de prueba:

```dart
tester.view.physicalSize = const Size(320, 640);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
```

4. Renderizar `RegisterScreen` con el helper existente.
5. Comprobar:
   - `tester.takeException()` es `null`;
   - existe “¿Ya tienes una cuenta?”;
   - existe “Inicia sesión aquí”;
   - el formulario sigue visible.
6. Si aparece overflow:
   - hacer el ajuste visual mínimo;
   - preferir `Wrap`, `Flexible` o `Expanded` en la fila;
   - no cambiar textos, validaciones ni navegación.
7. Reejecutar toda la suite.

## 9. Casos que debe cubrir

- Pantalla estrecha 320×640 sin overflow.
- La fila de login no rompe el layout.
- El resto de pruebas de Registro sigue pasando.
- No se altera la navegación ni la ruta inicial.

## 10. Pruebas

Agregar una prueba de widget responsive. Mantener las 8 existentes. No eliminar
ni duplicar pruebas de validación, fecha o doble envío que ya existen.

## 11. Validación visual

- 320×640: formulario completo, sin overflow horizontal.
- Verificar que el botón de registro sigue accesible con scroll.

## 12. Validación técnica

Desde `giftify/`:

```powershell
dart format lib test
flutter analyze
flutter test
```

Desde la raíz:

```powershell
git diff --check
```

## 13. Registro en bitácora

Actualizar `docs/bitacoras/DIEGO.md` con:

- objetivo de la sesión;
- prueba responsive agregada;
- si hubo ajuste visual y por qué;
- resultado de format, analyze y test;
- pendientes.

No modificar `docs/bitacora-ia.md` durante el trabajo paralelo.

## 14. Git

```powershell
git fetch --all --prune
git switch diego
git pull --ff-only origin diego
git merge origin/main

# trabajo y validación

git status
git diff --stat
git add giftify/lib/features/auth/screens/register_screen.dart
git add giftify/test/register_screen_test.dart
git add docs/bitacoras/DIEGO.md
git diff --cached --name-status
git diff --cached --check
git commit -m "test: cubrir registro en pantalla movil estrecha"
git push origin diego
```

Si no se modifica la pantalla, no agregarla al commit.

## 15. Evidencias

- Salida de `flutter analyze`.
- Total de tests y `All tests passed`.
- `git diff --check` limpio.
- `git status` final.
- SHA del commit.
- Captura o descripción del test responsive si hubo ajuste visual.

## 16. Criterios de cierre

```text
[ ] Prueba responsive 320×640 agregada
[ ] Fila de login verificada
[ ] Sin overflow
[ ] Las 8 pruebas existentes siguen pasando
[ ] dart format lib test correcto
[ ] flutter analyze sin issues
[ ] flutter test verde
[ ] git diff --check limpio
[ ] Bitácora actualizada
[ ] Commit y push a diego
```

## 17. Prohibiciones

- No autenticación real.
- No backend, Supabase, Firebase, API REST, SQLite ni Riverpod.
- No persistencia.
- No modificar módulos ajenos.
- No agregar dependencias.
- No tocar `app_router.dart` ni `giftify_app.dart` sin coordinación.
- No modificar `docs/bitacora-ia.md` en esta fase.
