# Brayan — módulos `home/` y `search/`

Rama personal: `brayan`
Módulos principales:

- `giftify/lib/features/home/`
- `giftify/lib/features/search/`

## Estado real integrado

### Home

- Conserva la pantalla visual existente.
- El CTA principal muestra `Encontrar tu regalo`.
- El CTA navega con `Navigator.pushNamed(context, AppRoutes.search)`.
- Incluye secciones de ocasiones, categorías, catálogo visual y explicación del
  funcionamiento.
- No consulta datos ni implementa lógica de resultados.

### Personalización de búsqueda

- Formulario con `Form`.
- Campos obligatorios: ocasión, destinatario y presupuesto máximo.
- Campos opcionales: fecha del regalo, tipo de regalo y tamaño.
- La fecha no puede ser anterior a hoy.
- El presupuesto acepta coma o punto decimal mediante `_parseBudget`.
- Construye un `GiftSearchCriteria` real y navega:

```dart
Navigator.pushNamed(
  context,
  AppRoutes.productResults,
  arguments: criteria,
);
```

- No implementa filtrado ni consulta de productos: esa responsabilidad está en
  `features/products/`.

Pruebas existentes:

- No hay un archivo de test específico para Home ni para Search.
- El contrato de navegación se cubre parcialmente en
  `giftify/test/navigation_contract_test.dart` y el arranque en
  `giftify/test/app_smoke_test.dart`.

## Enfoque de la siguiente etapa

1. Cerrar el vacío de pruebas de Home y Search antes de agregar estados
   asíncronos.
2. Validar que Search construya `GiftSearchCriteria` con los seis campos y que
   Results los reciba sin transformaciones adicionales.
3. Probar presupuesto con coma, con punto, vacío y valores inválidos.
4. Probar que la fecha opcional se envíe como `null` cuando no se selecciona.
5. Mantener Home como pantalla estática de navegación; no forzarla a consumir un
   repositorio remoto.
6. Si el laboratorio de estados asíncronos se aplica a Search, justificar qué
   dato se carga de forma asíncrona. Lo más natural es que los criterios sigan
   siendo locales y que la pantalla de datos sea Results.

## Reglas específicas

- No implementar lógica de resultados ni filtros en Search: pertenece a
  `features/products/`.
- No modificar `GiftSearchCriteria` sin coordinar con Andrés.
- No duplicar el router ni crear rutas nuevas fuera de `AppRoutes`.
- No agregar backend ni estado global para Home/Search sin decisión del equipo.
- Mantener los textos en español y sin problemas de codificación.

## Coordinación

- Dependencia directa: Andrés (`products/`), por el contrato
  `GiftSearchCriteria -> ProductResultsScreen`.
- Dependencia de contrato: `shared/models/gift_search_criteria.dart`.
- Dependencia con Diego (`auth/`): Home es el destino del registro.

## Validación antes de cerrar una tarea

Desde `giftify/`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Agregar pruebas específicas de Home y Search cuando se modifiquen. Actualizar:

- `docs/bitacoras/BRAYAN.md`
- `docs/bitacora-ia.md` si se usó IA
