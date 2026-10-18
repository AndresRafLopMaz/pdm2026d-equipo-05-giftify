# Diego — módulo `auth/`

Rama personal: `diego`
Módulo principal: `giftify/lib/features/auth/`
Área compartida que consume: `app/giftify_app.dart` y `app/app_router.dart`

## Estado real integrado

`RegisterScreen` ya está implementado como `StatefulWidget` y es la ruta inicial
de la aplicación (`AppRoutes.register`).

Comportamiento actual:

- Campos: nombre, correo, contraseña y fecha de nacimiento.
- Validaciones locales: nombre obligatorio, correo con formato válido,
  contraseña de al menos 8 caracteres y fecha seleccionada.
- Selector de fecha con `showDatePicker`; no permite fechas futuras.
- Control para mostrar u ocultar la contraseña.
- Registro simulado con `Future.delayed` de 600 ms.
- Construcción de `UserProfile` sin almacenar la contraseña.
- En éxito: `Navigator.pushReplacementNamed(context, AppRoutes.home)`.
- En fallo: `SnackBar` con el mensaje
  `No se pudo completar el registro. Intenta nuevamente.`
- Protección contra doble envío mediante `_isSubmitting`.
- El enlace de inicio de sesión solo muestra un `SnackBar` informativo.

Pruebas existentes:

- `giftify/test/register_screen_test.dart` (8 pruebas).
- `giftify/test/app_smoke_test.dart` verifica el inicio en Registro.

## Enfoque de la siguiente etapa

1. Validar la integración Registro -> Home después de cualquier cambio en
   `app_router.dart` o `giftify_app.dart`.
2. Mantener el registro como simulación local. No implementar login real,
   tokens, sesiones ni llamadas HTTP.
3. Preparar el módulo para una futura capa de datos sin adelantar trabajo:
   si se introduce un repositorio de autenticación, debe ser una abstracción
   pequeña, inyectable y testeable, no una conexión real.
4. Revisar que el estado de envío y el error sigan siendo visibles y que el
   botón no permita dobles envíos.
5. Participar en la pareja del laboratorio que se asigne y registrar el trabajo
   en la bitácora.

## Reglas específicas

- No guardar contraseñas ni datos sensibles en `UserProfile`.
- No modificar `shared/models/user_profile.dart` sin coordinar con los módulos
  que lo consumen.
- `giftify_app.dart` y `app_router.dart` son áreas compartidas: cualquier cambio
  debe justificarse y probar el flujo completo.
- No cambiar la ruta inicial sin revisar `app_smoke_test.dart` y la bitácora de
  Brayan (Home).
- No implementar “recordar sesión”, recuperación de contraseña ni login social:
  están fuera del alcance actual.

## Coordinación

- Dependencia directa: Brayan (`home/`), porque el registro navega a Home.
- Dependencia de contrato: `UserProfile` en `shared/`.
- Si el laboratorio exige una pantalla con estados asíncronos, no convertir
  Registro en una pantalla de datos remotos de forma artificial; coordinar con
  el equipo la pantalla candidata.

## Validación antes de cerrar una tarea

Desde `giftify/`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/register_screen_test.dart test/app_smoke_test.dart
flutter test
```

Actualizar al final:

- `docs/bitacoras/DIEGO.md`
- `docs/bitacora-ia.md` si se usó IA
