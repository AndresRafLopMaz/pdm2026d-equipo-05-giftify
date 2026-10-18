# Catherine — cierre de Cart y Checkout

ESTADO: TRABAJO ACTUAL — MVP LOCAL

Rama personal: `catherine`

## 1. Objetivo

Cerrar `features/cart/` para un MVP local estable, sin pagos reales ni
persistencia, agregando la prueba de integración que falta.

## 2. Estado actual que NO debe reimplementarse

### Cart

- Recibe `List<CartItem>` por `initialItems`.
- Copia la lista en `initState`.
- Incrementa y disminuye cantidades.
- Cantidad mínima 1; eliminación explícita.
- Subtotal por producto y total general.
- Carrito vacío.
- Navegación a Checkout con la lista actualizada.
- Responsive.
- 9 pruebas de widget.

### Checkout

- Recibe `List<CartItem>`.
- Resumen, subtotales y total.
- Validación de destinatario, dirección, ciudad y departamento.
- Referencia opcional.
- `DeliveryAddress` en memoria.
- Pago simulado: tarjeta y contra entrega.
- No solicita ni almacena datos financieros reales.
- Bloquea dobles confirmaciones.
- Lista vacía controlada.
- Responsive y teclado.
- 11 pruebas de widget.

No reimplementar nada de esa lista.

## 3. Trabajo requerido

### P0

Ninguno. Cart y Checkout funcionan y están bien cubiertos.

### P1

Crear:

```text
giftify/test/cart_checkout_flow_test.dart
```

La prueba debe demostrar:

1. Construir un carrito con un `CartItem` conocido.
2. Renderizar `CartScreen`.
3. Cambiar la cantidad.
4. Verificar subtotal y total actualizados.
5. Ir a Checkout.
6. Capturar la lista enviada.
7. Verificar que Checkout recibe los `CartItem` actualizados.
8. Verificar que el total de Checkout coincide con el total de Cart.
9. No depender de backend ni persistencia.

Si es viable sin duplicar demasiado, repetir la verificación en 320×640.

### Fuera de alcance

- Pagos reales.
- Persistencia.
- Nuevas funcionalidades de carrito.
- CTA de “Buscar regalos” en carrito vacío (P2).

## 4. Flujo funcional

```text
ProductDetailScreen
        ↓
CartItem
        ↓
CartScreen
        ↓
List<CartItem>
        ↓
CheckoutScreen
```

## 5. Archivos que debe leer

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

## 6. Archivos que puede modificar

```text
giftify/test/cart_checkout_flow_test.dart
giftify/lib/features/cart/screens/cart_screen.dart
giftify/lib/features/cart/screens/checkout_screen.dart
docs/bitacoras/CATHERINE.md
```

Modificar las pantallas solo si la prueba revela un defecto real.

## 7. Archivos que NO debe modificar

```text
giftify/lib/shared/models/cart_item.dart
giftify/lib/shared/models/delivery_address.dart
giftify/lib/shared/enums/payment_method_type.dart
giftify/lib/features/products/
giftify/lib/features/search/
giftify/lib/app/app_router.dart
giftify/pubspec.yaml
docs/bitacora-ia.md
```

Motivo: modelos compartidos, módulos ajenos y contratos de navegación.

## 8. Implementación esperada

Puede reutilizar los helpers existentes de `cart_screen_test.dart` y
`checkout_screen_test.dart`, o crear helpers locales en el nuevo archivo.

Secuencia sugerida:

1. Crear un `CartItem` con un producto de `mockProducts` y cantidad 1.
2. Renderizar `CartScreen(initialItems: [item])` dentro de `MaterialApp` con
   `AppRoutes`/`onGenerateRoute`.
3. Pulsar el botón de incremento:

```text
ValueKey('increase-${product.id}')
```

4. Verificar el total del carrito:

```text
ValueKey('cart-total')
```

5. Pulsar:

```text
ValueKey('checkout-button')
```

6. Capturar:

```dart
final checkout = tester.widget<CheckoutScreen>(
  find.byType(CheckoutScreen),
);
```

7. Verificar `checkout.items.length`, la cantidad y el producto.
8. Calcular el total esperado:

```dart
final expectedTotal = checkout.items.fold<double>(
  0,
  (total, item) => total + item.subtotal,
);
```

9. Comparar con el total mostrado en Checkout:

```text
ValueKey('checkout-total')
```

10. Verificar que el texto coincide con el total del carrito.

No acceder a métodos privados ni duplicar la lógica de las pantallas.

## 9. Casos que debe cubrir

- Cambio de cantidad en Cart.
- Subtotal y total actualizados.
- Checkout recibe la lista actualizada.
- Total de Checkout coincide con Cart.
- Sin backend ni persistencia.
- Opcional: misma verificación a 320×640.

## 10. Pruebas

Agregar solo la prueba de integración. Mantener las 9 pruebas de Cart y 11 de
Checkout. No duplicar validaciones, métodos de pago, doble confirmación,
responsive o teclado que ya están cubiertos.

## 11. Validación visual

- La integración debe funcionar en tamaño normal.
- Si se agrega 320×640, verificar que no hay overflow.
- No cambiar el diseño si la prueba pasa.

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

Actualizar `docs/bitacoras/CATHERINE.md` con:

- objetivo;
- prueba de integración creada;
- total verificado;
- si hubo corrección real;
- resultados;
- pendientes.

No modificar `docs/bitacora-ia.md` durante el trabajo paralelo.

## 14. Git

```powershell
git fetch --all --prune
git switch catherine
git pull --ff-only origin catherine
git merge origin/main

# trabajo y validación

git status
git diff --stat
git add giftify/test/cart_checkout_flow_test.dart
# si hubo un ajuste real:
# git add giftify/lib/features/cart/screens/cart_screen.dart
# git add giftify/lib/features/cart/screens/checkout_screen.dart
git add docs/bitacoras/CATHERINE.md
git diff --cached --name-status
git diff --cached --check
git commit -m "test: verificar flujo de carrito a checkout"
git push origin catherine
```

## 15. Evidencias

- Salida de `flutter analyze`.
- Total de tests y `All tests passed`.
- Evidencia del test Cart → Checkout con total consistente.
- `git diff --check` limpio.
- `git status` final.
- SHA del commit.
- Rama remota actualizada.

## 16. Criterios de cierre

```text
[ ] Test de integración Cart → Checkout creado
[ ] Cantidad actualizada verificada
[ ] Subtotal/total de Cart verificados
[ ] Checkout recibe los items actualizados
[ ] Total de Checkout coincide con Cart
[ ] Tests existentes siguen pasando
[ ] dart format lib test correcto
[ ] flutter analyze sin issues
[ ] flutter test verde
[ ] git diff --check limpio
[ ] Bitácora actualizada
[ ] Commit y push a catherine
```

## 17. Prohibiciones

- No pagos reales.
- No persistencia.
- No almacenar números completos de tarjeta, CVV ni secretos.
- No modificar modelos compartidos, router, Products ni Search.
- No agregar dependencias.
- No modificar `docs/bitacora-ia.md` en esta fase.
