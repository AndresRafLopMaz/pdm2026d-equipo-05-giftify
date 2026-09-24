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
