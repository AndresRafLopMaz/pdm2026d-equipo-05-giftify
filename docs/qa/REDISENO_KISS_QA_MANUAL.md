# QA manual — Rediseño KISS de Giftify

**Estado:** pendiente de ejecución manual.

No marcar una casilla si no se probó en un dispositivo o emulador real.
La QA automatizada no sustituye esta revisión visual.

## Preparación

- [ ] Ejecutar la app en Android o Windows.
- [ ] Confirmar que la app abre en Registro.
- [ ] Confirmar que no hay texto cortado ni overflow visible.
- [ ] Revisar en 320x640.
- [ ] Revisar en 390x844.
- [ ] Revisar en tablet o ventana ancha.

## Register

- [ ] El formulario y sus cuatro campos son visibles.
- [ ] Las validaciones de nombre, correo y contraseña funcionan.
- [ ] La fecha de nacimiento abre el selector.
- [ ] Mostrar/ocultar contraseña funciona.
- [ ] No hay overflow con el teclado abierto.
- [ ] Un registro válido navega a Home.

## Home

- [ ] `Buscar un regalo` abre la tab Buscar.
- [ ] `Catálogo` abre la tab Catálogo.
- [ ] `Carrito` abre la tab Carrito.
- [ ] `Mis direcciones` abre Addresses.
- [ ] Los accesos secundarios no desbordan en 320x640.

## Search

- [ ] Ocasión, destinatario y presupuesto son obligatorios.
- [ ] `Más opciones` muestra fecha, tipo y tamaño.
- [ ] Las validaciones impiden continuar con datos inválidos.
- [ ] `Buscar regalos` abre Results con los criterios.

## Results

- [ ] Los filtros abren y actualizan la lista.
- [ ] Tocar una fila abre Detail.
- [ ] El resumen de búsqueda es legible.
- [ ] El badge de disponibilidad no desborda.
- [ ] Swipe elimina y `Deshacer` restaura.
- [ ] Empty, error y Reintentar se muestran correctamente.
- [ ] Los textos largos no rompen la fila.

## Detail

- [ ] La imagen/placeholder se muestra correctamente.
- [ ] Precio, disponibilidad y metadatos son legibles.
- [ ] El CTA `Agregar al carrito` queda fijo abajo.
- [ ] Un producto agotado deshabilita el CTA.
- [ ] Un producto `unknown` advierte y deshabilita el CTA.
- [ ] Agregar al carrito navega a Cart con el producto.

## Cart

- [ ] El carrito persistido aparece después de reabrir la app.
- [ ] Aumentar y disminuir cantidad actualiza subtotal y total.
- [ ] No se puede bajar de 1.
- [ ] El filtro no altera el total.
- [ ] Filtro sin resultados muestra el estado correcto.
- [ ] Eliminar y `Deshacer` restauran el producto.
- [ ] `Continuar al pago` recibe todos los ítems aunque haya filtro.
- [ ] La barra de total y CTA no tapa contenido.

## Checkout

- [ ] Los cuatro campos obligatorios validan.
- [ ] La referencia es opcional.
- [ ] Tarjeta y pago contra entrega son seleccionables.
- [ ] No se solicitan datos financieros reales.
- [ ] El total coincide con el carrito.
- [ ] `Confirmar pedido` muestra la confirmación simulada.
- [ ] El CTA sigue visible con el teclado abierto.

## Addresses

- [ ] Crear una dirección.
- [ ] Editar conserva el mismo ID.
- [ ] Etiqueta duplicada muestra el mensaje humano.
- [ ] Cambiar la dirección principal.
- [ ] Intentar eliminar la principal muestra el diálogo de bloqueo.
- [ ] Archivar una dirección no principal.
- [ ] Restaurar una dirección archivada.
- [ ] Eliminar una dirección no principal.
- [ ] Cerrar y reabrir la app conserva las direcciones.
- [ ] Activas/Archivadas no desborda.
- [ ] El menú y el CTA inferior siguen accesibles.

## Cierre

- [ ] No hay overflow en 320x640.
- [ ] No hay overflow en 390x844.
- [ ] No hay overflow en tablet/web.
- [ ] No se observan CTAs duplicados.
- [ ] No se observan acciones muertas.
- [ ] Registrar capturas si el equipo lo solicita.
