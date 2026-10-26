## Sesión 2026-09-22

### Objetivo
Implementar y validar la Pantalla 6 — Carrito de compras.

### Trabajo realizado
- Se convirtió CartScreen en StatefulWidget.
- Se implementó manejo local de los productos recibidos mediante List<CartItem>.
- Se agregó incremento y decremento de cantidades.
- Se estableció una cantidad mínima de 1.
- Se implementó eliminación explícita de productos.
- Se mostraron precio unitario, subtotal y total general en quetzales.
- Se implementó el estado de carrito vacío.
- Se agregó navegación hacia Checkout mediante AppRoutes.checkout.
- Se agregó comportamiento responsive para pantallas móviles estrechas.
- Se realizó validación visual en una resolución de 390x844.
- Se comprobó correctamente el estado vacío y el botón de continuar deshabilitado.

### Archivos modificados
- `giftify/lib/features/cart/screens/cart_screen.dart`
- `giftify/test/cart_screen_test.dart`

### Decisiones técnicas
- El estado del carrito se administra únicamente mediante StatefulWidget y setState().
- initialItems se copia mediante List<CartItem>.of().
- Las cantidades se actualizan utilizando CartItem.copyWith().
- Los subtotales utilizan CartItem.subtotal.
- El total se deriva de los subtotales actuales.
- No se implementó backend.
- No se implementó persistencia.
- No se implementaron pagos reales.
- No se modificaron módulos ajenos.
- No se modificó ProductDetailScreen.

### Pruebas realizadas
- `flutter analyze` — OK, sin problemas.
- `flutter test` — OK, 15 pruebas aprobadas.
- `git diff --check` — OK.
- Prueba responsive automatizada a 320x640 — OK.
- Validación visual manual a 390x844 — OK.

### Pendientes
- Implementar Pantalla 7 — Check-out.
- Realizar integración completa desde ProductDetail cuando el módulo correspondiente esté disponible.
- Ajustar fidelidad visual si posteriormente se proporciona la referencia V2.

### Impacto para otros módulos
- CartScreen conserva el contrato List<CartItem>.
- La navegación a Checkout envía la lista actualizada mediante AppRoutes.checkout.
- No se modificaron contratos compartidos ni otros módulos.

## Sesión 2026-09-22 — Check-out

### Objetivo
Implementar y validar la Pantalla 7 — Check-out simulado.

### Trabajo realizado
- Se convirtió CheckoutScreen en StatefulWidget.
- Se implementó el resumen de productos con nombre, cantidad, subtotal y total.
- Se agregó formulario local para dirección de entrega.
- Se validaron como obligatorios nombre del receptor, dirección, ciudad y departamento.
- Se mantuvo la referencia como campo opcional.
- Se construyó DeliveryAddress únicamente en memoria después de validar el formulario.
- Se implementó selección de método de pago mediante PaymentMethodType.
- Se agregó opción de tarjeta simulada.
- Se agregó opción de pago contra entrega.
- Se evitó solicitar o almacenar información financiera real.
- Se implementó confirmación local con bloqueo temporal para evitar dobles envíos.
- Se agregó diálogo de confirmación.
- Se implementó estado seguro cuando no existen productos.
- Se ajustó el diseño responsive para pantallas móviles estrechas.

### Archivos modificados
- `giftify/lib/features/cart/screens/checkout_screen.dart`
- `giftify/test/checkout_screen_test.dart`

### Decisiones técnicas
- El estado se administra únicamente mediante StatefulWidget y setState().
- DeliveryAddress se crea únicamente después de una validación correcta.
- DeliveryAddress permanece únicamente en memoria.
- El método de pago utiliza PaymentMethodType como fuente de estado.
- La simulación de tarjeta utiliza únicamente un texto fijo con terminación 4242.
- No se solicitan números completos de tarjeta, CVV, PIN ni credenciales.
- No se implementó backend.
- No se implementó persistencia.
- No se implementó una pasarela de pagos.
- No se creó una pantalla adicional de pedidos.
- No se modificaron CartScreen, ProductDetailScreen, router ni modelos compartidos.

### Pruebas realizadas
- `flutter analyze` — OK, sin problemas.
- `flutter test` — OK, 25 pruebas aprobadas.
- `git diff --check` — OK.
- 10 pruebas específicas de CheckoutScreen — OK.
- Prueba responsive automatizada a 320x640 — OK.

### Pendientes
- Realizar integración completa desde ProductDetail cuando el módulo correspondiente esté disponible.
- Revisar fidelidad visual cuando se disponga de la referencia V2.
- Realizar validación integrada del flujo completo Cart → Checkout cuando las pantallas anteriores estén terminadas.

### Impacto para otros módulos
- CheckoutScreen conserva el contrato List<CartItem>.
- Utiliza DeliveryAddress y PaymentMethodType existentes.
- No se modificaron contratos compartidos.
- No se introdujeron dependencias nuevas.

## Sesión 2026-09-23 — Ajuste visual V2

