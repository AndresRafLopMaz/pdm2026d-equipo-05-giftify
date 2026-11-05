# FASE 10G — QA final y cierre técnico

## Estado

- **10G-A — Regresión funcional P0/P1 y accesibilidad crítica:** completado.
- **10G-B — Recursos visuales y polish:** completado técnicamente con fallback A+.
- **10G-C — QA final, documentación y PR:** pendiente.

> No se encontraron assets WebP locales válidos. Los 10 assets por categoría
> quedan pendientes de incorporación con origen y licencia documentados.

Base de partida: `2f567692794b081cdfcd599e5d7ddcc5ebb67fa5`.

## 10G-A — Regresión funcional

### 1. Mojibake en ProductCard

**ANTES**

`ProductCard` mostraba `Â·` y `â˜…` en la metadata visible de Results/Catálogo.
También había comentarios con mojibake en `product_filter.dart`.

**FIX**

- Se reemplazaron por `·` y `★`.
- Se corrigieron los comentarios de `product_filter.dart`.
- No se añadió ningún reemplazo en runtime.

**TEST**

`test/product_card_test.dart` verifica el texto exacto y la ausencia de
`Â`, `â` y `Ã`.

**ESTADO:** completado.

### 2. Search: presupuesto no finito o ambiguo

**ANTES**

`double.tryParse` aceptaba `NaN`, `Infinity`, `+Infinity`, `-Infinity` y
`1e309`; el validador solo comprobaba nulo y `<= 0`. `1,000` se convertía en
`1.0`.

**FIX**

Regla final:

```text
^\d+(?:[.,]\d{1,2})?$
```

- Acepta `250`, `250.50` y `250,50`.
- Rechaza `NaN`, `Infinity`, exponentes, signos, múltiples separadores y
  separadores con más de dos decimales.
- La validación final exige `isFinite && > 0`.
- Se añadió `autovalidateMode: onUserInteraction` para limpiar el error al
  corregir.
- Hint actualizado a `Ej. 250 o 250.50`.

**TEST**

`test/gift_search_screen_test.dart` cubre valores válidos, coma, punto,
`NaN`, `Infinity`, `+Infinity`, `-Infinity`, `1e309`, `1,000`, `1.000,50`,
`100,500`, `-1`, texto, cero, vacío y limpieza del error inline.

**ESTADO:** completado.

### 3. Checkout con todos los pagos vencidos

**ANTES**

Si todos los métodos estaban vencidos, Checkout mostraba un método no
seleccionable pero no ofrecía agregar otro. El usuario quedaba en dead-end.

**FIX**

- Estado explícito “Sin método de pago vigente”.
- CTA “Agregar método de pago” hacia `/payment-methods/new`.
- El selector muestra métodos vencidos deshabilitados y un CTA para agregar
  cuando no existe ninguno vigente.
- El pago nuevo se refleja mediante `paymentMethodsProvider`.
- El reloj de expiración dejó de ser un valor congelado: producción usa
  `DateTime.now` en cada evaluación; tests siguen inyectando `now`.
- Copy de error local corregido: ya no sugiere revisar la conexión.

**TEST**

`test/checkout_screen_test.dart` cubre all-expired, selector, agregar pago,
retorno a Checkout, pago válido y confirmación habilitada.

**ESTADO:** completado.

### 4. Rutas de productos sin AuthGate

**ANTES**

`/search`, `/products` y `/products/detail` no pasaban por AuthGate, pero sus
providers dependen de `currentUserIdProvider`.

**FIX**

Las tres rutas usan ahora `AuthGate` con el widget autenticado correspondiente.
Se mantienen argumentos y fallbacks actuales.

**TEST**

`test/routing/private_routes_test.dart` cubre sin sesión → Login y con sesión
→ pantalla; `/products/detail` conserva el `GiftProduct`.

**ESTADO:** completado.

### 5. Carrito corrupto u obsoleto

**ANTES**

JSON corrupto, estructura inválida o un `productId` eliminado del catálogo
podían dejar el carrito en error permanente sin recuperación.

**FIX**

- JSON corrupto o estructura que no es lista → carrito vacío y limpieza de la
  clave.
- Entradas individuales inválidas → se omiten; las válidas sobreviven.
- `productId` obsoleto → se omite y se sanea la persistencia.
- Duplicados y cantidades inválidas se descartan al cargar.
- Sin logger nuevo ni exposición de JSON.

