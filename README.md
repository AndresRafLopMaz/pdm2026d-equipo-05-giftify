# Giftify

Giftify es una aplicación Flutter para buscar regalos según ocasión,
destinatario, presupuesto y preferencias, revisar productos y completar un
flujo local de carrito y checkout simulado.

La aplicación prioriza una interfaz simple, mobile-first y sin dependencia de
un backend real.

## Alcance actual

Pantallas principales:

```text
Register
Home
Search
Results
Detail
Cart
Checkout
Addresses
AddressForm
```

Navegación principal:

```text
Inicio | Buscar | Catálogo | Carrito
```

- `Catálogo` muestra Results sin criterios personalizados.
- `Carrito` es una tab principal.
- `Próximamente` no es una tab; `ComingSoonScreen` queda como fallback.
- Home enlaza a Mis direcciones.

## Tecnologías

- Flutter / Dart.
- Material 3.
- Riverpod.
- SharedPreferences.
- SQLite mediante `sqflite`.
- Navegación centralizada con `AppRouter`.
- Git y GitHub.

No se usa backend real, autenticación real ni pasarela de pago.

## Persistencia local

| Dato | Persistencia |
|---|---|
| Productos eliminados | SharedPreferences |
| Carrito | SharedPreferences, `productId` + `quantity` |
| Direcciones | SQLite, CRUD, principal, archivo y restauración |
| Registro / perfil | Transitorio |
| Criterios de Search | Transitorio |
| Checkout / orden | Transitorio |

La integración Checkout → AddressBook no está implementada. Checkout conserva
su formulario manual.

## Estructura

```text
giftify/
├─ lib/
│  ├─ app/            # Router, shell y tabs
│  ├─ core/           # Tema, SQLite y backend reservado
│  ├─ features/
│  │  ├─ auth/
│  │  ├─ home/
│  │  ├─ search/
│  │  ├─ products/
│  │  ├─ cart/
│  │  └─ addresses/
│  ├─ shared/         # Modelos, enums y mockProducts
│  └─ main.dart
└─ test/              # Tests de widgets, repositorios, providers y SQLite
```

## Ejecución

```powershell
cd giftify
flutter pub get
flutter run
```

Dispositivos detectados en el entorno actual:

- Windows desktop.
- Edge web.

Android requiere Android SDK, `adb` y un dispositivo/emulador. En el entorno
actual no están disponibles.

## Calidad

```powershell
dart format lib test
flutter analyze
flutter test
git diff --check
```

Estado actual:

- 184 tests aprobados.
- `flutter analyze`: sin issues.
- `flutter build web`: correcto.
- `flutter run -d edge --no-resident`: correcto.

### Limitaciones

- Web no valida SQLite ni el CRUD de Addresses.
- Windows build requiere Developer Mode habilitado.
- La QA manual Android sigue pendiente.
- No hay usuarios reales, reviews, backend ni pagos reales.
- No hay capturas incluidas en el repositorio.

## Documentación

- `docs/fases/`: decisiones técnicas por fase.
- `docs/equipo/`: contexto por laboratorio y responsabilidades.
- `docs/bitacoras/`: registro de cambios por integrante.
- `docs/qa/REDISENO_KISS_QA_MANUAL.md`: checklist manual pendiente.
- `docs/fases/FASE_9_REDISENO_KISS_FINAL.md`: cierre del rediseño KISS.
