# FASE 10D - Auth local, usuarios y sesión persistente

**Fecha:** 2026-11-05
**Rama:** `feat/redesign-kiss-final`
**Estado:** implementación completada; QA manual en Android pendiente.

## Objetivo

Implementar autenticación local con usuarios persistidos en SQLite, contraseñas
hasheadas, sesión persistente, restauración al iniciar, Logout y un AuthGate que
decide entre Login/Register y MainShell.

## Alcance

Incluido:

- PasswordHasher PBKDF2;
- SQLite v3 con tabla `users`;
- UserRepository;
- AuthService;
- SessionStore;
- AuthController;
- AuthGate;
- Login;
- Register V2;
- Logout;
- restauración de sesión;
- migraciones y tests.

Fuera de alcance:

- Profile;
- Settings;
- Dark Mode;
- Payment Methods;
- Checkout V2;
- ownership por usuario de Cart, Addresses o DeletedProducts;
- backend;
- OAuth;
- recuperación de contraseña;
- MFA.

## Modelo

```dart
class User {
  final int id;
  final String name;
  final String email;
}
```

`User` no contiene `passwordHash` ni `passwordSalt`.

Las credenciales solo existen en la capa interna:

```dart
class UserCredentials {
  final User user;
  final String passwordHash;
  final String passwordSalt;
}
```

## SQLite v3

`AppDatabase.version = 3`.

```sql
CREATE TABLE users (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          TEXT NOT NULL,
  email         TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  created_at    INTEGER NOT NULL
);

CREATE UNIQUE INDEX idx_users_email_nocase
ON users(email COLLATE NOCASE);
```

`delivery_addresses` y sus índices no se modificaron. La migración es aditiva:
no hay DROP, DELETE ni recreación de la base.

## Migraciones

- v1 → v3: aplica v1→v2 y luego crea `users`.
- v2 → v3: conserva direcciones e índices y crea `users`.
- Fresh v3: crea direcciones, índices, users e índice único de email.

Los tests verifican que `onCreate` y `onUpgrade` convergen al mismo esquema final
y que las direcciones existentes sobreviven.

## PasswordHasher

Algoritmo:

```text
PBKDF2-HMAC-SHA256
600,000 iteraciones en producción
32 bytes de salida
salt de 16 bytes por usuario
Base64 para hash y salt
comparación constant-time
```

Los tests usan 1,000 iteraciones para mantener la suite rápida, manteniendo el
mismo algoritmo.

El salt se genera con `Random.secure()` dentro del hasher. No hay salt global,
hardcodeado ni basado en tiempo.

`verify` devuelve `false` ante hash/salt corruptos o de longitud incorrecta; no
propaga `FormatException` a la UI.

## Email

Normalización:

```dart
email.trim().toLowerCase()
```

Además, la tabla usa un índice único `COLLATE NOCASE`. El repositorio también
normaliza para evitar duplicados si se usa directamente.

Un email duplicado se traduce a `EmailAlreadyRegisteredException`, nunca a un
error SQLite visible.

## Autenticación

`AuthService`:

- valida nombre, email y contraseña;
- normaliza email;
- verifica duplicados;
- hashea en registro;
- verifica credenciales en login;
- devuelve `User`;
- no guarda sesión.

`AuthController`:

- restaura sesión al construir;
- registra;
- inicia sesión;
- cierra sesión;
- guarda/limpia el `user_id` en SessionStore.

`AuthController` usa `AsyncNotifier<User?>`:

```text
AsyncLoading     → restaurando
AsyncData(null)  → sin sesión
AsyncData(User)  → autenticado
AsyncError       → error de restauración
```

Login y Register usan `_isSubmitting` local; no convierten la app completa en
`AsyncLoading` durante un envío.

## Sesión

```text
Clave: giftify.session_user_id
Tipo: int
```

Solo se guarda el ID. No se guarda password, hash, salt ni un token.

Sesión válida = existe ID y el usuario existe.

