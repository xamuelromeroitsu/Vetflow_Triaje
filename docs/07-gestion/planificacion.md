# Planificación

> Duraciones estimadas; se ajustan al terminar cada sprint.

## Fase 0 · Documentación (antes del código)
- [ ] Decidir nombre final.
- [ ] Confirmar país objetivo.
- [ ] Conseguir veterinario asesor y revisar el [protocolo](../03-triaje-clinico/protocolo-triaje.md).
- [ ] Resolver las preguntas críticas de [preguntas-pendientes](preguntas-pendientes.md).
- [ ] Wireframes de P-02, P-06 y P-09.
- [ ] Decidir gestor de estado (ADR-0004).

## Fase 1 · MVP
| Sprint | Pasos | Meta |
|---|---|---|
| 0 | Paso 0 | Proyecto Flutter + Firebase funcionando |
| 1 | Pasos 1 y 2 | Registrar mascota y síntomas |
| 2 | Pasos 3, 4 y 5 | Signos vitales, fotos y QA de captura |
| 3 | Pasos 6 y 7 | Triaje y cola simple |

| Paso | Objetivo | Tareas | Resultado visible |
|---|---|---|---|
| 0 | Repo y proyecto base | TAR-01, 02 | App conectada a Firebase |
| 1 | Registrar mascota | TAR-03 a 06 | Formulario que guarda en Firestore |
| 2 | Registrar síntomas | TAR-07, 08 | Pantalla de síntomas |
| 3 | Signos vitales | TAR-09 | Inputs con validación |
| 4 | Fotos | TAR-10 | Subir y ver imágenes |
| 5 | Pruebas de captura | TAR-11, 12 | Checklist de QA completo |
| 6 | Triaje por reglas | TAR-13, 14 | Resultado 🔴🟠🟢 |
| 7 | Cola simple | TAR-15 | Lista por prioridad |

## Hitos
| Hito | Criterio |
|---|---|
| H0 · Documentación lista | Preguntas críticas resueltas y protocolo revisado por veterinario |
| H1 · Captura completa | Registro de punta a punta |
| H2 · MVP funcional | Triaje + cola, probado internamente |
| H3 · Piloto | Uso real con una clínica |

## Fases siguientes
Ver [roadmap](../01-producto/roadmap.md).
