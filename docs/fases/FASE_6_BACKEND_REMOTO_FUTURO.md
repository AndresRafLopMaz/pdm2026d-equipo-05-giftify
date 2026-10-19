# Giftify — Fase 6: Backend remoto futuro

ESTADO: PLANIFICADA / NO IMPLEMENTADA

Este documento conserva la planificación de una posible integración futura con
un backend remoto. No describe código existente ni autoriza a implementarlo
todavía.

## 1. Principio actual

El MVP de Giftify es **completamente local**:

```text
ProductResultsScreen
        ↓
ProductRepository
        ↓
MockProductRepository
        ↓
mockProducts
```

No hay Supabase, Firebase, API REST, SQLite, autenticación ni persistencia.

## 2. Arquitectura futura propuesta

```text
UI
 ↓
estado asíncrono
 ↓
ProductRepository
 ↓
RemoteProductRepository
 ↓
BackendClient
 ↓
Backend remoto
```

Responsabilidades:

- **UI:** muestra carga, error, vacío y datos; no conoce JSON, SQL, URLs ni el
  proveedor.
- **Estado asíncrono:** conserva el futuro, el error y el reintento.
- **ProductRepository:** contrato estable para obtener productos.
- **RemoteProductRepository:** implementación remota; arma la petición, valida
  la respuesta y mapea JSON a `GiftProduct`.
- **BackendClient:** infraestructura HTTP y configuración de la URL base.
- **Backend remoto:** base de datos, autenticación y reglas del servidor.

`RemoteProductRepository` sustituirá posteriormente a `MockProductRepository`
sin cambiar la pantalla.

## 3. Comparación de alternativas

### A. Supabase + PostgreSQL

- Es un backend real (BaaS).
- PostgreSQL relacional; buen ajuste para productos, vendedores y órdenes.
- Autenticación integrada.
- SDK de Flutter y API REST.
- Complejidad media y mantenimiento bajo para un equipo pequeño.
- Recomendación **preliminar**, no una decisión definitiva.

### B. Firebase / Firestore

- Es un backend real (BaaS).
- Firestore es documental; las relaciones producto–vendedor–orden requieren
  modelado adicional.
- Autenticación integrada.
- Integración Flutter sencilla.
- Rápido para prototipos, menos natural para datos relacionales.

### C. API REST + PostgreSQL

- Es un backend real.
- Modelo relacional y control total.
- Autenticación mediante tokens/JWT.
- Mayor complejidad: servidor, despliegue, CORS, seguridad y migraciones.
- Adecuado si el objetivo académico incluye construir el backend.

### D. SQLite local

- **No es un backend.** Es persistencia local en el dispositivo.
- No ofrece autenticación, multiusuario ni sincronización.
- Útil para caché offline, favoritos o carrito persistente.
- No sustituye a `RemoteProductRepository`.

## 4. Decisión actual

Para el MVP:

- se mantienen los datos locales;
- no se agrega SQLite;
- no se agrega Riverpod;
- no se implementa backend remoto;
- no se configuran servicios externos;
- no se agregan dependencias.

Supabase se considera una recomendación preliminar por su equilibrio entre
PostgreSQL, autenticación y facilidad para Flutter, pero la decisión definitiva
queda abierta.

## 5. Entidades futuras posibles

```text
users
products
sellers
addresses
orders
availability
```

Posibles relaciones:

```text
products.seller_id   -> sellers.id
orders.user_id       -> users.id
orders.address_id    -> addresses.id
availability.product_id -> products.id
order_items.order_id -> orders.id
order_items.product_id -> products.id
```

No se crean tablas en esta fase.

## 6. Reglas de diseño

- La UI no debe conocer SQL, JSON, URLs ni detalles del proveedor.
- El mapeo de datos vive en la capa de repositorio.
- El backend no debe filtrar datos de negocio que la app pueda calcular sin
  costo, salvo que exista una razón de rendimiento.
- Los secretos no se guardan en el repositorio.
- Los datos financieros reales no se almacenan en la app.
- Cualquier cambio de proveedor debe conservar el contrato
  `ProductRepository`.

## 7. Criterios para iniciar la fase

Antes de implementar un backend:

```text
[ ] El MVP local está cerrado y probado
[ ] La pantalla de resultados tiene cuatro estados
[ ] El repositorio local está desacoplado de la UI
[ ] Existe una decisión de equipo sobre el proveedor
[ ] Existe presupuesto y tiempo para mantener el servicio
[ ] Se definió el modelo de datos y las relaciones
[ ] Se definió la estrategia de autenticación
[ ] Se definió el manejo de secretos
[ ] Se definió el plan de pruebas y migración
```

## 8. Fuera de alcance de este documento

- Crear tablas.
- Configurar Supabase o Firebase.
- Agregar dependencias.
- Implementar `RemoteProductRepository`.
- Implementar autenticación.
- Implementar pagos.
- Modificar `GiftProduct`.
- Modificar el MVP local.
