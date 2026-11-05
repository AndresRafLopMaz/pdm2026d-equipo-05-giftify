# FASE 10E - Profile, Settings y Dark Mode

**Fecha:** 2026-11-05
**Rama:** `feat/redesign-kiss-final`
**Estado:** implementación completada; QA visual Android pendiente.

## Objetivo

Agregar preferencias de tema persistentes, Dark Mode completo, Profile real,
Settings real, acceso a Profile desde Home y trasladar Logout desde Home a
Profile, manteniendo Auth y SQLite intactos.

## Arquitectura de tema

`AppTheme.lightTheme` y `AppTheme.darkTheme` se construyen con un builder
compartido. `appTheme` se conserva como alias de light para compatibilidad.

Se mantiene `GiftifyColors` como `ThemeExtension`; no se creó un sistema paralelo.

- `GiftifyColors.of` usa la extensión del tema.
- Si falta la extensión, cae a dark o light según `Theme.brightness`.
- Light conserva la paleta del Design System V2.
- Dark usa una paleta propia, no una inversión automática.

## Paleta Dark

```text
Background              #121318
Surface                 #1A1B22
Surface muted           #23252E
Surface container low   #171820
Surface container high  #2B2D38
Surface container high+ #323542
Border / outlineVariant #343742
Outline                 #4A4E5C

Text                    #F3F4F7
Muted                   #AEB3C2

Primary                 #AEB9FF
On primary              #171B30
Primary container       #2C3352
On primary container    #E3E7FF

Secondary               #CFC1FF
On secondary            #241B3A
Secondary container     #3A2F58
On secondary container  #F0E8FF

Tertiary                #F0A9C9
On tertiary             #3B1728
Tertiary container      #4A2A3B
On tertiary container   #FFD9E8

Error                   #FFB4AB
On error                #690005
Error container         #5C1A16
On error container      #FFDAD6
```

`GiftifyColors` dark:

```text
secondaryStrong #D4C7FF
secondarySoft   #2D2742
blush           #D39AB7
blushStrong     #FFC0DA
blushSoft       #3A2230
warm            #F3D6A4
warmStrong      #F7D58A
warmSoft        #3A2E1B
success         #6FCFA2
successStrong   #8FE3B8
successSoft     #1C3528
```

## Contraste

Dark validado:

```text
Text / Background                         16.87:1
Muted / Background                         8.86:1
Text / Surface                             15.60:1
Muted / Surface                             8.19:1
Primary / Background                        9.88:1
Primary / Surface                           9.14:1
Primary / PrimarySoft                       6.57:1
OnPrimary / Primary                         9.05:1
OnPrimaryContainer / PrimaryContainer      10.07:1
SecondaryStrong / SecondarySoft             9.06:1
BlushStrong / BlushSoft                     9.51:1
WarmStrong / WarmSoft                       9.35:1
SuccessStrong / SuccessSoft                 8.71:1
Error / ErrorContainer                      7.66:1
OnSurfaceVariant / SurfaceContainerHighest  5.82:1
```

Light conserva sus contrastes previos.

## Component themes

Se adaptaron mediante el builder compartido:

- AppBar;
- NavigationBar;
- FilledButton;
- OutlinedButton;
- TextButton;
- InputDecoration;
- Card;
- Chip;
- Divider;
- SnackBar;
- Dialog;
- BottomSheet;
- PopupMenu.

`Radio`, `RadioListTile`, `RadioGroup`, `DatePicker`, `Switch`, `ChoiceChip` y
`FilterChip` heredan del `ColorScheme`; no se agregaron overrides locales.

## System UI

`GiftifyApp` aplica un `AnnotatedRegion<SystemUiOverlayStyle>` centralizado
según brightness. Evita `SystemChrome` repetido por pantalla.

## ThemePreferenceStore

```text
Clave: giftify.theme_mode
Valores: system | light | dark
```

Interfaz:

```dart
Future<ThemeMode> read();
Future<void> save(ThemeMode mode);
```

Implementación:

```text
SharedPreferencesThemePreferenceStore
```

- ausente o inválido → `ThemeMode.system`;
- guarda `mode.name`, no índices;
- fallo de escritura → `ThemePersistenceException`.

## ThemeController

```text
Notifier<ThemeMode>
```

- estado inicial precargado por override;
- `setMode` aplica inmediatamente;
- si falla la persistencia, revierte el estado y relanza un error controlado;
- no depende de AuthController.

