# QA final Android — Giftify

## Estado

**PENDIENTE DE EJECUCIÓN MANUAL.**

En el entorno actual:

- Android SDK: no disponible.
- `adb`: no disponible.
- Emulador/dispositivo Android: no disponible.

`flutter doctor -v` reporta `Unable to locate Android SDK`. Los checks siguientes
no están marcados como completados.

## Preparación

1. Instalar Android SDK y `adb`.
2. Habilitar un dispositivo físico o emulador.
3. Ejecutar desde `giftify/`:

```bash
flutter pub get
flutter run -d <device-id>
```

4. Usar datos de prueba; no ingresar datos reales.

## AUTH

- [ ] Register con nombre, correo y contraseña válidos.
- [ ] Login con las credenciales registradas.
- [ ] Logout desde Profile.
- [ ] Cerrar la app y volver a abrir.
- [ ] Confirmar restauración de sesión.
- [ ] Password incorrecto muestra error genérico.
- [ ] Correo duplicado muestra mensaje humano.

## MULTIUSUARIO

- [ ] Usuario A crea dirección, carrito, producto eliminado y pago.
- [ ] Logout de A.
- [ ] Usuario B no ve datos de A.
- [ ] Usuario B crea sus propios datos.
- [ ] Volver a A recupera sus datos.
- [ ] Alternar A/B una segunda vez.

## SEARCH

- [ ] Prefill desde categorías de Home.
- [ ] Filtros de destinatario, ocasión e intereses.
- [ ] Presupuesto válido y errores de presupuesto.
- [ ] Más detalles.
- [ ] Results.
- [ ] Detail.
- [ ] Back sin “Ruta no encontrada”.

## CART

- [ ] Add to Cart desde Detail.
- [ ] Cambiar cantidad.
- [ ] Eliminar y Deshacer.
- [ ] Persistencia tras reinicio.
- [ ] Checkout CTA.
- [ ] Empty state.

## ADDRESSES

- [ ] Crear dirección.
- [ ] Editar dirección.
- [ ] Marcar como principal.
- [ ] Archivar.
- [ ] Restaurar.
- [ ] Eliminar una dirección no principal.
- [ ] Persistencia tras reinicio.

## PAYMENTS

- [ ] Crear método ficticio.
- [ ] Establecer predeterminado.
- [ ] Visualizar método vencido.
- [ ] Eliminar método.
- [ ] Confirmar aviso de datos ficticios.
- [ ] Confirmar ausencia de PAN/CVV.

## CHECKOUT

- [ ] Dirección predeterminada.
- [ ] Cambiar dirección.
- [ ] Pago vigente.
- [ ] Todos los pagos vencidos.
- [ ] Agregar pago desde el selector.
- [ ] Confirmar compra simulada.
- [ ] Success.
- [ ] Volver a Inicio.
- [ ] Carrito vacío después de confirmar.
- [ ] Back/CTA no revelan Checkout confirmado.

## THEME

- [ ] Light.
- [ ] Dark.
- [ ] System.
- [ ] Persistencia tras reinicio.
- [ ] Dialogs, bottom sheets, date picker y snackbars en Dark.

## UX / HARDWARE

- [ ] Teclado no tapa campos críticos.
- [ ] Back físico/gesto.
- [ ] Safe areas.
- [ ] Sin overflow en resolución móvil.
- [ ] Touch targets ≥ 48.
- [ ] Rotación: evaluar si entra en alcance de la entrega.

## Evidencia

Registrar dispositivo, versión Android, build y capturas únicamente después de
la ejecución real. No marcar checks sin evidencia.
