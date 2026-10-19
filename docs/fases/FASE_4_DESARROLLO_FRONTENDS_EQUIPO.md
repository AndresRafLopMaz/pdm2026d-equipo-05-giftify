# Giftify — Fase 4: Desarrollo de frontends por equipo

## 1. Propósito y estado

Este documento registra la fase **ya completada** de desarrollo del frontend de
Giftify por parte de los cuatro integrantes, usando ramas personales y
Pull Requests hacia `main`.

Estado: **COMPLETADA**.

La fase incluye las siete pantallas del MVP, la integración de los PR #15, #16,
#17 y #18, las bitácoras individuales y una suite de 59 pruebas.

## 2. Contexto

Giftify es una aplicación Flutter para elegir regalos bajo restricciones de
ocasión, destinatario, presupuesto, fecha, disponibilidad, vendedor y tiempo de
entrega.

Flujo de pantallas:

```text
Registro → Home → Personalización → Resultados → Detalle → Carrito → Checkout
```

Durante esta fase no se implementó backend remoto, autenticación real, pagos
reales, persistencia ni un gestor global de estado.

## 3. Estrategia de ramas

Se trabajó con cuatro ramas personales:

```text
diego
brayan
andres
catherine
```

Reglas aplicadas:

- cada integrante trabajó en su rama personal;
- no se reescribió la historia de ramas compartidas;
- no se usó `force push`;
- los cambios se integraron mediante Pull Request;
- `main` fue el punto de integración.

Puntas de rama al cerrar el trabajo:

| Rama | Última referencia |
|---|---|
| `diego` | `12e771a` |
| `brayan` | `b2bd5e1` |
| `andres` | `6a8e20b` |
| `catherine` | `cbf58c6` |

## 4. Distribución de pantallas y módulos

| Integrante | Pantallas | Módulo | Rama |
|---|---|---|---|
| Diego | 1 — Registro | `features/auth/` | `diego` |
| Brayan | 2 — Home y 3 — Personalización | `features/home/`, `features/search/` | `brayan` |
| Andrés | 4 — Resultados y 5 — Detalle | `features/products/` | `andres` |
| Catherine | 6 — Carrito y 7 — Checkout | `features/cart/` | `catherine` |

## 5. Desarrollo paralelo

El trabajo se dividió por módulos para reducir conflictos:

- Diego trabajó el registro y el cambio de ruta inicial.
- Brayan trabajó la navegación Home → Search y la construcción de
  `GiftSearchCriteria`.
- Andrés trabajó el filtrado, los resultados, el detalle y la creación de
  `CartItem`.
- Catherine trabajó el carrito, las cantidades, los totales y el checkout
  simulado.

La integración dependía de contratos compartidos, no de implementaciones
internas de cada pantalla.

## 6. Uso de guías IA y bitácoras

El trabajo se apoyó en guías y prompts de IA por integrante. Cada persona
registró su trabajo en su bitácora individual:

```text
docs/bitacoras/DIEGO.md
docs/bitacoras/BRAYAN.md
docs/bitacoras/ANDRES.md
docs/bitacoras/CATHERINE.md
```

El registro transversal `docs/bitacora-ia.md` se incorporó posteriormente, en la
fase de CI, no durante esta fase de frontend.

Las bitácoras documentan objetivos, archivos modificados, decisiones, pruebas,
limitaciones y pendientes. No sustituyen la revisión humana del código.

## 7. Contratos entre pantallas

El router central `AppRoutes` y los modelos de `shared/` definieron los
contratos:

| Paso | Argumento |
|---|---|
| Search → Results | `GiftSearchCriteria` |
| Results → Detail | `GiftProduct` |
| Detail → Cart | `[CartItem]` |
| Cart → Checkout | `List<CartItem>` |

Modelos compartidos:

- `GiftSearchCriteria`
- `GiftProduct`
- `CartItem`
- `DeliveryAddress`
- `UserProfile`

Enums:

- `GiftAvailability`
- `PaymentMethodType`

## 8. Implementación por módulo

### Diego — Registro

