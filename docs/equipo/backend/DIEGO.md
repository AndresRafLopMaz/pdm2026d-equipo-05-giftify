ESTADO: PLANIFICACIÓN FUTURA — NO IMPLEMENTAR DURANTE EL MVP LOCAL

# Diego — Auth y usuarios (futuro)

Responsabilidad futura:

- autenticación;
- `UserProfile`;
- sesión;
- tabla o servicio de usuarios;
- relación entre usuario y direcciones/órdenes.

Reglas:

- no guardar contraseñas en texto plano;
- no reutilizar `UserProfile` como credencial;
- el backend gestiona autenticación y sesión;
- la UI no conoce tokens, SQL ni URLs internas.

No implementar durante el MVP local. Ver
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.
