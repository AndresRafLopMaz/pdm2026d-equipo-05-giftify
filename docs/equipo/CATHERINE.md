# Catherine — módulo `cart/`

Rama personal: `catherine`
Módulo principal: `giftify/lib/features/cart/`

## Estado real integrado

### Carrito

Archivo: `giftify/lib/features/cart/screens/cart_screen.dart`

- Recibe `List<CartItem>` mediante `initialItems`.
- Copia la lista en `initState`; no existe carrito global ni persistencia.
- Permite incrementar y disminuir cantidades.
- No permite bajar de cantidad 1; para quitar un producto existe una acción
  explícita.
- Recalcula `subtotal` por producto y `total` general.
- Estado vacío: `Tu carrito está vacío`.
- Navega a `AppRoutes.checkout` con `List<CartItem>.of(_items)`.
- Formatea precios como `Q 0.00`.
- Usa `Image.network` solo si `imageAsset` es una URL válida; en caso contrario
  muestra un placeholder.

### Checkout

Archivo: `giftify/lib/features/cart/screens/checkout_screen.dart`

- Recibe `List<CartItem>` mediante `items`.
- Muestra resumen, subtotales y total.
- Campos obligatorios de entrega: destinatario, dirección, ciudad y
  departamento; la referencia es opcional.
- Construye `DeliveryAddress` sin persistirlo.
- Métodos de pago: tarjeta simulada y pago contra entrega.
- La tarjeta se representa como `Tarjeta simulada •••• 4242`; no se capturan
  datos financieros reales.
- Confirmación simulada con `Future.delayed` de 300 ms.
- Bloquea dobles envíos mientras `_isProcessing` es verdadero.
- Estado sin productos: `No hay productos para procesar.`
- No realiza pagos, llamadas HTTP ni almacenamiento.

Pruebas existentes:

- `cart_screen_test.dart` (9 pruebas).
- `checkout_screen_test.dart` (11 pruebas).

## Enfoque de la siguiente etapa

1. Validar el flujo `Detalle -> CartItem -> Carrito -> Checkout` con los datos
   reales de `mockProducts`.
2. Revisar totales, cantidades, eliminación, estado vacío y navegación.
3. Mantener el pago como simulación. No implementar pasarelas ni capturar
   números de tarjeta.
4. Si el laboratorio de estados asíncronos asigna este módulo, no inventar una
   API remota. La opción defendible es un repositorio de carrito inyectable que
   cargue una lista local de forma asíncrona y permita probar carga, error,
   vacío y datos. Si el equipo decide que eso empeora la arquitectura, elegir
   otra pantalla y documentarlo.
5. Agregar la prueba del estado de error con un repositorio falso si se adopta
   el patrón asíncrono.

## Reglas específicas

- No almacenar datos financieros reales.
- No implementar pagos reales.
- No modificar `CartItem`, `DeliveryAddress` o `PaymentMethodType` sin coordinar
  con los módulos que los consumen.
- No modificar `features/products/` sin coordinar con Andrés.
- No introducir persistencia local o SQLite sin una necesidad funcional
  concreta y aprobación del equipo.
- Mantener el carrito actual por argumentos de navegación hasta que exista una
  decisión explícita de estado global.

## Coordinación

- Dependencia directa: Andrés (`products/`), porque el detalle crea `CartItem`.
- Dependencia de contrato: `shared/models/cart_item.dart`,
  `shared/models/delivery_address.dart` y
  `shared/enums/payment_method_type.dart`.
- Dependencia de navegación: `app_router.dart` para `AppRoutes.cart` y
  `AppRoutes.checkout`.

## Validación antes de cerrar una tarea

Desde `giftify/`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/cart_screen_test.dart
flutter test test/checkout_screen_test.dart
flutter test
```

Actualizar:

- `docs/bitacoras/CATHERINE.md`
- `docs/bitacora-ia.md` si se usó IA
