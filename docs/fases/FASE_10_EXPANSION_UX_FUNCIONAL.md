# FASE 10 — Expansión UX y funcional de Giftify

**Fecha:** 2026-11-05
**Rama base:** `feat/redesign-kiss-final`
**Estado:** planificación aprobada; sin implementación funcional.

## 1. Contexto

La FASE 9 estabilizó el rediseño KISS de Giftify:

- sistema visual centralizado;
- navegación principal con Inicio, Buscar, Catálogo y Carrito;
- Search;
- Results;
- Detail;
- Cart;
- Checkout;
- Register;
- Addresses;
- responsive;
- persistencia existente de carrito, productos eliminados y direcciones.

La revisión manual posterior identificó nuevas necesidades de producto, UX y
funcionalidad que amplían el alcance más allá de un simple pulido visual.

Esta fase **no reemplaza FASE 9**:

```text
FASE 9  → rediseño y estabilización visual.
FASE 10 → expansión funcional y UX V2.
```

FASE 10 es exclusivamente documental. No implementa los bugs ni las features
descritas aquí.

## 2. Observaciones que originan la fase

1. Back puede terminar en `Ruta no encontrada`.
2. El tap de producto puede no abrir Detail.
3. Agregar un producto navega automáticamente a Cart y resulta molesto.
4. El diseño quedó demasiado minimalista y necesita identidad visual.
5. Las funciones deben ser más fáciles de descubrir.
6. Search necesita mayor desarrollo visual y funcional.
7. Se necesitan más datos y persistencia.
8. Se necesita sesión persistente, Logout y Dark Mode.
9. Se deben mejorar iconografía, imágenes y recursos visuales.
10. Se necesitan más filtros, especificaciones y criterios de búsqueda.

## 3. Backlog priorizado

### P0 — Bugs críticos

#### P0.1 Back / Ruta no encontrada

**Objetivo:** nunca mostrar `_UnknownRouteScreen` durante navegación normal.

Antes de modificar:

- reproducir el fallo;
- identificar la ruta recibida;
- inspeccionar el stack de navegación;
- crear un test de regresión.

Revisar:

```text
AppRouter
Navigator.pushNamed
Navigator.pushReplacementNamed
Navigator.pop
MainShell
```

No corregir con hacks como redirigir toda ruta desconocida a Home. Primero debe
encontrarse la ruta inválida y su origen.

#### P0.2 Product → Detail

**Objetivo:**

```text
Results → tap producto → ProductDetail correcto
```

Verificar:

```text
ProductCard.onTap
Navigator
arguments
GiftProduct
AppRouter
```

Los tests existentes de navegación pasan. Por lo tanto, el fallo debe
reproducirse primero en un entorno real antes de modificar código.

#### P0.3 Add to Cart sin navegación automática

Flujo actual:

```text
Detail → Agregar al carrito → navega a Cart
```

Flujo objetivo:

```text
Detail → Agregar al carrito → permanece en Detail
→ SnackBar: "Producto agregado al carrito."
→ Acción opcional: "Ver carrito"
```

Preservar:

- `cartItemsProvider`;
- persistencia;
- cantidades;
- total;
- contrato de Checkout.

La acción `Ver carrito` será opcional y no obligatoria.

### P1 — UX / Design System V2

Mantener los principios de estructura KISS, pero permitir mayor identidad visual.

Dirección propuesta:

- blanco;
- azul suave;
- lavanda;
- rosa pastel;
- crema;
- superficies suaves;
- decoración moderada;
- iconografía coherente;
- imágenes útiles.

Evitar volver a:

- exceso de cards;
- gradientes agresivos;
- sombras pesadas;
- múltiples CTAs principales;
- ruido visual.

Objetivos:

- tranquilidad;
- confianza;
- facilidad de orientación;
- personalidad de marca;
- descubribilidad.

La paleta concreta queda pendiente de validación visual. No se implementan
colores en esta fase documental.

### P2 — Search y recomendación

Search V2 debe considerar:

- relación/destinatario;
- rango de edad;
- ocasión;
- presupuesto;
- intereses;
- tipo de regalo;
- fecha;
- tamaño;
- disponibilidad;
- entrega rápida;
- producto local;
- personalizable;
- preferencias adicionales.

Intereses sugeridos:

```text
Tecnología
Música
Gaming
Cocina
Deportes
Moda
Libros
Arte
```

Evaluar la expansión de `GiftProduct` con campos opcionales:

```text
occasions
recommendedAges
recipientTypes
interests
tags
isPersonalizable
isLocal
stock
```

Los campos nuevos deben ser opcionales para no romper productos existentes,
carrito, filtros ni tests.

### Catálogo

Estado actual: aproximadamente **6 productos mock**.

Objetivo: **30–50 productos mock coherentes**.

Categorías sugeridas:

```text
Tecnología
Joyería
Alimentos
Accesorios
Hogar
Libros
Gaming
Belleza
Artesanías
Personalizados
Experiencias
```

Requisitos:

- IDs estables;
- precios realistas;
- disponibilidad variada;
- sellers;
- rating;
- imágenes o placeholders;
- categorías consistentes;
- compatibilidad con Cart;
- compatibilidad con productos eliminados.

### P3 — Usuarios y autenticación local

Crear posteriormente:

