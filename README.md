# Giftify

**Curso:** Programación de Dispositivos Móviles  
**Universidad:** Universidad Mesoamericana  
**Semestre:** 8.º semestre  
**Sección:** D  
**Equipo:** 05  

## Descripción

Giftify es una aplicación móvil orientada a facilitar la elección de regalos personalizados. El proyecto busca apoyar al usuario durante el proceso de definir sus necesidades, consultar alternativas, comparar opciones y revisar información relevante antes de seleccionar un regalo.

El MVP se enfoca específicamente en reducir la dificultad de tomar una decisión confiable cuando existen restricciones de presupuesto, destinatario y fecha límite.

## Usuario primario

El usuario primario está representado por una persona como Carolina, de 49 años, quien compra y coordina regalos para familiares, compañeros, seres queridos y voluntarios.

Durante este proceso necesita considerar características del destinatario, presupuesto, disponibilidad de productos y tiempo disponible para realizar la compra.

## Problema observable

Al elegir un regalo con una fecha límite, el usuario puede encontrar opciones cuya disponibilidad está desactualizada, diferencias entre lo mostrado y el producto real, información dispersa y respuestas tardías de los vendedores.

Esto provoca pérdida de tiempo, dificulta la comparación y aumenta el riesgo de elegir una opción que no esté disponible o no sea adecuada para el destinatario.

## Propuesta de valor

Ayudamos a personas que coordinan la elección de un regalo a tomar una decisión confiable mediante una búsqueda personalizada y la comparación de opciones verificables.

## Flujo principal del MVP

El flujo principal será:

1. Ingresar los criterios del regalo.
2. Consultar opciones personalizadas.
3. Comparar alternativas.
4. Consultar el detalle de una opción.
5. Revisar precio, disponibilidad y tiempo de entrega.
6. Seleccionar una opción adecuada.

Flujo resumido:

`Ingresar criterios → Buscar opciones → Comparar → Verificar información → Seleccionar regalo`

## Alcance del MVP

### Sí entra

1. Definir criterios esenciales del regalo, como ocasión, destinatario, presupuesto y fecha.
2. Mostrar y comparar opciones personalizadas.
3. Consultar información de una opción antes de seleccionarla.

### No entra todavía

1. Registro avanzado de usuarios y administración de perfiles.
2. Carrito de compras, pagos y checkout.
3. Seguimiento de pedidos, logística y entrega final del regalo.

## Suposición más riesgosa

La principal suposición del proyecto es que Giftify podrá presentar información de precio, disponibilidad y tiempo de entrega suficientemente actualizada y confiable para apoyar la decisión del usuario.

## Milestone actual

### M1 - Arquitectura y datos

**Fecha objetivo:** 27 de agosto de 2026.

El objetivo de M1 es contar con:

- flujo del MVP definido;
- estructura base del proyecto Flutter;
- navegación inicial;
- modelos de datos principales;
- decisión sobre manejo de estado y datos.

## Roles del equipo

| Rol | Responsabilidad | Integrante / GitHub |
| --- | --- | --- |
| Producto / PM | Alcance, prioridades y criterios | Andrés López / @AndresRafLopMaz |
| Arquitectura | Repositorio, estructura, ramas e integración | Diego Barrios / @DiegoBarriosCifuentes |
| UX / Investigación | Usuario, flujo y validación | Catherine Coti / @Catherine707 |
| QA / Release | Revisión, evidencia y cierre | Carmen Crisostomo / @Ortizcarmen |
| 5.º integrante | [Responsabilidad, si aplica] | Brayan Hernández / @Brayan11Hernandez |

Los roles pueden rotar durante el proyecto y todos los integrantes participan en el desarrollo.

## Forma de trabajo

No se realizarán cambios directamente sobre `main`.

Todo cambio seguirá el flujo:

`Issue → Rama → Desarrollo → Commit → Pull Request → Revisión → Merge`

### Reglas

1. Cada trabajo debe iniciar con un Issue.
2. Cada Issue debe tener un responsable.
3. Se crea una rama asociada al Issue.
4. Los cambios se realizan únicamente en esa rama.
5. Se crea un Pull Request hacia `main`.
6. Otro integrante revisa el Pull Request.
7. El cambio se integra únicamente después de la revisión.
8. Al realizar el merge se verifica el cierre del Issue correspondiente.

## Convención inicial de ramas

Ejemplo:

`issue-3-crear-navegacion`

La rama deberá relacionarse claramente con el Issue que implementa.

## Uso responsable de IA

La inteligencia artificial puede utilizarse como apoyo para comprender conceptos, redactar documentación o dividir tareas.

Las decisiones, validaciones, evidencia y revisión final corresponden al equipo.

Cuando se utilice IA en una tarea relevante, se documentará qué apoyo proporcionó y qué decidió aceptar, modificar o rechazar el equipo.

## Issue #2 - Estructura base del proyecto Flutter

Como parte del milestone **M1 - Arquitectura y datos**, se ha definido la estructura base que posteriormente utilizará el proyecto Flutter de Giftify.

La estructura mínima contemplada es la siguiente:

```text
pdm2026d-equipo-05-giftify/
├── lib/
├── test/
└── pubspec.yaml
```

### Elementos principales

* `lib/`: contendrá el código fuente principal de la aplicación.
* `test/`: contendrá las pruebas que se incorporen durante el desarrollo.
* `pubspec.yaml`: permitirá definir la configuración general, dependencias y recursos del proyecto Flutter.

Esta estructura servirá como base para integrar posteriormente las pantallas, modelos, navegación y lógica correspondientes al MVP de Giftify.
