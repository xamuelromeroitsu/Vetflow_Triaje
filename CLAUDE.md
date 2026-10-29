# VetFlow Triaje – instrucciones para Claude Code

App móvil (Flutter + Supabase) que sugiere un nivel de triaje veterinario: Emergencia / Urgencia / Consulta. El código vive en `vetflow_triaje/`; el backend usa Supabase Auth, PostgreSQL con RLS y Storage.

## Antes de trabajar
1. Lee `docs/README.md` (mapa de documentación) y el documento que afecte a tu tarea.
2. Las tareas están en `docs/07-gestion/backlog-tareas.md`; una historia = una rama.
3. Usa el agente o la skill que corresponda (ver `docs/07-gestion/agentes-y-skills.md`).

## Reglas que nunca se rompen
- **El triaje nunca baja de nivel** por datos incompletos, "no sé" o signos vitales faltantes. Ante la duda, subir.
- **El veterinario confirma.** Se guardan `suggested` y `confirmed` por separado, más `reasons` y `rulesVersion`.
- **Reglas clínicas = borrador** hasta que un veterinario las valide (`docs/03-triaje-clinico/validacion-veterinaria.md`). No inventar rangos ni síntomas.
- **Nunca solo color:** el nivel se comunica con color + icono + texto.
- **Validar en el móvil y en las políticas RLS de Supabase**, nunca solo en uno.
- **Datos mínimos:** no pedir ni guardar datos que el triaje no necesite.
- **Dueño y mascota fuera de la clínica** (`owners`, `pets`, `visits` con `companyId` opcional). Ver ADR-0002.
- La app **no diagnostica**; mantener el aviso en los textos al usuario.
- Sin afirmaciones sin respaldo en textos de la app (ej. "99 % de precisión", "diagnóstico").

## Stack y estructura
Flutter · Supabase Auth · PostgreSQL con RLS · Supabase Storage. Código en `vetflow_triaje/lib/` con `app/`, `shared/` y `features/` (un slice vertical por dominio, incluida su presentación). El motor de triaje (`features/triage/`) no depende de la UI. Estructura completa: `docs/05-arquitectura/arquitectura-carpetas.md`.

## Herramientas
- **Notion (MCP remoto)**: `opencode.json` declara el servidor `notion` → `https://mcp.notion.com/mcp`. Permite leer, crear y actualizar páginas de Notion (documentación de producto compartida con el equipo).
  - Cada persona del equipo autentica su propia sesión, una vez: `opencode mcp auth notion` (OAuth en el navegador). El token queda en `~/.local/share/opencode/mcp-auth.json`, **nunca en el repo**.
  - `opencode mcp list` comprueba el estado de la conexión.
  - Herramientas: prefijadas con `notion-` (p. ej. `notion-search`, `notion-fetch`, `notion-create-pages`, `notion-update-page`).
- **Skills**: `.opencode/skills/` (Firebase CLI, Auth, Firestore, reglas de seguridad, arquitectura). Ver `.opencode/skills/README.md`.
- **VS Code**: `vetflow_triaje/.vscode/` con `launch.json` (debug/profile/release) y `tasks.json` (analyze, test, build).

## Convenciones
- Commits: `tipo(alcance): descripción` (`feat`, `fix`, `docs`, `test`, `refactor`, `chore`).
- Si cambia una decisión, actualizar el documento afectado en el mismo commit.
- Decisiones técnicas importantes → ADR (`docs/plantillas/adr.md`).
- "Hecho" = `docs/06-calidad/definicion-de-hecho.md`.

## Pendientes críticos (no asumir)
País objetivo · veterinario asesor · nombre final · especies del MVP. Ver `docs/07-gestion/preguntas-pendientes.md`.