### Objetivo
Ajustar visualmente las pantallas de Carrito y Check-out para acercarlas al prototipo V2 sin modificar la lógica funcional existente.

### Trabajo realizado
- Se ajustó CartScreen tomando V2 como referencia visual.
- Se añadió divisor bajo el encabezado.
- Se estilizaron las tarjetas de productos con bordes redondeados y apariencia más compacta.
- Se aplicó el color rosa a las acciones principales del módulo.
- Se redujo visualmente el tamaño de controles de cantidad.
- Se destacó el total y el botón inferior de continuación.
- Se reorganizó CheckoutScreen con el orden: dirección, método de pago, resumen y confirmación.
- Se estilizó el formulario de dirección mediante tarjetas y detalles visuales rosas.
- Los métodos de pago dejaron de representarse mediante ChoiceChip y pasaron a tarjetas seleccionables.
- Se mantuvo PaymentMethodType como fuente real del estado.
- Se añadió una barra inferior estable para Confirmar pedido.
- Se ajustó el estado vacío de Checkout para utilizar rosaPrincipal.
- Se corrigieron problemas de overflow detectados en pantallas estrechas.
- Se validó el comportamiento con teclado simulado.

### Archivos modificados
- `giftify/lib/features/cart/screens/cart_screen.dart`
- `giftify/lib/features/cart/screens/checkout_screen.dart`
- `giftify/test/checkout_screen_test.dart`

### Decisiones técnicas
- El prototipo V2 se utilizó únicamente como referencia visual.
- No se modificaron contratos, modelos ni navegación.
- No se modificó el tema global.
- Los colores rosas se aplicaron localmente al módulo.
- No se agregaron ratings, navegación a ProductDetail ni datos inexistentes.
- No se agregaron direcciones persistentes.
- No se agregaron datos financieros ni pagos reales.
- El botón final se mantiene como "Confirmar pedido" porque el flujo representa una simulación y no un cobro real.

### Pruebas realizadas
- `dart format lib test` — OK.
- `flutter analyze` — OK, sin problemas.
- `flutter test` — OK, 26 pruebas aprobadas.
- `git diff --check` — OK.
- Responsive 320x640 — OK.
- Teclado simulado con viewInsets — OK.
- Validación visual manual a 390x844 — OK.

### Pendientes
- Integrar ProductDetail → Cart cuando el módulo correspondiente esté disponible.
- Realizar prueba visual completa con productos cuando exista integración entre pantallas.
- Validar el flujo completo ProductDetail → Cart → Checkout con los demás integrantes.

### Impacto para otros módulos
- No se modificaron otros módulos.
- CartScreen mantiene List<CartItem>.
- CheckoutScreen mantiene List<CartItem>.
- Se conservan DeliveryAddress y PaymentMethodType.
- No se agregaron dependencias.

## Sesión 2026-10-18 — Integración Cart → Checkout

### Objetivo
Cerrar Cart y Checkout del MVP local mediante una prueba de integración del flujo real entre ambas pantallas.

### Trabajo realizado
- Se sincronizó `catherine` con `origin/catherine` y `origin/main` sin conflictos.
- Se creó `giftify/test/cart_checkout_flow_test.dart`.
- Se construyó un `CartItem` conocido con cantidad inicial 1.
- Se incrementó la cantidad a 2 mediante la interacción real de CartScreen.
- Se verificaron subtotal y total actualizados a `Q 250.00`.
- Se navegó mediante `AppRoutes.checkout` y `AppRouter.onGenerateRoute`.
- Se comprobó que CheckoutScreen recibió el mismo producto con cantidad 2.
- Se comprobó que los totales de Cart y Checkout coinciden.
- Se repitió el flujo completo a 320x640 sin overflow.

### Archivos modificados
- `giftify/test/cart_checkout_flow_test.dart`
- `docs/bitacoras/CATHERINE.md`

### Decisiones técnicas
- La prueba utiliza únicamente constructores, propiedades públicas y ValueKey existentes.
- El total esperado utiliza `CartItem.subtotal`; no se accede a estado privado.
- Se utiliza la navegación real del router, sin mocks ni rutas alternativas.
- No fue necesario modificar CartScreen ni CheckoutScreen porque la prueba no reveló defectos.
- No se modificaron modelos compartidos, router ni módulos de otros integrantes.
- No se agregó backend, persistencia ni pagos reales.

### Pruebas realizadas
- Línea base después de sincronizar: 59 pruebas aprobadas.
- `dart format lib test` — OK.
- `flutter analyze` — OK, sin problemas.
- `flutter test test/cart_checkout_flow_test.dart` — OK, 2 pruebas aprobadas.
- `flutter test` — OK, 61 pruebas aprobadas.
- Flujo normal Cart → Checkout — OK.
- Flujo Cart → Checkout a 320x640 — OK, sin overflow.

### Pendientes
- Integrar posteriormente la rama `catherine` al MVP del equipo según el orden acordado.
- Mantener pagos y persistencia fuera de alcance hasta una decisión futura del equipo.

