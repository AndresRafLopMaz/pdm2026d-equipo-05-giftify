ESTADO: PLANIFICACIÓN FUTURA — NO IMPLEMENTAR DURANTE EL MVP LOCAL

# Catherine — Cart y órdenes (futuro)

Responsabilidad futura:

- carrito persistente o sincronizado;
- `DeliveryAddress`;
- órdenes;
- relación entre orden, usuario, dirección y productos;
- integración con un proveedor de pagos, si existe.

Reglas:

- no almacenar números completos de tarjeta, CVV ni secretos;
- los pagos reales quedan fuera del MVP local;
- no duplicar `CartItem`, `DeliveryAddress` ni `PaymentMethodType`;
- la UI no conoce SQL, JSON ni URLs.

No implementar durante el MVP local. Ver
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.
