# Documentación de VetFlow

Estado: ✅ completo · 🟡 borrador (necesita revisión) · ⬜ por completar

## 01 · Producto – *¿qué y para quién?*
| Documento | Estado |
|---|---|
| [product-brief.md](01-producto/product-brief.md) | 🟡 |
| [usuarios-y-personas.md](01-producto/usuarios-y-personas.md) | 🟡 hipótesis a validar con entrevistas |
| [mvp-scope.md](01-producto/mvp-scope.md) | 🟡 |
| [roadmap.md](01-producto/roadmap.md) | 🟡 |
| [future-state.md](01-producto/future-state.md) | 🟡 |

## 02 · Requisitos – *¿qué hace el sistema?*
| Documento | Estado |
|---|---|
| [functional-spec.md](02-requisitos/functional-spec.md) | 🟡 |
| [flujos-usuario.md](02-requisitos/flujos-usuario.md) | 🟡 |
| [requisitos-no-funcionales.md](02-requisitos/requisitos-no-funcionales.md) | 🟡 |
| [epicas.md](02-requisitos/epicas.md) | 🟡 |
| [historias/indice.md](02-requisitos/historias/indice.md) | 🟡 |
| [historias/EPC-01-captura.md](02-requisitos/historias/EPC-01-captura.md) | 🟡 |

## 03 · Triaje clínico – *¿cómo se decide el nivel?*
| Documento | Estado |
|---|---|
| [protocolo-triaje.md](03-triaje-clinico/protocolo-triaje.md) | 🟡 requiere veterinario |
| [reglas-por-sintoma.md](03-triaje-clinico/reglas-por-sintoma.md) | 🟡 requiere veterinario |
| [signos-vitales-por-especie.md](03-triaje-clinico/signos-vitales-por-especie.md) | 🟡 requiere veterinario |
| [validacion-veterinaria.md](03-triaje-clinico/validacion-veterinaria.md) | ⬜ |

## 04 · Diseño y UX – *¿cómo se ve y se siente?*
| Documento | Estado |
|---|---|
| [branding.md](04-diseno-ux/branding.md) | ⬜ decidir nombre |
| [design-system.md](04-diseno-ux/design-system.md) | 🟡 |
| [pantallas-mvp.md](04-diseno-ux/pantallas-mvp.md) | 🟡 |
| [mockups-referencia.md](04-diseno-ux/mockups-referencia.md) | 🟡 |

## 05 · Arquitectura – *¿cómo se construye?*
| Documento | Estado |
|---|---|
| [technical-spec.md](05-arquitectura/technical-spec.md) | 🟡 |
| [arquitectura-carpetas.md](05-arquitectura/arquitectura-carpetas.md) | ✅ estructura en vigor |
| [arquitectura-conceptos-y-brechas.md](05-arquitectura/arquitectura-conceptos-y-brechas.md) | ✅ conceptos · brechas → ADR-0006 |
| [modelo-de-datos.md](05-arquitectura/modelo-de-datos.md) | 🟡 |
| [seguridad-y-privacidad.md](05-arquitectura/seguridad-y-privacidad.md) | 🟡 |
| [adr/](05-arquitectura/adr/README.md) (decisiones técnicas) | 🟡 |

## 06 · Calidad – *¿cómo sabemos que funciona?*
| Documento | Estado |
|---|---|
| [estrategia-de-pruebas.md](06-calidad/estrategia-de-pruebas.md) | 🟡 |
| [checklist-qa-captura.md](06-calidad/checklist-qa-captura.md) | 🟡 |
| [definicion-de-hecho.md](06-calidad/definicion-de-hecho.md) | 🟡 |

## 07 · Gestión – *¿cómo y cuándo?*
| Documento | Estado |
|---|---|
| [metodologia.md](07-gestion/metodologia.md) | 🟡 |
| [planificacion.md](07-gestion/planificacion.md) | 🟡 |
| [backlog-tareas.md](07-gestion/backlog-tareas.md) | 🟡 |
| [riesgos.md](07-gestion/riesgos.md) | 🟡 |
| [preguntas-pendientes.md](07-gestion/preguntas-pendientes.md) | ⬜ |

## 08 · Administración
| Documento | Estado |
|---|---|
| [sistema-admin.md](08-administracion/sistema-admin.md) | 🟡 |

## Plantillas
[historia de usuario](plantillas/historia-de-usuario.md) · [tarea](plantillas/tarea.md) · [ADR](plantillas/adr.md) · [reporte de bug](plantillas/bug-report.md)

## Reglas de mantenimiento
- Una decisión que cambia se actualiza en el mismo commit.
- Cada documento responde **una** pregunta y se lee en pocos minutos; si crece, se divide.
- Al revisar un documento, se actualiza su estado en esta tabla.
