# Brayan — cierre de Home y Search

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `brayan`

## 1. Objetivo

Cerrar `features/home/` y `features/search/` para un MVP local estable,
agregando la cobertura de pruebas que hoy no existe.

## 2. Estado actual que NO debe reimplementarse

### Home

- Interfaz visual existente.
- CTA “Encontrar tu regalo”.
- Navegación a `AppRoutes.search` con `Navigator.pushNamed`.
- No hay tests específicos de Home.

### Search

- Formulario con ocasión, destinatario y presupuesto obligatorios.
- Fecha, tipo de regalo y tamaño opcionales.
- Presupuesto con coma o punto.
- Validación de presupuesto mayor que 0.
- Fecha no anterior a hoy.
- Construcción de `GiftSearchCriteria` con seis campos.
- Navegación a `AppRoutes.productResults` con el criterio.
- Layout responsive: columna por debajo de 620 px.
- No hay tests específicos de Search.

No reimplementar el formulario, las validaciones ni la navegación.

## 3. Trabajo requerido

### P0

1. Crear `giftify/test/home_screen_test.dart`:
   - renderizar Home;
   - encontrar el CTA “Encontrar tu regalo”;
   - pulsarlo;
   - verificar navegación a `AppRoutes.search` / `GiftSearchScreen`.

2. Crear `giftify/test/gift_search_screen_test.dart`:
   - campos obligatorios;
   - presupuesto vacío;
   - presupuesto inválido;
   - presupuesto 0;
   - presupuesto negativo;
   - presupuesto con punto;
   - presupuesto con coma;
   - fecha opcional enviada como `null`;
   - construcción de `GiftSearchCriteria`;
   - seis campos esperados;
   - navegación Search → Results.

### P1

- Home en 320×640.
- Search en 320×640.
- Search con ancho mayor a 620.
- Sin overflow en dropdowns y presupuesto.

### Fuera de alcance

- Lógica de resultados.
- Modificar `ProductResultsScreen`.
- Cambiar `GiftSearchCriteria`.
- Backend, persistencia o dependencias.

## 4. Flujo funcional

```text
HomeScreen
    ↓
AppRoutes.search
    ↓
GiftSearchScreen
    ↓
GiftSearchCriteria
    ↓
AppRoutes.productResults
```

## 5. Archivos que debe leer

```text
docs/equipo/00_REGLAS_COMUNES.md
docs/equipo/mvp/00_CONTEXTO_MVP_LOCAL.md
docs/equipo/mvp/ANDRES.md
docs/bitacoras/BRAYAN.md
giftify/lib/features/home/screens/home_screen.dart
giftify/lib/features/search/screens/gift_search_screen.dart
giftify/lib/shared/models/gift_search_criteria.dart
giftify/lib/app/app_router.dart
giftify/test/navigation_contract_test.dart
```

## 6. Archivos que puede modificar

```text
giftify/lib/features/home/screens/home_screen.dart
giftify/lib/features/search/screens/gift_search_screen.dart
giftify/test/home_screen_test.dart
giftify/test/gift_search_screen_test.dart
docs/bitacoras/BRAYAN.md
```

Modificar las pantallas solo si un test revela un defecto real.

## 7. Archivos que NO debe modificar

```text
giftify/lib/features/products/
giftify/lib/features/cart/
giftify/lib/app/app_router.dart
giftify/lib/shared/models/gift_search_criteria.dart
giftify/pubspec.yaml
docs/bitacora-ia.md
```

Motivo: resultados pertenece a Andrés, carrito a Catherine, y el router/los
modelos son contratos compartidos.

## 8. Implementación esperada

### Home

Renderizar `HomeScreen` dentro de un `MaterialApp` con el router real o un
`onGenerateRoute` de prueba. Pulsar el CTA y verificar que se abre
`GiftSearchScreen` o que la ruta solicitada es `AppRoutes.search`.

### Search: validaciones

