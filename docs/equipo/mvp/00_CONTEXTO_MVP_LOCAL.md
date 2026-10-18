# Contexto del MVP local — Giftify

ESTADO: TRABAJO ACTUAL — MVP LOCAL

## 1. Objetivo de la entrega actual

Cerrar Giftify como un MVP **completamente local**, estable, probado e
integrable: siete pantallas, navegación completa, datos locales y suite de
pruebas en verde.

No se implementa backend remoto en esta entrega. La planificación futura vive en
`docs/equipo/backend/` y en `docs/fases/FASE_6_BACKEND_REMOTO_FUTURO.md`
(cuando esa fase se integre). No forma parte del trabajo actual.

## 2. Arquitectura local

```text
Registro → Home → Personalización → Resultados → Detalle → Carrito → Checkout
```

Datos de productos:

```text
ProductResultsScreen
        ↓
ProductRepository
        ↓
MockProductRepository
        ↓
mockProducts
```

La rama `feat/21-estados-resultados` ya incorpora `ProductRepository`,
`MockProductRepository` y sus pruebas unitarias. Hasta que esa tarea termine,
`ProductResultsScreen` sigue usando `mockProducts` directamente. El objetivo de
Andrés es completar ese desacople.

## 3. Estado real del repositorio

- `main` contiene las siete pantallas, `docs/equipo/mvp/`, CI, CODEOWNERS y
  plantilla de PR.
- `feat/21-estados-resultados` contiene BUILD 5A del repositorio local.
- Las ramas personales están atrasadas respecto a `main`; deben sincronizarse
  antes de trabajar.
- `FASE_4` y `FASE_6` están en `feat/21` y llegarán a `main` con su PR; no son
  código pendiente.
- No existen tests específicos de Home ni Search.
- `ProductResultsScreen` todavía no tiene estados asíncronos.
- Cart y Checkout ya están implementados y con buena cobertura.

## 4. Flujo de trabajo Git

Cada integrante, al comenzar:

```powershell
git fetch --all --prune
git switch <rama-personal>
git pull --ff-only origin <rama-personal>
git merge origin/main
```

Durante el trabajo:

```powershell
dart format lib test
flutter analyze
flutter test
git diff --check
```

Al terminar:

```powershell
git status
git diff --stat
git add <solo archivos propios>
git diff --cached --name-status
git diff --cached --check
git commit -m "<mensaje semántico>"
git push origin <rama-personal>
```

No se exige PR durante el desarrollo. El único PR obligatorio es el de Issue #21
al finalizar los estados asíncronos. La integración a `main` se hará de forma
controlada después.

## 5. Nunca trabajar directamente en `main`

Aunque el ruleset esté temporalmente deshabilitado, la regla humana sigue
vigente: no se trabaja directamente en `main`. Todo cambio de código pasa por
rama personal o rama feature.

La única excepción autorizada es la actualización documental de estas guías.

## 6. Propiedad de los módulos

| Integrante | Módulo principal | Pantallas |
|---|---|---|
| Diego | `features/auth/` | Registro |
| Brayan | `features/home/`, `features/search/` | Home y Search |
| Andrés | `features/products/` | Results y Detail |
| Catherine | `features/cart/` | Cart y Checkout |

Cada persona modifica principalmente su módulo, sus tests y su bitácora.

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
- Introducir estado global o persistencia.

Durante el trabajo paralelo, **evitar modificar concurrentemente**:

```text
giftify/lib/app/app_router.dart
giftify/lib/shared/models/
giftify/lib/shared/data/mock_products.dart
giftify/pubspec.yaml
docs/bitacora-ia.md
```

Si una tarea necesita uno de esos archivos, detenerse y coordinar.

## 9. Trabajo paralelo

Los cuatro pueden comenzar en paralelo. Ninguno depende funcionalmente de otro
para empezar:

- Diego: prueba responsive de Registro.
- Brayan: pruebas de Home y Search.
- Andrés: estados asíncronos de Results.
- Catherine: integración Cart → Checkout.

Orden recomendado de integración posterior:

```text
1. Diego
2. Brayan
3. Catherine
4. Andrés / PR #21
```

Motivo: integrar primero los cambios pequeños y validar el PR del laboratorio
contra el `main` más reciente. Este orden **no bloquea** el desarrollo paralelo.

## 10. PLAN antes de BUILD

Antes de implementar:

1. leer la guía propia y la bitácora propia;
2. leer las guías de módulos dependientes;
3. revisar el código y los tests reales;
4. identificar archivos permitidos y restringidos;
5. proponer alcance y pruebas;
6. coordinar si hay cambios compartidos;
7. solo entonces implementar.

## 11. Bitácoras

Cada integrante actualiza su bitácora:

```text
docs/bitacoras/DIEGO.md
docs/bitacoras/BRAYAN.md
docs/bitacoras/ANDRES.md
docs/bitacoras/CATHERINE.md
```

Registrar: objetivo, archivos, decisiones, pruebas, limitaciones y pendientes.

Durante el trabajo paralelo, **Diego, Brayan y Catherine no deben modificar
`docs/bitacora-ia.md`**. Andrés conservará la entrada relacionada con Issue #21.
La consolidación transversal de IA se hará en la integración final.

## 12. Reglas de calidad y alcance

- No eliminar tests para hacer pasar el CI.
- No usar `continue-on-error`.
- No introducir secretos ni datos financieros reales.
- No agregar dependencias sin justificación y coordinación.
- No implementar funcionalidades fuera del alcance del MVP local.
- No modificar módulos ajenos sin justificarlo.
- No cerrar un Issue antes de integrar su PR.

## 13. Comandos obligatorios

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

## 14. Issue y documentación

```text
Issue = trazabilidad
.md   = instrucciones operativas detalladas
```

El Issue no reemplaza esta guía. Las instrucciones concretas viven en
`docs/equipo/mvp/`.

## 15. Evidencias de cierre

Cada integrante conserva:

- salida de `flutter analyze`;
- cantidad total de tests;
- `All tests passed`;
- `git diff --check` limpio;
- `git status` final;
- SHA del commit;
- rama remota actualizada.

Andrés conserva además capturas de loading, error + `Reintentar`, empty +
`Modificar búsqueda` y data.

## 16. Fuera de alcance

No implementar:

- backend remoto;
- Supabase;
- Firebase;
- API REST;
- SQLite;
- Riverpod;
- autenticación remota;
- persistencia remota;
- pagos reales.