- `RegisterScreen` con nombre, correo, contraseña y fecha de nacimiento.
- Validaciones locales.
- Registro simulado con `Future.delayed`.
- Construcción de `UserProfile` sin almacenar la contraseña.
- Navegación a Home después del registro.
- `initialRoute` cambiada a Registro.

### Brayan — Home y Search

- Home conserva la interfaz visual existente.
- El CTA “Encontrar tu regalo” navega a `AppRoutes.search`.
- Search valida ocasión, destinatario y presupuesto.
- Campos opcionales: fecha, tipo de regalo y tamaño.
- Construye `GiftSearchCriteria` y navega a `AppRoutes.productResults`.

### Andrés — Resultados y Detalle

- Resultados recibe criterios y filtra `mockProducts`.
- Filtrado y priorización en `product_filters.dart`.
- Estado vacío cuando nada cumple el presupuesto.
- Detalle recibe `GiftProduct`, muestra disponibilidad y permite agregar.
- Al agregar crea `CartItem` y navega al carrito.

### Catherine — Carrito y Checkout

- Carrito recibe `List<CartItem>`.
- Incremento, decremento y eliminación de productos.
- Subtotal por producto y total general.
- Estado de carrito vacío.
- Checkout recibe la lista y valida dirección.
- Métodos de pago simulados: tarjeta y pago contra entrega.
- Confirmación simulada sin cobro real.

## 9. Pruebas implementadas

Total al cerrar la fase: **59 pruebas aprobadas**.

| Archivo | Pruebas |
|---|---:|
| `app_smoke_test.dart` | 1 |
| `navigation_contract_test.dart` | 2 |
| `shared_models_test.dart` | 3 |
| `register_screen_test.dart` | 8 |
| `cart_screen_test.dart` | 9 |
| `checkout_screen_test.dart` | 11 |
| `product_detail_screen_test.dart` | 12 |
| `product_filters_test.dart` | 8 |
| `product_results_screen_test.dart` | 5 |
| **Total** | **59** |

Comandos ejecutados en la fase:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Resultados: formato limpio, análisis sin errores y suite en verde.

No existían pruebas específicas de Home ni de Search al cerrar esta fase.

## 10. Integración en `main`

Los PR se integraron en este orden:

| PR | Rama | Merge en `main` |
|---|---|---|
| #15 | `diego` | `95c295a` |
| #16 | `brayan` | `e5ad235` |
| #17 | `andres` | `43b7830` |
| #18 | `catherine` | `7e3b900` |

Después de los merges se eliminó el directorio `context/` (`4cec567`) y se
actualizó la bitácora de Brayan (`aeb2973`). Ese fue el estado de `main` al
cerrar la fase de frontend.

## 11. Resultado técnico

```text
Siete pantallas funcionales
Navegación completa Registro → Checkout
Contratos compartidos respetados
59 pruebas aprobadas
Formato limpio
Análisis sin errores
Sin backend real
Sin persistencia
Sin pagos reales
```

## 12. Decisiones

- Datos locales mediante `mockProducts`.
- Estado local con `StatefulWidget` y `setState`.
- Sin gestor global de estado.
- Carrito transmitido por argumentos de navegación.
- Registro simulado.
- Pago simulado, sin datos financieros reales.
- Router central único.
- Modelos compartidos en `shared/`.

## 13. Limitaciones

- No existe backend ni autenticación real.
- No existe persistencia local o remota.
- No existen pagos reales.
- El carrito se pierde al salir de la pantalla.
- No hay pruebas específicas de Home/Search.
- Resultados no tiene estados de carga ni error; la consulta es síncrona.
- Todos los productos mock tienen `imageAsset == null`.
- `recipient` no filtra porque `GiftProduct` no contiene esa información.

## 14. Evidencias

- Ramas personales y sus commits.
- PR #15, #16, #17 y #18.
- Bitácoras individuales.
- Suite de 59 pruebas.
- `main` con las siete pantallas integradas.

## 15. Pendientes al cerrar la fase

- CI y protección de `main`.
- Estados asíncronos y repositorio de productos.
- Pruebas de Home y Search.
- Documentación de equipo.
- Preparación de backend futuro.
- QA global del flujo completo.
