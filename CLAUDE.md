# VetFlow Triaje – instrucciones para Claude Code

App móvil (Flutter + Firebase) que sugiere un nivel de triaje veterinario: Emergencia / Urgencia / Consulta. Estado: Fase 0 (documentación), el código empieza en el Paso 0.

## Antes de trabajar
1. Lee `docs/README.md` (mapa de documentación) y el documento que afecte a tu tarea.
2. Las tareas están en `docs/07-gestion/backlog-tareas.md`; una historia = una rama.
3. Usa el agente o la skill que corresponda (ver `docs/07-gestion/agentes-y-skills.md`).

## Reglas que nunca se rompen
- **El triaje nunca baja de nivel** por datos incompletos, "no sé" o signos vitales faltantes. Ante la duda, subir.
- **El veterinario confirma.** Se guardan `suggested` y `confirmed` por separado, más `reasons` y `rulesVersion`.
- **Reglas clínicas = borrador** hasta que un veterinario las valide (`docs/03-triaje-clinico/validacion-veterinaria.md`). No inventar rangos ni síntomas.
- **Nunca solo color:** el nivel se comunica con color + icono + texto.
- **Validar en el móvil y en las reglas de Firestore**, nunca solo en uno.
- **Datos mínimos:** no pedir ni guardar datos que el triaje no necesite.
- **Dueño y mascota fuera de la clínica** (`owners`, `pets`, `visits` con `companyId` opcional). Ver ADR-0002.
- La app **no diagnostica**; mantener el aviso en los textos al usuario.
- Sin afirmaciones sin respaldo en textos de la app (ej. "99 % de precisión", "diagnóstico").

## Stack y estructura
Flutter · Firebase Auth · Firestore (persistencia offline) · Storage. Código en `app/lib/` con `core/` y `features/`. El motor de triaje (`features/triage/`) no depende de la UI.

## Convenciones
- Commits: `tipo(alcance): descripción` (`feat`, `fix`, `docs`, `test`, `refactor`, `chore`).
- Si cambia una decisión, actualizar el documento afectado en el mismo commit.
- Decisiones técnicas importantes → ADR (`docs/plantillas/adr.md`).
- "Hecho" = `docs/06-calidad/definicion-de-hecho.md`.

## Pendientes críticos (no asumir)
País objetivo · veterinario asesor · nombre final · especies del MVP. Ver `docs/07-gestion/preguntas-pendientes.md`.
