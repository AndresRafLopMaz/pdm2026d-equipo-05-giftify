# Brayan — cierre de Home y Search

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `brayan`

## 1. Objetivo

Cerrar `features/home/` y `features/search/` para un MVP local estable, con
cobertura de pruebas suficiente y sin implementar lógica de resultados.

## 2. Estado real verificado

### Home

- Conserva la interfaz visual existente.
- El CTA “Encontrar tu regalo” navega con
  `Navigator.pushNamed(context, AppRoutes.search)`.
- No hay archivo de prueba específico de Home.

### Search

- Formulario con ocasión, destinatario y presupuesto obligatorios.
- Fecha, tipo de regalo y tamaño opcionales.
- El presupuesto acepta coma o punto y debe ser mayor que 0.
- La fecha no puede ser anterior a hoy.
- Construye `GiftSearchCriteria` con los seis campos.
- Navega a `AppRoutes.productResults` con el criterio como argumento.
- Es responsive: usa `LayoutBuilder` y cambia a una columna cuando el ancho es
  menor que 620.
- No hay archivo de prueba específico de Search.

## 3. Brecha principal

La lógica existe, pero **Home y Search no tienen pruebas de widget propias**.
Esa es la brecha real, no una funcionalidad faltante.

## 4. Lecturas obligatorias

```text
docs/equipo/00_REGLAS_COMUNES.md
docs/equipo/mvp/00_CONTEXTO_MVP_LOCAL.md
docs/equipo/ANDRES.md
docs/bitacoras/BRAYAN.md
giftify/lib/features/home/screens/home_screen.dart
giftify/lib/features/search/screens/gift_search_screen.dart
giftify/lib/shared/models/gift_search_criteria.dart
giftify/lib/app/app_router.dart
giftify/test/navigation_contract_test.dart
```

## 5. Tareas pertinentes

1. **Home:** prueba del CTA “Encontrar tu regalo” y navegación a Search.
2. **Home responsive:** prueba a 320×640; corregir solo si hay overflow real.
3. **Search:** pruebas de campos obligatorios y mensajes de validación.
4. **Presupuesto:** probar vacío, texto inválido, cero, negativo, coma y punto.
5. **Fecha:** probar que es opcional y que se envía como `null` si no se elige.
6. **Criterios:** probar que se construye `GiftSearchCriteria` con ocasión,
   destinatario, presupuesto, fecha, tipo y tamaño.
7. **Integración Search → Results:** capturar el argumento de navegación y
   verificar que es el `GiftSearchCriteria` esperado.
8. **Responsive:** probar Search en ancho móvil y en ancho amplio.

No cambiar la lógica de filtrado ni Results. Si una prueba revela un defecto
real, corregirlo en Search/Home con el alcance mínimo.

## 6. Archivos permitidos

```text
giftify/lib/features/home/screens/home_screen.dart
giftify/lib/features/search/screens/gift_search_screen.dart
giftify/test/home_screen_test.dart
giftify/test/gift_search_screen_test.dart
docs/bitacoras/BRAYAN.md
```

## 7. Archivos compartidos o restringidos

Requieren coordinación:

```text
giftify/lib/app/app_router.dart
giftify/lib/shared/models/gift_search_criteria.dart
```

No modificar:

```text
giftify/lib/features/products/
giftify/lib/features/cart/
```

`recipient` es obligatorio en el formulario, pero no filtra productos porque
`GiftProduct` no contiene esa información. No cambiar ese contrato.

## 8. Criterios de aceptación

```text
[ ] Home navega a Search con el CTA
[ ] Home no desborda a 320×640
[ ] Search no navega con campos obligatorios vacíos
[ ] Presupuesto inválido o <= 0 muestra error
[ ] Presupuesto con coma y con punto se interpreta igual
[ ] Fecha vacía se envía como null
[ ] Se construyen los seis campos de GiftSearchCriteria
[ ] Search navega a Results con el criterio correcto
[ ] Search no desborda en móvil ni en ancho amplio
[ ] dart format, flutter analyze y flutter test pasan
```

## 9. Pruebas necesarias

Crear pruebas de widget para Home y Search. Para la integración con Results, es
preferible capturar `RouteSettings.arguments` con un `onGenerateRoute` de prueba
en lugar de depender de la pantalla de Andrés. Así se evita acoplar la prueba al
trabajo de estados asíncronos de `ProductResultsScreen`.

## 10. Bitácora

Actualizar `docs/bitacoras/BRAYAN.md` con objetivo, archivos, decisiones,
pruebas y pendientes. Registrar IA en `docs/bitacora-ia.md` si aplica.

## 11. Resultado esperado del PR

Un PR de pruebas y ajustes mínimos en Home/Search, sin lógica de resultados, sin
backend y con CI en verde.
