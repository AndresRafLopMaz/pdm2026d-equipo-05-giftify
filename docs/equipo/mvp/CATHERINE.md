# Catherine — cierre de Cart y Checkout

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `catherine`

## 1. Objetivo

Cerrar `features/cart/` para un MVP local estable, sin pagos reales ni
persistencia.

## 2. Estado real verificado

### Cart

- Recibe `List<CartItem>` por `initialItems`.
- Copia la lista en `initState`.
- Incrementa y disminuye cantidades.
- No permite bajar de 1; la eliminación es explícita.
- Calcula subtotal por producto y total general.
- Muestra estado vacío.
- Navega a Checkout con la lista actualizada.
- Es responsive y tiene 9 pruebas de widget.

### Checkout

- Recibe `List<CartItem>`.
- Muestra resumen, subtotales y total.
- Valida destinatario, dirección, ciudad y departamento.
- La referencia es opcional.
- Construye `DeliveryAddress` en memoria.
- Métodos simulados: tarjeta y pago contra entrega.
- No solicita ni almacena datos financieros reales.
- Bloquea dobles confirmaciones mientras procesa.
- Maneja lista vacía y es responsive.
- Tiene 11 pruebas de widget.

La cobertura de este módulo ya es sólida. No se deben duplicar pruebas
existentes.

## 3. Brecha real detectada

Las pruebas cubren Cart y Checkout por separado, y existe una prueba de
navegación con la lista actualizada. No existe una prueba de integración que
verifique en conjunto que, después de cambiar cantidades en Cart, el total que
muestra Checkout coincide con el total del carrito.

Esa es la única brecha clara; agregarla solo si aporta valor y sin repetir las
pruebas unitarias ya existentes.

## 4. Lecturas obligatorias

```text
docs/equipo/00_REGLAS_COMUNES.md
docs/equipo/mvp/00_CONTEXTO_MVP_LOCAL.md
docs/bitacoras/CATHERINE.md
giftify/lib/features/cart/screens/cart_screen.dart
giftify/lib/features/cart/screens/checkout_screen.dart
giftify/lib/shared/models/cart_item.dart
giftify/lib/shared/models/delivery_address.dart
giftify/lib/shared/enums/payment_method_type.dart
giftify/test/cart_screen_test.dart
giftify/test/checkout_screen_test.dart
```

## 5. Tareas pertinentes

1. Mantener las pruebas actuales de cantidades, eliminación, subtotales,
   totales, estado vacío, validaciones, métodos de pago, doble confirmación,
   responsive y teclado.
2. Agregar una prueba de integración Cart → Checkout:
   - cargar dos productos;
   - cambiar una cantidad en Cart;
   - navegar a Checkout;
   - verificar que la lista y el total coinciden.
3. Verificar que no se solicitan ni muestran números completos de tarjeta, CVV
   o secretos.
4. Corregir solo defectos reales que aparezcan en la prueba de integración.

No agregar funcionalidades nuevas al carrito ni al checkout.

## 6. Archivos permitidos

```text
giftify/lib/features/cart/screens/cart_screen.dart
giftify/lib/features/cart/screens/checkout_screen.dart
giftify/test/cart_screen_test.dart
giftify/test/checkout_screen_test.dart
giftify/test/cart_checkout_flow_test.dart
docs/bitacoras/CATHERINE.md
```

## 7. Archivos compartidos o restringidos

Requieren coordinación:

```text
giftify/lib/app/app_router.dart
giftify/lib/shared/models/cart_item.dart
giftify/lib/shared/models/delivery_address.dart
giftify/lib/shared/enums/payment_method_type.dart
```

No modificar Products, Search, Home ni Auth.

## 8. Criterios de aceptación

```text
[ ] Las pruebas existentes siguen pasando
[ ] Cantidades y totales siguen correctos
[ ] El carrito vacío sigue mostrando su estado
[ ] Checkout recibe la lista actualizada
[ ] El total de Checkout coincide con el total de Cart
[ ] No se almacenan datos financieros reales
[ ] No hay overflow a 320×640
[ ] dart format, flutter analyze y flutter test pasan
```

## 9. Pruebas necesarias

- integración Cart → Checkout con total consistente;
- mantener las 9 pruebas de Cart y 11 de Checkout.

## 10. Bitácora

Actualizar `docs/bitacoras/CATHERINE.md` con objetivo, archivos, decisiones,
pruebas y pendientes. Registrar IA en `docs/bitacora-ia.md` si aplica.

## 11. Resultado esperado del PR

Un PR pequeño, centrado en la prueba de integración y en cualquier corrección
real detectada, sin pagos reales, sin persistencia y con CI en verde.
