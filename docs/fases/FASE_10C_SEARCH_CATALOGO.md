# FASE 10C — Search V2, catálogo ampliado y recomendación

**Fecha:** 2026-11-05
**Rama:** `feat/redesign-kiss-final`
**Estado:** implementación funcional completada; QA manual pendiente.

## Objetivo

Evolucionar Search y la recomendación de Giftify sin alterar los contratos de
navegación, carrito, productos eliminados, Checkout ni direcciones.

## Modelo V2

`GiftProduct` conserva:

- `id`, `name`, `description`, `price`;
- `availability`, `sellerName`, `sellerRating`;
- `estimatedDeliveryDays`, `imageAsset`.

Se migró:

```text
category       → GiftCategory
size           → GiftSize
occasions      → Set<GiftOccasion>
```

Se agregaron con defaults compatibles:

```text
recipientTypes     Set<GiftRecipient> = {}
ageRanges          Set<GiftAgeRange> = {}
interests          Set<GiftInterest> = {}
giftFormat         GiftFormat.physical
isPersonalizable   false
isLocal            false
```

No se agregaron tags ni stock numérico.

## Enums

```text
GiftCategory
GiftRecipient
GiftOccasion
GiftInterest
GiftAgeRange
GiftFormat
GiftSize
```

`GiftAvailability` se conserva.

## Catálogo

Total: **36 productos**.

```text
technology      5
jewelry         4
food            4
accessories     4
home            4
books           3
gaming          3
beauty          3
crafts          3
experiences     3
```

Los IDs `gift-001` a `gift-006` se conservan con nombre y precio originales.
Los productos nuevos usan `gift-007` a `gift-036`.

## Search V2

Una sola pantalla progresiva:

1. destinatario;
2. ocasión;
3. presupuesto máximo;
4. intereses multiselect;
5. Más detalles;
6. Buscar regalos;
7. Limpiar.

Más detalles incluye edad, fecha, formato, tamaño, personalizable, local,
entrega rápida y solo disponibles.

## Prefill desde Home

```text
Cumpleaños   → occasion=birthday
Pareja       → recipientType=partner
Familia      → recipientType=family
Amigos       → recipientType=friend
Tecnología   → interests={technology}
Experiencias → giftFormat=experience
```

Home no navega directamente a Results. Escribe un `SearchPrefill` de un solo
uso y selecciona la tab Buscar.

## Recomendación

Hard filters:

```text
price <= maxBudget
onlyAvailable ⇒ product.isAvailable
eventDate ⇒ deliveryDays != null && llegada <= fecha
```

Scoring:

```text
recipientType        +4
occasion             +3
interests            +2 por match, máximo +4
ageRange             +2
giftFormat           +2
size                 +1
isPersonalizable     +1
isLocal              +1
fastDelivery         +1
```

Tie breakers:

```text
score desc
price asc
id asc
```

Sin criterios: `sellerRating desc`, `price asc`, `id asc`.

Complejidad: filtros O(n), scoring O(n · k), sort O(n log n).

## Compatibilidad

- carrito persiste solo `productId` y `quantity`;
- productos eliminados persisten IDs;
- `gift-001..006` se mantienen;
- Add to Cart y “Ver carrito” no cambian;
- MainShell, Back y routing no cambian;
- no se modifican SQLite, migraciones, Checkout ni Addresses.

## Participación

- Andrés: modelo, enums, compatibilidad, algoritmo e integración.
- Catherine: UX de Search, flujo progresivo, prefill desde Home y copy.
- Diego: responsive, accesibilidad, pruebas de Search y recomendación.
- Brayan11Hernandez: curación de catálogo, propuesta de productos, categorías,
  intereses, revisión de nombres/descripciones, precios, filtros conceptuales,
  QA de Search y contenido mock. Relevancia baja/media. No se usó como author
  ni co-author porque no hay correo Git verificado.
