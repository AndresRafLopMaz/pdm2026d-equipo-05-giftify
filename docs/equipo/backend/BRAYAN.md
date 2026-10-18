ESTADO: PLANIFICACIÓN FUTURA — NO IMPLEMENTAR DURANTE EL MVP LOCAL

# Brayan — Search y consultas (futuro)

Responsabilidad futura:

- contrato de búsqueda;
- `GiftSearchCriteria`;
- consultas de productos;
- filtrado local o del servidor según decisión técnica;
- integración Search → Results con datos remotos.

Reglas:

- no duplicar `GiftSearchCriteria`;
- no mover lógica de resultados a Search sin coordinación;
- la UI no conoce SQL, JSON ni URLs;
- el filtrado remoto debe conservar el comportamiento esperado.

No implementar durante el MVP local. Ver
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.