**TEST**

`test/cart_repository_test.dart` y `test/cart_items_provider_test.dart` cubren
JSON corrupto, estructura inválida, entradas inválidas, ID obsoleto, mezcla
válida/inválida, clave saneada y provider sin estado de error.

**ESTADO:** completado.

### 6. Migración v1→v2 con labels NOCASE

**ANTES**

La migración v1→v2 intentaba crear un índice `UNIQUE(label COLLATE NOCASE)`
sin resolver colisiones como `Casa`, `casa`, `CASA`.

**FIX**

Antes de crear el índice v2 se reservan todos los labels originales y se
renombran determinísticamente los duplicados:

```text
Casa
Casa (2)
Casa (3)
...
```

Se consideran labels preexistentes como `Casa (2)`. No se elimina ninguna fila.
`AppDatabase.version` sigue siendo 5.

**TEST**

`test/database/address_migration_test.dart` migra v1→v5 con `Casa`, `casa`,
`CASA` y `Casa (2)`, verificando cuatro filas, IDs conservados y labels únicos.

**ESTADO:** completado.

### 7. Contraste de bordes e inputs

**ANTES**

`outline` light era `#E4E6EC` (≈1.25:1 sobre blanco); dark era
`#4A4E5C` (≈2.07:1). El texto muted light no alcanzaba AA sobre
`surfaceContainerHighest`.

**FIX**

- `outline` light: `#878E9F` (≥3:1 sobre surface/background).
- `outlineVariant` light: se mantiene `#E4E6EC` para decoración.
- `outline` dark: `#6B7284` (≥3:1).
- `outlineVariant` dark: se mantiene para decoración.
- `onSurfaceVariant` light: `#5F6777` para AA sobre `surfaceContainerHighest`.
- Chips con `showCheckmark: true`.

**TEST**

`test/theme_contrast_test.dart` valida texto AA y contraste non-text ≥3:1 en
Light/Dark, además del checkmark de chips.

**ESTADO:** completado.

### 8. Touch targets

**ANTES**

Controles de cantidad del carrito 44×44; categorías de Home ~36 dp.

**FIX**

- Cantidad del carrito: 48×48.
- Categorías de Home: área táctil mínima 48 sin agrandar innecesariamente el
  contenido visual.

**TEST**

`test/cart_screen_test.dart` y `test/home_screen_test.dart` verifican tamaño
mínimo.

**ESTADO:** completado.

### 9. Estado UI entre usuarios

**ANTES**

`appTab`, filtros de producto/carrito y prefill de Search podían sobrevivir al
logout.

**FIX**

En la transición authenticated→unauthenticated, `GiftifyApp` mantiene el
`popUntil(isFirst)` y además:

- `appTab → home`;
- `productFilter → default`;
- `cartFilter → default`;
- `searchPrefill → null`.

No se toca ThemeMode, carrito, direcciones, eliminados, pagos ni usuarios.
`AuthController` no conoce features de UI.

**TEST**

`test/app_ui_reset_test.dart` prueba A con tab/filtros/prefill, logout, B login,
Home inicial, filtros limpios, prefill nulo, tema intacto y stack sin MainShell.

**ESTADO:** completado.

### 10. Text scale 2.0 en Carrito y Checkout

**ANTES**

Carrito y Checkout no tenían prueba a 320×640 con text scale 2.0. Al añadirla
aparecieron overflows horizontales: precio del carrito, total del resumen y
acciones del selector de Checkout.

**FIX**

- Precio/total usan `Flexible` con alineación final.
- Los paneles de selección de Checkout apilan su acción debajo del texto cuando
  el text scale supera 1.3.
- No se redujeron fonts.

**TEST**

`test/cart_screen_test.dart` y `test/checkout_screen_test.dart` cubren 320×640
con text scale 2.0.

**ESTADO:** completado.

## 10G-B — Recursos visuales y polish

### Assets encontrados

Al iniciar 10G-B no existían imágenes de producto ni carpeta `assets/`. Solo
había iconos de plataforma generados por Flutter. Los 36 productos tenían
`imageAsset == null`.

No se descargaron imágenes externas ni se inventó procedencia.

### Estrategia aplicada

Se implementó **A+**:

