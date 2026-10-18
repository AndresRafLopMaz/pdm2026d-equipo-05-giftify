# Contexto del MVP local — Giftify

ESTADO: TRABAJO ACTUAL — MVP LOCAL

## 1. Objetivo de la entrega actual

Cerrar Giftify como un MVP **completamente local**, estable, probado y
integrable: siete pantallas, navegación completa, datos locales y suite de
pruebas en verde.

No se implementa backend remoto en esta entrega.

## 2. Arquitectura local

```text
Registro → Home → Personalización → Resultados → Detalle → Carrito → Checkout
```

Datos:

```text
ProductResultsScreen
        ↓
ProductRepository
        ↓
MockProductRepository
        ↓
mockProducts
```

- `giftify/lib/app/`: `MaterialApp`, router y ruta inicial.
- `giftify/lib/core/`: tema y configuración de backend (sin HTTP real).
- `giftify/lib/shared/`: modelos, enums y catálogo mock.
- `giftify/lib/features/`: módulos por pantalla.
- `giftify/test/`: pruebas unitarias y de widget.

La rama `feat/21-estados-resultados` incorpora `ProductRepository` y
`MockProductRepository`; se integrarán al cerrar el Issue #21. Hasta entonces,
la pantalla de resultados sigue usando `mockProducts` directamente.

## 3. Sin backend remoto

Todavía no existe:

- Supabase;
- Firebase;
- API REST;
- SQLite;
- autenticación remota;
- persistencia remota;
- pagos reales;
- Riverpod.

`BackendClient` y `BackendConfig` son solo configuración reservada. No realizan
peticiones HTTP.

## 4. Flujo de trabajo Git

Cada integrante:

```powershell
git fetch --all --prune
git switch <rama-personal>
git pull --ff-only origin <rama-personal>
git merge origin/main
git switch -c <rama-de-tarea>
```

Al terminar:

```powershell
git add <archivos>
git diff --cached --name-status
git diff --cached --check
git commit -m "<mensaje semántico>"
git push -u origin <rama-de-tarea>
```

Abrir PR hacia `main`. No hacer merge sin revisión.

## 5. Nunca trabajar directamente en `main`

`main` es la rama de integración. Todo cambio pasa por rama y PR. No se usa
`force push` ni se reescribe historia compartida.

## 6. Propiedad de los módulos

| Integrante | Módulo principal | Pantallas |
|---|---|---|
| Diego | `features/auth/` | Registro |
| Brayan | `features/home/`, `features/search/` | Home y Search |
| Andrés | `features/products/` | Results y Detail |
| Catherine | `features/cart/` | Cart y Checkout |

Cada persona trabaja principalmente en su módulo. `app/`, `core/` y `shared/`
son áreas compartidas y requieren coordinación.

## 7. Contratos compartidos

No duplicar ni cambiar sin coordinación:

```text
GiftSearchCriteria
GiftProduct
CartItem
DeliveryAddress
UserProfile
GiftAvailability
PaymentMethodType
AppRoutes
```

## 8. Cuándo se requiere coordinación

- Cambios en `app/`, `core/` o `shared/`.
- Cambios en un modelo compartido.
- Cambios en el router o en los argumentos de navegación.
- Cambios en un módulo de otro integrante.
- Agregar una dependencia.
- Cambiar el contrato de un repositorio.
- Introducir un estado global o persistencia.

## 9. PLAN antes de BUILD

Antes de implementar:

1. leer la guía de la tarea y la bitácora propia;
2. leer las guías de los módulos dependientes;
3. identificar archivos permitidos y restringidos;
4. revisar el código y los tests reales;
5. proponer alcance y pruebas;
6. pedir aprobación si hay cambios compartidos;
7. solo entonces implementar.

## 10. Bitácoras

Cada integrante actualiza su bitácora:

```text
docs/bitacoras/DIEGO.md
docs/bitacoras/BRAYAN.md
docs/bitacoras/ANDRES.md
docs/bitacoras/CATHERINE.md
```

Registrar: objetivo, archivos, decisiones, pruebas, limitaciones y pendientes.
El uso de IA se registra en `docs/bitacora-ia.md`.

## 11. Comandos obligatorios

Desde `giftify/`:

```powershell
dart format lib test
flutter analyze
flutter test
```

Desde la raíz:

```powershell
git diff --check
```

## 12. Reglas de calidad y alcance

- No eliminar tests para hacer pasar el CI.
- No usar `continue-on-error` en analyze o test.
- No introducir secretos ni datos financieros reales.
- No agregar dependencias sin justificación y coordinación.
- No implementar funcionalidades fuera del alcance del MVP local.
- No modificar módulos ajenos sin justificarlo.
- No cerrar un Issue antes de integrar su PR.

## 13. PR y CI

- Todo trabajo termina en un PR hacia `main`.
- El check `Formato, análisis y pruebas` debe quedar verde.
- Otro integrante revisa antes de integrar cuando corresponda.
- El PR debe describir qué cambió, cómo se probó y qué queda pendiente.

## 14. Issue y documentación

```text
Issue = trazabilidad
.md   = instrucciones operativas detalladas
```

El Issue no reemplaza la guía de trabajo. Las instrucciones concretas viven en
`docs/equipo/mvp/`.

La planificación futura de backend vive en `docs/equipo/backend/` y en
`docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`. No se implementa en esta entrega.
