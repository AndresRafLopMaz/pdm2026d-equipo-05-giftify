ESTADO: PLANIFICACIÓN FUTURA — NO IMPLEMENTAR DURANTE EL MVP LOCAL

# Andrés — Products y catálogo (futuro)

Responsabilidad futura:

- `RemoteProductRepository`;
- catálogo de productos;
- vendedores;
- disponibilidad;
- mapeo de JSON a `GiftProduct`;
- manejo de errores remotos.

Arquitectura:

```text
ProductRepository
        ↓
RemoteProductRepository
        ↓
BackendClient / SDK
        ↓
Backend
```

Reglas:

- la UI no conoce URLs, SQL ni JSON;
- no duplicar `GiftProduct`;
- no cambiar el contrato sin coordinar con Search, Cart y Checkout;
- `MockProductRepository` se conserva para pruebas locales.

No implementar durante el MVP local. Ver
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.