Renderizar `GiftSearchScreen` directamente. Pulsar “Buscar regalos” sin completar
campos y verificar los mensajes de validación. No debe navegar.

### Search: presupuesto

Probar:

```text
vacío          -> error
"abc"          -> error
"0"            -> error
"-10"          -> error
"250.00"       -> válido
"250,00"       -> válido
```

Recordar que la pantalla convierte coma en punto antes de parsear.

### Search: criterios y navegación

Para evitar depender de `ProductResultsScreen`, usar un `MaterialApp` con
`onGenerateRoute` propio. Cuando `settings.name == AppRoutes.productResults`:

```dart
expect(settings.arguments, isA<GiftSearchCriteria>());
```

Guardar el argumento y comprobar:

```text
occasion
recipient
maxBudget
eventDate
giftType
size
```

No renderizar la pantalla de Andrés en esta prueba.

### Fecha opcional

No seleccionar fecha y verificar que `eventDate` es `null` en el criterio
capturado.

### Responsive

Usar `tester.view.physicalSize` y `devicePixelRatio`, con `addTearDown` para
restaurar. Probar 320×640 y un ancho mayor a 620.

## 9. Casos que debe cubrir

- Home → Search.
- Formulario vacío.
- Presupuesto inválido, cero y negativo.
- Presupuesto con coma y con punto.
- Fecha opcional.
- Criterio completo.
- Search → Results con el argumento correcto.
- Sin overflow en móvil y escritorio.

## 10. Pruebas

Crear las dos pruebas nuevas. Mantener `navigation_contract_test.dart` sin
modificarlo. No duplicar pruebas de Results ni de Cart.

## 11. Validación visual

- Home a 320×640.
- Search a 320×640.
- Search en ancho amplio.
- Dropdowns y campo de presupuesto sin overflow.

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

Actualizar `docs/bitacoras/BRAYAN.md` con:

- objetivo;
- pruebas creadas;
- casos cubiertos;
- defectos encontrados y corregidos, si hubo;
- resultados de validación;
- pendientes.

No modificar `docs/bitacora-ia.md` durante el trabajo paralelo.

## 14. Git

```powershell
git fetch --all --prune
git switch brayan
git pull --ff-only origin brayan
git merge origin/main

# trabajo y validación

git status
git diff --stat
git add giftify/test/home_screen_test.dart
git add giftify/test/gift_search_screen_test.dart
# si hubo un ajuste real:
# git add giftify/lib/features/home/screens/home_screen.dart
# git add giftify/lib/features/search/screens/gift_search_screen.dart
git add docs/bitacoras/BRAYAN.md
git diff --cached --name-status
git diff --cached --check
git commit -m "test: cubrir home y busqueda de regalos"
git push origin brayan
```

## 15. Evidencias

- Salida de `flutter analyze`.
- Total de tests y `All tests passed`.
- Evidencia de los tests nuevos de Home/Search.
- `git diff --check` limpio.
- `git status` final.
- SHA del commit.
- Rama remota actualizada.

## 16. Criterios de cierre

```text
[ ] Test de Home CTA → Search
[ ] Test de validaciones de Search
[ ] Tests de presupuesto (vacío, inválido, 0, negativo, coma, punto)
[ ] Test de fecha opcional como null
[ ] Test de GiftSearchCriteria con seis campos
[ ] Test de Search → Results capturando el argumento
[ ] Responsive 320×640 y ancho amplio
[ ] dart format lib test correcto
[ ] flutter analyze sin issues
[ ] flutter test verde
[ ] git diff --check limpio
[ ] Bitácora actualizada
[ ] Commit y push a brayan
```

## 17. Prohibiciones

- No modificar `ProductResultsScreen`.
- No implementar filtrado.
- No tocar modelos compartidos, router, Cart ni Products.
- No backend, SQLite, Riverpod ni dependencias.
- No modificar `docs/bitacora-ia.md` en esta fase.
