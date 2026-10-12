# Alcance del MVP

## Objetivo
Que un dueño pueda registrar a su mascota con síntomas y signos vitales, reciba un nivel sugerido y un veterinario pueda confirmarlo.

## Dentro del MVP
| Función | Épica | Historias |
|---|---|---|
| Preguntas de descarte (señales de emergencia) | EPC-02 | US-05 |
| Registro de la mascota y antecedentes | EPC-01 | US-01 |
| Síntomas con texto guiado | EPC-01 | US-02 |
| Signos vitales | EPC-01 | US-04 |
| Fotos | EPC-01 | US-03 |
| Triaje por reglas (3 niveles) | EPC-02 | US-05, US-06 |
| Cola simple por prioridad | EPC-03 | US-07 |

## Fuera del MVP
| Función | Épica | Fase |
|---|---|---|
| Citas | EPC-06 | 2 |
| Noticias y primeros auxilios | EPC-04 | 3 |
| Mapa y directorio | EPC-05 | 3 |
| Carnet digital | EPC-07 | 3 |
| Multi-empresa y analítica | EPC-08 | 4 |
| IA / análisis de imágenes | — | Sin fecha |

## Supuestos
- Una clínica piloto.
- Perros y gatos (confirmar en [preguntas-pendientes](../07-gestion/preguntas-pendientes.md)).
- Reglas validadas por un veterinario antes de abrir la app al público.
- Sin pagos.

## Hecho cuando…
- [ ] Un dueño completa el registro de punta a punta desde el móvil.
- [ ] El caso se guarda con un nivel sugerido.
- [ ] El veterinario puede confirmar o corregir el nivel.
- [ ] La cola muestra primero los casos más graves.
- [ ] Pasó el [checklist de QA](../06-calidad/checklist-qa-captura.md).
- [ ] Un veterinario validó las reglas ([validación](../03-triaje-clinico/validacion-veterinaria.md)).