- `ProductImage` centralizado.
- Resolver de assets por categoría preparado para los 10 WebP futuros.
- Fallback Material por categoría con icono y superficie semántica.
- Sin `Image.network`.
- Sin assets WebP falsos.
- Sin sección `assets:` en `pubspec.yaml` hasta disponer de archivos válidos.

Rutas reservadas:

```text
assets/images/categories/technology.webp
assets/images/categories/jewelry.webp
assets/images/categories/food.webp
assets/images/categories/accessories.webp
assets/images/categories/home.webp
assets/images/categories/books.webp
assets/images/categories/gaming.webp
assets/images/categories/beauty.webp
assets/images/categories/crafts.webp
assets/images/categories/experiences.webp
```

`CategoryVisuals.localAssetsAvailable` permanece en `false` hasta incorporar
los archivos con licencia. Al activarlo, `ProductImage` usará el asset de
categoría; `imageAsset` sigue siendo override opcional.

### Fallback por categoría

| Categoría | Icono |
|---|---|
| Tecnología | `devices_rounded` |
| Joyería | `diamond_rounded` |
| Alimentos | `restaurant_rounded` |
| Accesorios | `watch_rounded` |
| Hogar | `home_rounded` |
| Libros | `menu_book_rounded` |
| Gaming | `sports_esports_rounded` |
| Belleza | `spa_rounded` |
| Artesanías | `palette_rounded` |
| Experiencias | `local_activity_rounded` |

Los colores usan tokens Light/Dark; no hay colores de pantalla hardcodeados.

### Integración

- Results/Catálogo: `ProductCard` usa `ProductImage` 92×92.
- Detail: `ProductImage` full width × 240.
- Cart: `ProductImage` 80×80 con `Image.asset`; se eliminó `Image.network`.
- `errorBuilder` cae al fallback de categoría.

### Copy e iconografía

- Disponibilidad: “Todas” → “Todos”.
- Register: copy limitado a cuenta, direcciones y carrito reales.
- Search: “Local” → “Producto local”.
- Success: “Pedido confirmado” + aviso de simulación académica.
- Últimos 4 dígitos: `numbers_rounded` en vez de `pin`.
- Errores locales: `error_outline_rounded` en vez de nube/conexión.
- Filtro: `filter_list_rounded`; modificar búsqueda: `edit_rounded`.
- Dirección principal: “Dirección principal” / “Esta es la dirección principal.”.

### Semantics y touch

- `ProductCard`: hint “Ver detalle”.
- `AddressCard`: hint “Editar dirección”.
- Results: acción semántica personalizada para eliminar sin depender del swipe.
- `PaymentMethods`: método vencido visible con icono + “Vencido”, no solo color.
- Se mantuvieron los targets 48 de 10G-A.

### Home

- Se corrigió el círculo decorativo que quedaba oculto bajo el fondo opaco del
  hero.

### Responsive, Dark y text scale

Se agregaron pruebas para:

- `CheckoutSuccess`: 320/390/800 y text scale 1.3/2.0.
- `AddressForm`: 320/390/800 y text scale 1.3/2.0.
- `MainShell`: 320/390/412/800 y text scale 1.3/2.0.
- Results, Detail y AddressList: 320×640 + text scale 2.0.
- Success y MainShell en Dark.
- ProductImage fallback en Light/Dark.

### Dependencias

Se auditó `cupertino_icons`: no tenía referencias en `lib/` ni `test/`. Al
retirarlo, el build Web emitió un warning de fuente faltante porque el
tree-shaker de Flutter aún espera `CupertinoIcons`.

Se decidió **mantenerlo** para conservar un build Web limpio y evitar iconos
faltantes. No se agregaron dependencias nuevas ni se actualizaron versiones.

## Regresión

- `dart format --output=none --set-exit-if-changed lib test`: PASS.
- `flutter analyze`: PASS.
- `flutter test`: **421 pruebas aprobadas**.
- `git diff --check`: PASS.
- `flutter build web`: PASS.
- Android: **NO EJECUTADO** por falta de SDK/adb/emulador.

## Fuera de 10G-A

- Assets, ProductImage y Cart `Image.asset`: resueltos en 10G-B con A+;
  WebP pendiente de assets licenciados.
- Copy/iconografía masiva: resuelta en 10G-B.
- README, QA manual, capturas y PR: 10G-C.
