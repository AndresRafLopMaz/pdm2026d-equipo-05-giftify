# Bitácora — Brayan Hernández

Responsable de las **Pantallas 2 y 3** de Giftify, correspondientes a los módulos:

- `features/home/`
- `features/search/`

---

## Sesión 2026-09-24

### Objetivo

Implementar y dejar funcional el flujo inicial de Giftify correspondiente a:

- **Pantalla 2 — Home / guía principal**
- **Pantalla 3 — Personalización de búsqueda**

Ambas pantallas utilizan los contratos compartidos existentes, especialmente `GiftSearchCriteria` y el router central `AppRoutes`, sin implementar backend real, lógica de resultados, carrito ni estado global.

---

## Pantalla 2 — Home / guía principal

Archivo:

`giftify/lib/features/home/screens/home_screen.dart`

### Trabajo realizado

- Se conservó la implementación visual existente.
- Se evitó reemplazar la pantalla por una versión nueva o simplificada.
- Se corrigieron textos que presentaban problemas de codificación.
- Se mantuvo la estructura visual de:
  - encabezado;
  - mensaje principal;
  - ocasiones;
  - categorías;
  - catálogo visual;
  - explicación del funcionamiento de Giftify.
- El CTA principal fue ajustado para mostrar **"Encontrar tu regalo"**.
- El CTA navega correctamente a `AppRoutes.search`.
- Se eliminó únicamente el comportamiento temporal o placeholder asociado al CTA.
- No se modificaron módulos de otros integrantes.

### Navegación Home → Search

Se utilizó el router existente:

```dart
Navigator.pushNamed(
  context,
  AppRoutes.search,
);
```

---

## Sesión 2026-10-18

### Objetivo

Cerrar la cobertura de Home y Search para el MVP local sin reimplementar sus
funcionalidades ni depender de `ProductResultsScreen` en las pruebas de
navegación.

### Archivos creados

- `giftify/test/home_screen_test.dart`
- `giftify/test/gift_search_screen_test.dart`

### Trabajo realizado

- Se cubrió el renderizado de Home y el CTA `Encontrar tu regalo`.
- Se verificó la navegación Home → Search mediante `AppRoutes.search`.
- Se cubrieron los seis campos del formulario de Search.
- Se verificaron las validaciones de campos obligatorios y presupuestos vacío,
  inválido, cero y negativo.
- Se verificaron presupuestos decimales con punto y con coma.
- Se comprobó que la fecha opcional se envía como `null` cuando no se elige.
- Se construyó y comprobó un `GiftSearchCriteria` con `occasion`, `recipient`,
  `maxBudget`, `eventDate`, `giftType` y `size`.
- Se capturaron `AppRoutes.productResults` y `RouteSettings.arguments` con un
  router de prueba, sin renderizar `ProductResultsScreen`.
- Se verificó Home y Search en 320×640, además de Search en 800×800.

### Defecto encontrado y corregido

La prueba móvil detectó un overflow horizontal en el encabezado del catálogo de
Home. Se restringió su columna de textos con `Expanded`, conservando el diseño y
sin cambiar la funcionalidad existente.

### Validación

- `dart format lib test`: 35 archivos revisados, 0 cambios pendientes.
- `flutter analyze`: sin issues.
- `flutter test`: 72 pruebas aprobadas.
- `git diff --check`: limpio.

### Pendientes

- Ninguno dentro del alcance de Home y Search para esta tarea.

### Detalle de cobertura

Se agregaron **13 pruebas nuevas**. La suite completa quedó con **72 pruebas
aprobadas**.

Home:

- renderizado de Home;
- CTA principal;
- navegación Home → Search;
- responsive móvil;
- responsive en ancho amplio.

Search:

- campos obligatorios;
- presupuesto vacío;
- presupuesto inválido;
- presupuesto igual a `0`;
- presupuesto negativo;
- presupuesto decimal con punto;
- presupuesto decimal con coma;
- fecha opcional con valor `null`;
- construcción de los seis campos de `GiftSearchCriteria`;
- navegación Search → Results;
- captura de `RouteSettings.arguments`;
- responsive en móvil y ancho amplio.

Campos verificados de `GiftSearchCriteria`:

- `occasion`
- `recipient`
- `maxBudget`
- `eventDate`
- `giftType`
- `size`

No se modificó el modelo `GiftSearchCriteria` ni el módulo Products. La
navegación Search → Results se probó capturando los argumentos, sin renderizar
`ProductResultsScreen`.

### Evidencia

![Evidencia de pruebas de Home y Search](https://github.com/user-attachments/assets/e90d8747-39b1-46ac-9f9e-3e11ea12df68)

### Cierre de la tarea

- Commit funcional: `ad2a27518c5bbf67626cf4fbeb18229a206dff58`.
- Mensaje: `test: cubrir home y busqueda de regalos`.
- Push realizado a `origin/brayan`.
- Formato: OK.
- Analyze: sin issues.
- Tests de la rama en esa validación: 72 aprobadas.
- `git diff --check`: sin errores.