```text
UserRepository
Auth/session provider
Login
Register persistente
Logout
session restore
```

Flujo:

```text
App start → revisar sesión
  sesión válida → MainShell
  sin sesión    → Login/Register
```

No guardar contraseñas en texto plano.

Antes de implementar, definir:

- algoritmo de hashing;
- salt;
- paquete/dependencia permitida;
- modelo `User`;
- tabla SQLite;
- migración;
- pruebas.

No usar credenciales reales.

### P4 — Perfil y Settings

Crear:

```text
ProfileScreen
SettingsScreen
```

Profile debe permitir acceso a:

- datos del usuario;
- Mis direcciones;
- Métodos de pago;
- Apariencia;
- Cerrar sesión.

Settings:

```text
ThemeMode.system
ThemeMode.light
ThemeMode.dark
```

La preferencia debe persistirse.

Dark mode requiere:

- `dark ColorScheme`;
- contraste;
- surfaces;
- inputs;
- badges;
- dialogs;
- NavigationBar;
- pruebas visuales y responsive.

### P5 — Métodos de pago ficticios

Crear una libreta local.

Modelo conceptual:

```text
PaymentMethod
  id
  userId
  holderName
  brand
  last4
  expiryMonth
  expiryYear
  isDefault
```

No almacenar:

```text
CVV
PAN completo
datos financieros reales
```

Los datos serán demostrativos.

Pantallas futuras:

```text
PaymentMethodsScreen
PaymentMethodFormScreen
```

Flujos:

- crear;
- editar;
- establecer principal;
- eliminar.

### Checkout V2

Solo después de estabilizar Auth, AddressBook y PaymentMethods.

Flujo futuro:

```text
Entrega → dirección persistente
Pago    → método persistente
Resumen → Cart actual
Confirmar → pedido simulado
```

No implementar órdenes persistentes sin diseñarlas previamente.

### P6 — Circuito completo

Flujo objetivo:

```text
Login/Register
→ Home
→ Search
→ Results
→ Detail
→ Cart
→ Checkout
```

Flujos secundarios:

```text
Profile → Addresses
Profile → Payment Methods
Profile → Settings
Profile → Logout
```

Reinicio:

```text
App restart → sesión restaurada → MainShell
```

### P7 — QA final

Validar:

- navegación;
- back;
- sesión;
- logout;
- persistencia;
- filtros;
- recomendaciones;
- carrito;
- AddressBook;
- PaymentMethods;
- Checkout;
- dark mode;
- responsive;
- Android;
- migraciones;
- tests;
- CI;
- capturas.

No declarar evidencia sin ejecución real.

## 4. Dependencias

```text
P0
↓
P1
↓
P2
↓
P3
↓
P4
↓
P5
↓
P6
↓
P7
```

Explicación:

- P0 debe resolverse antes de añadir funciones.
- P2 puede ampliar modelos de producto y datos mock.
- P3 requiere migración y decisiones de seguridad.
- P4 depende de usuario y sesión.
- P5 necesita identidad de usuario.
- P6 integra todos los subsistemas.
- P7 ocurre al final.

## 5. Migraciones

Agregar `users` o `payment_methods` a SQLite implica incrementar la versión de
la base de datos.

No usar:

```text
DROP DATABASE
DELETE DATABASE
recrear el esquema destruyendo datos
```

Cada migración debe:

- preservar `delivery_addresses`;
- preservar usuarios previos;
- tener tests de upgrade;
- tener `onCreate` equivalente al esquema final.

## 6. Riesgos

- Regresión de navegación.
- Cambios grandes en `GiftProduct`.
- IDs de `mockProducts`.
- Migraciones SQLite.
- Hashing incorrecto.
- Sesión inconsistente.
- Dark Mode incompleto.
- Filtros demasiado complejos.
- Sobredecoración.
- Performance con imágenes.
- Checkout demasiado acoplado.
- Web no valida SQLite.
- Android pendiente.

## 7. Estrategia de implementación

Fases futuras independientes:

### FASE 10A — P0

Bugs críticos de navegación y carrito.

### FASE 10B — Design System V2 + Home/discoverability

Identidad visual, descubribilidad y Home.

### FASE 10C — Search V2 + catálogo + datos

Criterios, filtros y 30–50 productos mock.

### FASE 10D — Auth + usuarios + sesión

Login/Register persistente, sesión y Logout.

### FASE 10E — Profile + Settings + Dark Mode

Perfil, preferencias, tema y persistencia de apariencia.

### FASE 10F — Payment Methods + Checkout V2

Libreta ficticia y conexión de Checkout.

### FASE 10G — Recursos visuales + QA final

Iconografía, imágenes, capturas y QA integral.

Cada fase debe:

- iniciar con PLAN;
- implementar con BUILD;
- ejecutar tests;
- crear commit lógico;
- push;
- detenerse para revisión.

## 8. Estrategia de Git

Mantener por ahora:

```text
feat/redesign-kiss-final
```

No crear ramas adicionales todavía.

No abrir PR.

No mergear.

FASE 10A se desarrollará en la misma rama salvo nueva decisión explícita.

## 9. Estado de implementación

```text
P0–P7: no implementado.
Código Flutter: sin cambios.
Tests: sin cambios.
Repositories/providers/SQLite: sin cambios.
PR: no abierto.
Merge: no realizado.
```
