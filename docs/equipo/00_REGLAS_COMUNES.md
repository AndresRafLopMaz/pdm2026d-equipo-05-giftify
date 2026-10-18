# Reglas comunes de trabajo — Giftify

Este documento resume cómo trabaja el equipo en la siguiente fase del MVP:
integración, QA, CI, estados asíncronos, repositorios de datos y preparación
para un backend futuro.

## 1. Qué es Giftify

Giftify es una aplicación Flutter para elegir regalos bajo restricciones de
ocasión, destinatario, presupuesto, fecha, disponibilidad, vendedor y tiempo de
entrega.

Flujo principal implementado:

```text
Registro
  -> Home
  -> Personalización de búsqueda
  -> Resultados
  -> Detalle
  -> Carrito
  -> Checkout
```

Estado real del MVP:

- Las siete pantallas están implementadas e integradas en `main`.
- Los datos de productos provienen de `giftify/lib/shared/data/mock_products.dart`.
- No existe backend real, autenticación real, pasarela de pagos ni base de datos.
- No existe un gestor global de estado; el carrito se transmite por argumentos
  de navegación.
- La suite local tiene 59 pruebas aprobadas.
- El CI está definido en el PR `chore/ci` y todavía no forma parte de `main`.

## 2. Arquitectura real

```text
giftify/lib/
├── app/
│   ├── app_router.dart
│   └── giftify_app.dart
├── core/
│   ├── backend/
│   │   ├── backend_client.dart
│   │   └── backend_config.dart
│   └── theme/
│       └── app_theme.dart
├── shared/
│   ├── data/
│   │   └── mock_products.dart
│   ├── enums/
│   │   ├── gift_availability.dart
│   │   └── payment_method_type.dart
│   └── models/
│       ├── cart_item.dart
│       ├── delivery_address.dart
│       ├── gift_product.dart
│       ├── gift_search_criteria.dart
│       └── user_profile.dart
└── features/
    ├── auth/
    ├── home/
    ├── search/
    ├── products/
    └── cart/
```

Responsabilidades:

- `app/`: `MaterialApp`, ruta inicial y contrato central de navegación.
- `core/`: infraestructura transversal. `BackendClient` y `BackendConfig` son
  solo configuración; no realizan HTTP.
- `shared/`: contratos compartidos. Un cambio aquí afecta a varias pantallas.
- `features/`: implementación de cada módulo.

## 3. Contratos compartidos

Modelos:

- `GiftSearchCriteria`: `occasion`, `recipient`, `maxBudget`, `eventDate`,
  `giftType`, `size`.
- `GiftProduct`: identidad, precio, categoría, tamaño, disponibilidad, vendedor,
  calificación, ocasiones sugeridas, entrega e imagen opcional.
- `CartItem`: producto y cantidad; `subtotal` calculado.
- `DeliveryAddress`: datos de entrega para checkout.
- `UserProfile`: perfil local creado en el registro; no almacena contraseña.

Enums:

- `GiftAvailability`: `inStock`, `lowStock`, `outOfStock`, `unknown`.
- `PaymentMethodType`: tarjeta simulada y pago contra entrega.

Reglas:

- No duplicar estos modelos ni crear variantes por pantalla.
- No agregar lógica de interfaz dentro de los modelos.
- Cualquier cambio de contrato debe justificarse y revisarse con los módulos que
  lo consumen.
- No inventar campos que el sistema todavía no produce.

## 4. Propiedad de los módulos

| Área | Responsable principal | Rama personal |
|---|---|---|
| `features/auth/` | Diego | `diego` |
| `features/home/` y `features/search/` | Brayan | `brayan` |
| `features/products/` | Andrés | `andres` |
| `features/cart/` | Catherine | `catherine` |
| `app/`, `core/`, `shared/` | Áreas compartidas | Coordinación previa |

`app/`, `core/` y `shared/` no pertenecen a un solo integrante. Modificarlas
requiere explicar el motivo, revisar el impacto en las demás pantallas y avisar
al equipo antes del cambio.

## 5. Reglas Git

- Cada integrante trabaja en su rama personal o en una rama temporal aprobada.
- No se trabaja directamente en `main` una vez activada su protección.
- No se reescribe historia de ramas compartidas.
- No se usa `git push --force`.
- No se borra trabajo de otros integrantes.
- Los commits deben ser pequeños y con mensaje semántico: `feat:`, `fix:`,
  `test:`, `docs:`, `chore:`.
- Antes de un PR: revisar `git diff`, ejecutar formato, analyze y test.
- Los PR hacia `main` requieren revisión y el check de CI.
- Usar merge, no rebase, para incorporar `main` a una rama personal.

## 6. Flujo obligatorio antes de una tarea

```text
1. Actualizar referencias: git fetch --all --prune
2. Cambiar a la rama propia: git switch <rama>
3. Incorporar main con merge: git merge origin/main
4. Leer la bitácora propia y las bitácoras de los módulos dependientes
5. Ejecutar la línea base: format, analyze y test
6. Trabajar en una rama feature temporal si el laboratorio lo exige
7. Actualizar la bitácora y la bitácora de IA al terminar
```

Si hay conflictos:

- detenerse;
- mostrar los archivos afectados;
- explicar la causa;
- no resolver automáticamente escogiendo una versión.

## 7. Calidad obligatoria

Desde `giftify/`:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Reglas:

- No desactivar `flutter analyze` ni `flutter test`.
- No eliminar pruebas para hacer pasar la suite.
- No usar `continue-on-error` para analyze o test.
- Toda pantalla con datos asíncronos debe probar carga, error, vacío y datos.
- El estado de error debe ofrecer un botón `Reintentar` que ejecute una nueva
  consulta.
- El check de CI debe llamarse `Formato, análisis y pruebas`.

## 8. Alcance y seguridad

Todavía no se implementa:

- login real ni autenticación con servidor;
- pagos reales;
- base de datos local o remota;
- llamadas HTTP reales;
- secretos o credenciales en el repositorio.

Reglas:

- No almacenar contraseñas, datos financieros ni secretos.
- No agregar dependencias sin justificarlas y coordinarlas.
- SQLite sería persistencia local, no backend; no se agrega sin una necesidad
  funcional concreta.
- Riverpod u otro gestor de estado no se instala sin decisión del equipo.

## 9. Uso de IA

La IA debe leer, como mínimo:

- `docs/equipo/00_REGLAS_COMUNES.md`;
- la bitácora del integrante;
- las bitácoras de los módulos con los que existe dependencia;
- `README.md` y la documentación de fases cuando aplique.

Reglas:

- La IA no decide arquitectura por sí sola.
- Todo uso relevante se registra en `docs/bitacora-ia.md`: qué se pidió, qué se
  aceptó, qué se rechazó y qué se corrigió manualmente.
- Cada integrante actualiza su propia bitácora en `docs/bitacoras/`.
- No se copian guías antiguas sin contrastarlas con el código real.

## 10. Definición de terminado

Una tarea está terminada cuando:

```text
[ ] El cambio está acotado a su módulo o fue coordinado
[ ] No duplica modelos ni contratos
[ ] dart format pasa
[ ] flutter analyze pasa
[ ] flutter test pasa
[ ] Se probó el flujo afectado
[ ] La bitácora propia está actualizada
[ ] El uso de IA está documentado
[ ] El PR describe qué cambió, cómo se probó y qué falta
```
