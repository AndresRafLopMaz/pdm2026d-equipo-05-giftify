<!-- GitHub llena este texto en cada Pull Request nuevo. Borra lo que no aplique. -->

## Qué cambia
<!-- Una o dos frases. El "por qué" importa más que el "qué". -->

Cierra #<!-- número del issue: al hacer merge, GitHub lo cierra solo -->

## Cómo probarlo
1.
2.

## Capturas
<!-- Antes / después si cambia la UI. -->

## Checklist del autor
- [ ] `dart format`, `flutter analyze` sin observaciones y `flutter test` en verde (el CI lo revisa).
- [ ] Probé el flujo en un dispositivo o emulador (no solo en Chrome/escritorio).
- [ ] Cambios acotados al alcance de la tarea; sin funcionalidades nuevas (login, pagos, etc.) fuera del issue.
- [ ] Rutas y navegación consistentes con `lib/app/app_router.dart`.
- [ ] Modelos y enums compartidos en `lib/shared/`; sin lógica de negocio dentro de widgets.
- [ ] No agregué llamadas de red reales (`BackendClient` sigue siendo solo configuración).
- [ ] Si usé IA: entrada en `docs/bitacora-ia.md` (qué pedí, qué acepté, qué rechacé).
- [ ] Si tomé una decisión de arquitectura: queda documentada en `docs/`.

## Para quien revisa
<!-- ¿Dónde quieres que miren con más cuidado? -->