### Impacto para otros módulos
- No se modificaron otros módulos.
- Se conservaron `List<CartItem>`, `CartItem`, `DeliveryAddress`, `PaymentMethodType` y `AppRoutes`.
- No se agregaron dependencias.

### Cierre de la tarea

- Commit funcional: `1744a5f872de43ad685d0c40f4f773c843dac7b2`.
- Mensaje: `test: verificar flujo de carrito a checkout`.
- Push realizado a `origin/catherine`.
- Prueba Cart → Checkout con cantidad modificada.
- Subtotal y total verificados tras el cambio de cantidad.
- Checkout recibe la lista actualizada y el total coincide con Cart.
- Responsive 320×640 sin overflow.
- Formato: OK.
- Analyze: sin problemas.
- Tests de la rama en esa validación: 61 aprobadas.
- `git diff --check`: sin errores.

## Sesión 2026-10-25 — Filtro, persistencia y Deshacer en Cart

### Objetivo
Implementar la parte principal del Issue #27 en
`feat/27-filtro-carrito`, conservando ProductDetail → Cart → Checkout y el
diseño V2.

### Trabajo realizado
- Se creó `CartRepository` con carga, incorporación, actualización de cantidad,
  eliminación y restauración.
- Se implementó `PersistentCartRepository` con operaciones serializadas para
  evitar escrituras concurrentes y pérdida de cantidades.
- Se persistieron únicamente `productId` y `quantity` mediante
  `shared_preferences`.
- Se reconstruyeron los `CartItem` con los productos canónicos de
  `mockProducts`; los IDs desconocidos producen error en lugar de descartarse.
- Se agregó `CartFilter` inmutable y `CartFilterNotifier` por categoría.
- Se implementó `cartItemsProvider` asíncrono y reactivo al filtro, con retry
  automático desactivado.
- Se creó `CartSnapshot` con `allItems`, `visibleItems`, categorías y total.
- Se migró `CartScreen` a `ConsumerStatefulWidget` sin cambiar su contrato
  `List<CartItem> initialItems`.
- Los elementos entrantes se fusionan una sola vez y suman cantidades por ID.
- Se añadieron loading, error con Reintentar y empty específico por filtro.
- Se agregó filtro horizontal por categoría y acción Limpiar filtro.
- Se agregó `Dismissible` con `ValueKey(product.id)`.
- El botón de eliminar y el swipe comparten eliminación repository-first.
- Se agregó SnackBar con Deshacer y restauración persistente en la posición
  original.
- Los errores de cantidad, delete y restore no muestran cambios no persistidos.
- El total y Checkout utilizan `allItems`; el filtro solo modifica
  `visibleItems`.

### Archivos creados
- `giftify/lib/features/cart/data/cart_filter.dart`
- `giftify/lib/features/cart/data/cart_repository.dart`
- `giftify/lib/features/cart/data/cart_store.dart`
- `giftify/lib/features/cart/data/persistent_cart_repository.dart`
- `giftify/lib/features/cart/providers/cart_filter_provider.dart`
- `giftify/lib/features/cart/providers/cart_items_provider.dart`
- `giftify/test/cart_filter_test.dart`
- `giftify/test/cart_items_provider_test.dart`
- `giftify/test/cart_repository_test.dart`

### Archivos modificados
- `giftify/lib/features/cart/screens/cart_screen.dart`
- `giftify/test/cart_screen_test.dart`
- `giftify/test/cart_checkout_flow_test.dart`
- `docs/bitacoras/CATHERINE.md`

### Pruebas realizadas
- Línea base: 104 pruebas aprobadas.
- Pruebas técnicas y regresiones dirigidas: 27 aprobadas.
- Suite completa tras la implementación: 120 pruebas aprobadas.
- `flutter analyze` — OK, sin problemas.
- Persistencia y reapertura con `SharedPreferences` — OK.
- Operaciones concurrentes del repositorio — OK.
- Flujo Cart → Checkout normal y 320x640 — OK.

### Decisiones técnicas
- Las operaciones del repositorio se serializan sobre una cola interna.
- Cada escritura construye el nuevo estado, persiste primero y solo entonces
  actualiza la UI.
- El almacenamiento usa un JSON atómico con pares `productId`/`quantity`.
- `CartFilter` no altera la fuente persistida ni el total general.
- Checkout recibe una copia de `allItems`, incluso cuando hay un filtro activo.
- No se modificaron ProductDetail, Checkout, AppRouter, modelos compartidos,
  dependencias ni módulos de Products.

### Pendientes para Diego
- Ampliar widget tests de filtros, empty filtrado, Dismissible, delete fallido,
  SnackBar y Deshacer fallido.
- Verificar en widget test que Checkout recibe todos los elementos con un filtro
  activo.
- Repetir QA responsive 320x640 y regresión global.
- Ejecutar CI conjunto y registrar sus resultados en su propia bitácora.

### Estado
- Implementación principal de Catherine terminada y validada localmente.
- Issue #27 y FASE 7 permanecen abiertos hasta completar el trabajo de Diego,
  QA conjunto, CI y review.
