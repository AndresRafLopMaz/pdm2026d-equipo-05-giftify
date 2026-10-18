# Diego — cierre del módulo Registro

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `diego`

## 1. Objetivo

Cerrar `features/auth/` para un MVP local estable, sin autenticación remota.

## 2. Estado real verificado

`RegisterScreen` ya implementa:

- formulario con nombre, correo, contraseña y fecha de nacimiento;
- validaciones locales;
- selector de fecha sin fechas futuras;
- mostrar/ocultar contraseña;
- registro simulado con `Future.delayed` de 600 ms;
- `UserProfile` sin almacenar contraseña;
- navegación a Home con `pushReplacementNamed`;
- ruta inicial `AppRoutes.register`;
- bloqueo del botón mientras `_isSubmitting` es verdadero.

Pruebas actuales: 8 en `register_screen_test.dart`, más `app_smoke_test.dart`.
Cubren renderizado, formulario vacío, correo inválido, contraseña corta,
visibilidad, apertura del selector de fecha, registro válido con navegación y
SnackBar de login.

## 3. Lecturas obligatorias

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

## 4. Tareas pertinentes

1. **Regresión Register → Home:** confirmar que un registro válido navega a Home
   y que la ruta inicial sigue siendo Registro.
2. **Responsive:** agregar una prueba de widget a 320×640. Si aparece overflow
   —por ejemplo, en la fila “¿Ya tienes una cuenta?”— corregirlo con un layout
   flexible, sin cambiar el flujo.
3. **Fecha:** ampliar la prueba del selector para confirmar que una fecha
   seleccionada queda escrita en el campo y permite continuar.
4. **Prevención de duplicados:** el botón ya se deshabilita durante el envío y
   la prueba de registro válido ya lo verifica. No duplicar esa prueba; solo
   conservarla.
5. **Errores:** el registro simulado no lanza errores de forma inyectable. No
   agregar backend ni un repositorio de autenticación para forzar ese estado en
   esta entrega.

No hay que “arreglar” lo que ya funciona. Las tareas 2 y 3 son las brechas
reales de cobertura.

## 5. Archivos permitidos

```text
giftify/lib/features/auth/screens/register_screen.dart
giftify/test/register_screen_test.dart
docs/bitacoras/DIEGO.md
```

## 6. Archivos compartidos o restringidos

Requieren coordinación:

```text
giftify/lib/app/giftify_app.dart
giftify/lib/app/app_router.dart
giftify/lib/shared/models/user_profile.dart
```

No modificar Home, Search, Products ni Cart.

## 7. Criterios de aceptación

```text
[ ] Registro sigue siendo la ruta inicial
[ ] Un registro válido navega a Home
[ ] El formulario inválido no navega
[ ] El botón se deshabilita durante el envío
[ ] No se almacena la contraseña
[ ] La pantalla no desborda a 320×640
[ ] La fecha seleccionada se refleja en el campo
[ ] dart format, flutter analyze y flutter test pasan
```

## 8. Pruebas necesarias

- responsive 320×640;
- selección real de fecha y valor del campo;
- mantener las 8 pruebas existentes sin eliminar ninguna.

## 9. Bitácora

Actualizar `docs/bitacoras/DIEGO.md` con objetivo, archivos, decisiones,
pruebas y limitaciones. Si se usa IA, registrar en `docs/bitacora-ia.md`.

## 10. Resultado esperado del PR

Un PR pequeño, sin autenticación real, con Registro estable, responsive
verificado, pruebas nuevas y CI en verde.