Si el ID no existe en `users`, se limpia la sesión. Si falla la base de datos,
no se borra automáticamente la sesión y AuthGate muestra error con reintento.

`SharedPreferences` no es un almacén de secretos; esta sesión es comodidad local,
no autenticación de producción.

## AuthGate y routing

```text
/          → AuthGate
/home      → AuthGate protegido
/login     → AuthGate(initialView: login)
/register  → AuthGate(initialView: register)
```

Estados:

```text
loading       → indicador breve
unauth        → Login/Register
authenticated → MainShell
error         → mensaje + Reintentar
```

Login/Register se alternan con estado local, sin Navigator. El éxito cambia el
estado del controller y AuthGate renderiza MainShell. No se usa
`pushReplacementNamed('/home')`.

`/` siempre es válida. La ruta desconocida conserva el fallback actual.

## Login

Campos:

- correo;
- contraseña con mostrar/ocultar.

Acciones:

- Iniciar sesión;
- Crear cuenta.

No existe “Olvidé mi contraseña”. El error de credenciales es genérico:

```text
Correo o contraseña incorrectos.
```

## Register V2

Campos:

- nombre;
- correo;
- contraseña;
- confirmar contraseña.

Se eliminó la fecha de nacimiento porque no se persistía, mostraba ni utilizaba.

Política:

```text
8–128 caracteres
sin trim silencioso
espacios permitidos
```

La confirmación se valida solo en UI y no se envía al servicio.

## Logout

Acción temporal en el header de Home:

```text
IconButton
key: logout-button
tooltip: Cerrar sesión
```

Logout limpia solo `giftify.session_user_id`. No elimina usuarios, carrito,
direcciones, productos eliminados, catálogo ni búsquedas.

AuthGate vuelve a Login y el stack no contiene MainShell; Back no lo revela.

## Limitación multiusuario temporal

En 10D se mantiene conscientemente:

- carrito global;
- direcciones globales;
- productos eliminados globales.

Por tanto, User A puede cerrar sesión y User B puede ver esos datos globales.
Esto es una limitación conocida del MVP académico y no se presenta como
aislamiento multiusuario de producción.

El ownership por usuario se difiere a una fase posterior (10F), incluyendo:

- `user_id` en direcciones y migración;
- namespace de carrito por usuario;
- namespace de productos eliminados por usuario.

## Tests

Cubiertos:

- hash correcto/incorrecto, salts, determinismo y corrupción;
- repositorio: create, find, duplicados, normalización y persistencia;
- migración v1→v3, v2→v3 y fresh v3;
- sesión: guardar, leer, limpiar y reinicio;
- AuthService: registro, login y errores;
- AuthController: restore, register, login, logout y sesión huérfana;
- AuthGate: loading, unauth, auth, error y logout/Back;
- Login/Register: validaciones, errores, alternancia, responsive y text scale;
- integración real SQLite + SharedPreferences + AuthController.

Resultado: **278 tests aprobados**.

## QA

- `dart format --output=none --set-exit-if-changed lib test`: 0 cambios.
- `flutter analyze`: sin issues.
- `flutter test`: 278 aprobados.
- `git diff --check`: exit 0.
- `flutter build web`: compilación correcta.

La compilación Web no valida SQLite ni Auth persistente. No existe fallback de
sqflite para Web. Android no está disponible en el entorno actual; la validación
manual queda pendiente.

## Participación

- Andrés: hashing, SQLite v3, migraciones, UserRepository, AuthService,
  SessionStore, AuthController, integración y seguridad.
- Catherine: Login/Register UX, copy, validaciones, errores y alternancia visual.
- Diego: AuthGate, responsive, accesibilidad, tests UI, restore, logout y Back.
- Brayan11Hernandez: revisión de copy, mensajes, QA conceptual, casos manuales,
  documentación del flujo y revisión visual. Relevancia baja/media.

No se usó a Brayan11Hernandez como author ni co-author porque no hay correo Git
verificado. No se inventaron correos.
