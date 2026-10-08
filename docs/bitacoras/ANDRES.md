# Bitácora — Andrés López

Responsable de las **Pantallas 4 y 5** de Giftify (módulo `features/products/`).

---

## Sesión 2026-09-24

### Objetivo

Implementar y cerrar técnicamente el núcleo de decisión del usuario:

- Pantalla 4 — Resultados personalizados.
- Pantalla 5 — Detalle del producto.

Ambas pantallas trabajan únicamente con los contratos compartidos existentes
(`GiftSearchCriteria`, `GiftProduct`, `GiftAvailability`, `CartItem`), el
catálogo local `mockProducts` y el router central `AppRoutes`, sin backend
real ni estado global.

### Pantalla 4 — Resultados personalizados

Archivo: `giftify/lib/features/products/screens/product_results_screen.dart`.

- Recibe `GiftSearchCriteria?` mediante el contrato del router.
- Cuando `criteria == null` muestra el catálogo general completo con un orden
  determinista (calificación del vendedor, precio, id).
- Muestra un resumen breve de los criterios cuando existen.
- Maneja el estado sin resultados con un mensaje informativo.
- Usa `ListView.builder`/`ListView.separated` dentro de `SafeArea` y navega al
  detalle con `AppRoutes.productDetail` enviando `GiftProduct`.

### Estrategia de filtrado / priorización

Archivo: `giftify/lib/features/products/utils/product_filters.dart`
(funciones puras, testeables sin widgets).

- **Filtro obligatorio:** se excluyen productos con `price > maxBudget`.
- **Puntuación de preferencias** (no excluyente, para no vaciar la pantalla):
  - `category == giftType` → +2
  - `suggestedOccasions` contiene `occasion` → +2
  - `size == criteria.size` → +1
  - llega antes de `eventDate` → +1 (solo si existen `eventDate` y
    `estimatedDeliveryDays`)
- **Orden:** mayor puntuación, luego precio ascendente, luego id (desempate
  determinista).
- Comparación de textos con `trim().toLowerCase()` (sin eliminación de tildes).
- `recipient` **no** se usa para filtrar porque `GiftProduct` no contiene esa
  información; solo se muestra como contexto.

### Pantalla 5 — Detalle del producto

Archivo: `giftify/lib/features/products/screens/product_detail_screen.dart`.

- Recibe `GiftProduct?` por el contrato del router.
- Muestra imagen/placeholder, nombre, precio, descripción, disponibilidad,
  entrega (si existe), categoría, tamaño, vendedor y calificación.
- Precio, disponibilidad y entrega tienen jerarquía visual destacada.
- Sección "Detalles del vendedor" limitada a `sellerName` y `sellerRating`
  (no se inventan dirección, teléfono, reseñas ni políticas).
- Cuando `product == null` muestra un estado seguro con el mensaje
  "No se pudo cargar la información del producto." y permite volver.

### Manejo de disponibilidad

Se reutiliza `AvailabilityBadge` (texto + ícono, no solo color):

- `inStock` → "Disponible"; agregar habilitado.
- `lowStock` → "Pocas unidades"; agregar habilitado.
- `outOfStock` → "Agotado"; agregar deshabilitado.
- `unknown` → "Por confirmar"; política conservadora: se muestra una
  advertencia, no se asegura disponibilidad y agregar queda deshabilitado.
- No se representa stock numérico inexistente.

### Integración temporal con CartItem y Cart

- Al agregar: `final item = CartItem(product: product);`
- Navegación: `Navigator.pushNamed(context, AppRoutes.cart, arguments: [item]);`
- Se respeta el contrato existente del router. No se creó carrito global ni
  persistencia. No se modificó `CartScreen`.

### Archivos principales creados / modificados

Creados:

- `giftify/lib/features/products/utils/product_filters.dart`
- `giftify/lib/features/products/widgets/availability_badge.dart`
- `giftify/lib/features/products/widgets/product_card.dart`
- `giftify/test/product_filters_test.dart`
- `giftify/test/product_results_screen_test.dart`
- `giftify/test/product_detail_screen_test.dart`

Modificados:

- `giftify/lib/features/products/screens/product_results_screen.dart`
- `giftify/lib/features/products/screens/product_detail_screen.dart`

### Pruebas realizadas

- Unitarias de `filterAndPrioritizeProducts`: presupuesto, categoría, ocasión,
  tamaño, entrega antes de `eventDate`, independencia de `recipient`,
  `criteria == null` y resultado vacío.
- Widget de Resultados: catálogo general, criterios + resumen, estado vacío,
  navegación al detalle y ausencia de desbordamiento en pantalla móvil (320×640).
- Widget de Detalle: nombre/precio/descripción, vendedor y calificación,
  disponibilidad (`inStock`, `lowStock`, `outOfStock`, `unknown`), producto
  nulo, producto sin imagen, sin `estimatedDeliveryDays`, habilitación/deshabilitación
  del botón, navegación con `CartItem` y ausencia de desbordamiento en móvil.
- Comandos ejecutados desde `giftify/`: `dart format lib test`,
  `flutter analyze`, `flutter test`.

### Limitaciones actuales

- No existe backend real; los datos provienen de `mockProducts`.
- No existe carrito global ni persistencia; el carrito recibe listas por
  argumentos de navegación.
- Todos los `mockProducts` tienen `imageAsset == null`, por lo que se muestra
  el placeholder; no se declararon assets.
- No se aplican reglas de descarte por `eventDate`; la entrega solo influye en
  la priorización.

### Dependencia con Search (Brayan)

La Pantalla 4 depende de que `GiftSearchScreen` construya y envíe
`GiftSearchCriteria` por `AppRoutes.productResults`. Mientras Search sea
placeholder, los resultados se validan con criterios inyectados manualmente.
No se modificó Search.

### Dependencia con Cart (Catherine)

La Pantalla 5 envía `[CartItem]` a `AppRoutes.cart` según el contrato de la
Fase 3. Si en el futuro se requiere un carrito global o compartido, debe
coordinarse como decisión de equipo. No se modificó Cart.

### Ausencia de backend real

No se implementaron peticiones HTTP, dependencias de red, ni persistencia.
`core/backend/` permanece como espacio reservado para una integración futura.

### Pendientes de integración

- Conectar el flujo real Search → Resultados cuando Brayan lo habilite.
- Definir el comportamiento del acceso al carrito desde Resultados (no se
  implementó en esta fase para evitar un estado global prematuro).
- Ampliación de assets para imágenes de producto (requiere coordinar
  `pubspec.yaml`).
