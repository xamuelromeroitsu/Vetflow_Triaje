# Metodología

Scrum ligero: ciclos cortos, historias pequeñas, algo funcionando al final de cada ciclo.

## Ciclo
1. Elegir historias "Listas" del backlog.
2. Dividirlas en tareas (TAR-XX).
3. Construir, probar y cerrar según la [definición de Hecho](../06-calidad/definicion-de-hecho.md).
4. Revisar qué se aprendió y ajustar el plan.

## Estados
`Por hacer` → `En curso` → `En revisión` → `Hecho` (más `Bloqueado` si aplica).

## Ramas
| Rama | Uso |
|---|---|
| `main` | Siempre estable |
| `feature/us-01-registro-mascota` | Una historia = una rama |
| `fix/descripcion-corta` | Correcciones |
| `docs/descripcion-corta` | Solo documentación |

## Commits
`tipo(alcance): descripción`. Ejemplos: `docs(triaje): agrega reglas iniciales` · `feat(pets): formulario de mascota` · `fix(vitals): valida rango de temperatura`.

## Identificadores
| Elemento | Formato |
|---|---|
| Épica | `EPC-01` |
| Historia | `US-01` (únicas) |
| Tarea | `TAR-01` |
| Requisitos | `RF-01` / `RNF-01` |
| Decisión técnica | `ADR-0001` |
| Pantalla | `P-01` |

## Reuniones sugeridas
Planificación (inicio de sprint) · Seguimiento corto (2–3 veces por semana) · Revisión y retrospectiva (fin de sprint).

## Roles (completar)
Producto · Mobile · Backend · QA · Veterinario asesor.
