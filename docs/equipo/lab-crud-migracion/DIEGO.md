# Diego — UI, formulario y navegación de direcciones

## Issue futuro

`#31 — [Lab S16] CRUD de direcciones con UNIQUE, en uso y archivado`

Depende de que el PR de migración `#30` esté integrado en `main`.

## Trabajo futuro

- `AddressListScreen`;
- `AddressFormScreen` único para crear y editar;
- tarjeta de dirección;
- enlace desde el perfil de Home;
- ruta `AppRoutes.addresses`;
- estados loading, error, vacío y datos;
- selector Activas / Archivadas;
- diálogo de dirección en uso;
- widget tests.

## Archivos previstos

```text
giftify/lib/features/addresses/screens/address_list_screen.dart
giftify/lib/features/addresses/screens/address_form_screen.dart
giftify/lib/features/addresses/widgets/address_card.dart
giftify/lib/app/app_router.dart
giftify/lib/features/home/screens/home_screen.dart
giftify/test/address_list_screen_test.dart
giftify/test/address_form_screen_test.dart
giftify/test/navigation_contract_test.dart
```

## Reglas

- El formulario no conoce SQL ni `shared_preferences`.
- El formulario recibe `initialAddress` opcional y un `onSubmit`.
- Crear muestra `Crear`; editar muestra `Guardar cambios`.
- Editar conserva el mismo id.
- La lista se refresca con `ref.invalidate(addressesProvider)`.
- No modificar Cart ni Products.
- El archivo de Home pertenece históricamente a Brayan; este cambio se coordina
  y se documenta por su ausencia temporal.
