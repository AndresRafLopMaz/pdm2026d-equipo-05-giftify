# FASE 10B — Design System V2 y Home

**Fecha:** 2026-11-05
**Rama:** `feat/redesign-kiss-final`
**Estado:** implementación visual completada; QA manual pendiente.

## Objetivo

Evolucionar la interfaz KISS de FASE 9 hacia una experiencia más cálida,
reconocible y orientada a regalos, sin volver al ruido visual anterior.

Se conservan los contratos de FASE 10A:

- raíz `/`;
- Register → MainShell;
- cuatro tabs;
- Back corregido;
- Product → Detail;
- Add to Cart permanece en Detail;
- SnackBar “Ver carrito”;
- Cart mediante tab de MainShell.

## Paleta definitiva

```text
Background        #F8F9FC
Surface           #FFFFFF
Surface muted     #F2F3F8
Border            #E4E6EC

Primary           #5867B8
Primary soft      #EEF0FF
On primary        #FFFFFF

Secondary         #9B8BD4
Secondary strong  #6B5AA6
Secondary soft    #F3EFFF

Blush             #E9B8D0
Blush strong      #9B4F73
Blush soft        #FFF1F7

Warm              #F3D6A4
Warm strong       #8A5A00
Warm soft         #FFF7EA

Success           #2E7D5B
Success strong    #1F6B43
Success soft      #E7F5ED

Error             #B3261E
Error soft        #FDECEA

Text              #262936
Muted             #697080
```

Reglas:

- azul para CTA, foco y navegación activa;
- lavanda para apoyo visual y categorías;
- rosa para afecto/regalos;
- crema para inspiración;
- verde solo para disponibilidad, éxito y confirmación;
- rojo para error, eliminación y agotado;
- pasteles solo como fondos, nunca como texto sobre blanco.

Contraste validado:

```text
Primary sobre blanco           5.19:1
Muted sobre Background         4.72:1
SuccessStrong sobre SuccessSoft 5.76:1
Primary sobre PrimarySoft      4.58:1
```

## Home V2

Home pasa de lista de acciones a dashboard de descubrimiento:

1. marca compacta;
2. saludo neutro sin nombre falso;
3. hero de búsqueda con fondo PrimarySoft;
4. categorías editoriales;
5. accesos rápidos funcionales;
6. banner editorial cálido.

El hero tiene el único CTA lleno. Los accesos rápidos son Catálogo, Mi carrito
y Direcciones. No se agregaron Profile, Settings ni Payment Methods.

## Categorías editoriales

Categorías visibles:

```text
Cumpleaños
Pareja
Familia
Amigos
Tecnología
Experiencias
```

En 10B son contenido puramente presentacional:

- no usan InkWell, GestureDetector, FilterChip ni onTap;
- no navegan;
- no filtran;
- no simulan botones.

FASE 10C las convertirá en filtros reales cuando exista Search V2 y datos
suficientes.

## Accesibilidad y responsive

- texto normal ≥ 4.5:1;
- icono + texto en estados;
- color no como único indicador;
- touch targets ≥ 48;
- validación en 320x640, 390x844, 412x915 y tablet;
- text scale 1.3 y 2.0 validado en Home;
- categorías no anunciadas como botones;
- accesos rápidos con semántica de botón.

## Participación

- Andrés: Theme, tokens, MainShell, integración y consistencia.
- Catherine: Home, jerarquía, accesos rápidos y descubribilidad.
- Diego: responsive, componentes, accesibilidad y pruebas visuales.
- Brayan11Hernandez: revisión de iconografía, propuesta de categorías visuales,
  revisión conceptual de Home, descubribilidad, contenido visual y QA
  conceptual. Relevancia baja/media. No se usó como author ni co-author porque
  no hay correo Git verificado.

## Fuera de alcance

- Search V2 funcional;
- nuevos filtros;
- nuevos campos de GiftProduct;
- nuevos mockProducts;
- Auth, Login o sesión;
- Profile, Settings o Dark Mode;
- Payment Methods;
- Checkout V2;
- badge funcional del carrito;
- migraciones o nuevas tablas.
