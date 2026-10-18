ESTADO: PLANIFICACIÓN FUTURA — NO IMPLEMENTAR DURANTE EL MVP LOCAL

# Contexto de backend remoto

Este documento describe responsabilidades futuras. No contiene instrucciones
para ejecutar backend ahora.

## Arquitectura

```text
UI
 ↓
Repository
 ↓
Remote implementation
 ↓
BackendClient / SDK
 ↓
Backend
```

## Reglas

- La UI no conoce SQL.
- La UI no conoce URLs.
- La UI no parsea JSON.
- No duplicar modelos compartidos.
- No subir secretos ni credenciales.
- Los cambios en `app/`, `core/` o `shared/` requieren coordinación.
- SQLite no es backend; es persistencia local.
- Supabase es una recomendación preliminar, no una decisión definitiva.
- Esta fase se realizará después de cerrar el MVP local.

La planificación extensa vive en
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`.

## Distribución conceptual

| Integrante | Área futura |
|---|---|
| Diego | Auth, UserProfile, sesión y usuarios |
| Brayan | Search, GiftSearchCriteria y consultas |
| Andrés | Products, ProductRepository, catálogo, vendedores y disponibilidad |
| Catherine | Cart, DeliveryAddress y órdenes |

No implementar nada de esta carpeta durante el MVP local.
