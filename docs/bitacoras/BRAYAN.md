<img width="1280" height="800" alt="image" src="https://github.com/user-attachments/assets/e90d8747-39b1-46ac-9f9e-3e11ea12df68" /># Bitácora — Brayan Hernández

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

dart
`
Navigator.pushNamed(
  context,
  AppRoutes.search,
);`

---

## Sesión 2026-10-18 — Cierre de Home y Search

### Objetivo

Completar la cobertura de pruebas correspondiente a las pantallas Home y Search del MVP local de Giftify, sin reimplementar funcionalidades existentes y respetando los límites del módulo asignado.

### Trabajo realizado

Se revisó el estado actual de:

- `features/home/`
- `features/search/`
- `GiftSearchCriteria`
- pruebas relacionadas con Home y Search.

La implementación existente se mantuvo y el trabajo se enfocó principalmente en agregar cobertura automatizada.

### Pruebas agregadas

Se crearon los siguientes archivos:

- `giftify/test/home_screen_test.dart`
- `giftify/test/gift_search_screen_test.dart`

Se agregaron **13 pruebas nuevas**.

La suite completa del proyecto quedó con:

- **72 pruebas aprobadas**

### Cobertura de Home

Se comprobó:

- renderizado correcto de Home;
- funcionamiento del CTA principal;
- navegación `Home → Search`;
- comportamiento responsive en pantalla móvil;
- comportamiento responsive en ancho amplio.

Se realizó un ajuste mínimo en:

`giftify/lib/features/home/screens/home_screen.dart`

El cambio consistió únicamente en mejorar el comportamiento responsive utilizando `Expanded` para evitar overflow en el encabezado del catálogo.

No se reimplementó Home.

### Cobertura de Search

Se agregaron pruebas para:

- campos obligatorios;
- presupuesto vacío;
- presupuesto inválido;
- presupuesto igual a `0`;
- presupuesto negativo;
- presupuesto decimal con punto;
- presupuesto decimal con coma;
- fecha opcional con valor `null`;
- construcción de los seis campos de `GiftSearchCriteria`;
- navegación `Search → Results`;
- captura de `RouteSettings.arguments`;
- responsive en pantalla móvil;
- responsive en ancho amplio.

### GiftSearchCriteria

Se verificó la construcción correcta de los seis campos:

- `occasion`
- `recipient`
- `maxBudget`
- `eventDate`
- `giftType`
- `size`

No se modificó el modelo `GiftSearchCriteria`.

### Navegación Search → Results

La navegación fue probada sin depender directamente de `ProductResultsScreen`.

Los tests capturan los argumentos enviados mediante:

`RouteSettings.arguments`

Esto permite validar que Search envía correctamente un objeto `GiftSearchCriteria` al flujo de resultados sin modificar el módulo Products.

### Responsive comprobado

Se realizaron pruebas en tamaños equivalentes a:

- móvil: `320x640`
- ancho amplio: `800x820`

No se detectaron problemas de overflow después del ajuste realizado en Home.

### Validaciones ejecutadas

Se ejecutaron:

```powershell
dart format lib test
flutter analyze
flutter test
git diff --check