## Startup

`main` precarga SharedPreferences y la preferencia antes de `runApp`. Así se
evita el flash light→dark. No se agrega splash adicional.

`GiftifyApp` usa:

```dart
theme: AppTheme.lightTheme
darkTheme: AppTheme.darkTheme
themeMode: currentMode
```

`ThemeMode.system` se guarda literalmente y MaterialApp lo resuelve con la
plataforma.

## Profile

`ProfileScreen` usa `authControllerProvider` y muestra:

- avatar con iniciales;
- nombre real;
- email real;
- Mis direcciones;
- Apariencia;
- Cerrar sesión.

No muestra ID, password, hash, salt, fecha de nacimiento, Payment Methods ni
edición de perfil.

`UserAvatar` genera hasta dos iniciales, no persiste y no permite upload.

## Settings

`SettingsScreen` contiene únicamente Apariencia:

```text
Sistema
Claro
Oscuro
```

Usa `RadioGroup<ThemeMode>` + `RadioListTile`, adecuado para 320 px y text scale
2.0. No hay opciones falsas.

Si falla la persistencia, revierte el tema y muestra:

```text
No pudimos guardar tu preferencia de apariencia.
```

## Rutas y protección

```text
/profile  → AuthGate(authenticatedChild: ProfileScreen)
/settings → AuthGate(authenticatedChild: SettingsScreen)
```

Sin sesión, ambas muestran Login y no exponen datos. Con sesión, muestran la
pantalla solicitada. Se mantienen `/`, `/home`, `/login`, `/register`, rutas
existentes y el fallback de ruta desconocida.

## Logout

Home ya no contiene logout. Profile contiene:

```text
key: profile-logout-button
```

Profile solo llama a `AuthController.logout()`. `GiftifyApp` escucha la
transición authenticated→unauthenticated y, después del frame, limpia las rutas
apiladas con `popUntil(isFirst)`. El resultado es Login con `canPop == false`,
sin Profile ni MainShell detrás.

## Home

- Se eliminó `logout-button`.
- Se agregó `profile-button` con avatar, tooltip y semántica.
- Saludo personalizado: `Hola, <primer nombre>`.
- Fallback: `Hola`.
- No se agregó una quinta tab.
- Search, Catálogo, Carrito, Direcciones y categorías siguen funcionando.

## Auditoría Dark

Se revisaron automáticamente en dark:

```text
Login
Register
AuthGate login/error
Home
Search
Results
Detail
Cart
Checkout
AddressList
AddressForm
Profile
Settings
```

No se encontraron colores hardcodeados de pantalla; los únicos usos de
`Brightness`/`SystemUiOverlayStyle` están centralizados en `GiftifyApp` y
`app_theme.dart`.

`AvailabilityBadge` conserva icono + texto y sus roles:

```text
Disponible      → success
Pocas unidades  → warm
Agotado         → error
Por confirmar   → onSurfaceVariant / surfaceContainerHighest
```

## QA

- `dart format --output=none --set-exit-if-changed lib test`: 0 cambios.
- `flutter analyze`: sin issues.
- `flutter test`: **326 pruebas aprobadas**.
- `git diff --check`: exit 0.
- `flutter build web`: compilación correcta.
- Edge: launch únicamente; no se declara validación manual ni Auth SQLite web.
- Android: **NO EJECUTADA**; no hay SDK/adb/emulador. Dark Mode requiere
  inspección visual física pendiente.

## Limitaciones

Se mantiene:

```text
Cart global
Addresses global
DeletedProducts global
Tema global de la instalación
```

No hay ownership por usuario en 10E. El tema no se guarda por usuario y Logout
no lo borra. 10F resolverá ownership de datos.

## Participación

- Andrés: arquitectura de tema, ColorScheme/GiftifyColors dark, ThemeStore,
  ThemeController, preload, MaterialApp, rutas protegidas y tests técnicos.
- Catherine: Profile/Settings UX, copy, Home/Profile discoverability, logout
  reubicado.
- Diego: responsive, accesibilidad, contraste, auditoría dark, tests de
  pantallas/routing/back.
- Brayan11Hernandez: revisión de paleta, iconografía, copy, QA visual conceptual,
  casos manuales y documentación visual. Relevancia baja/media.

No se usó a Brayan11Hernandez como author ni co-author porque no hay correo Git
verificado. No se inventaron correos.
