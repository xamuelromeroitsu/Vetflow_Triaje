# Especificación funcional

## Módulos
| # | Módulo | Épica | Móvil | Web | Usuario | Fase |
|---|---|---|---|---|---|---|
| 1 | Registrar patología/síntomas | EPC-01 | ✅ | ✅ | Dueño, recepción | MVP |
| 2 | Triaje veterinario | EPC-02 | ✅ | ✅ | Veterinario, sistema | MVP |
| 3 | Cola de urgencias | EPC-03 | ✅ | ✅ | Veterinario, admin | MVP (simple) |
| 4 | Noticias y consejos | EPC-04 | ✅ | ✅ | Dueño | 3 |
| 5 | Directorio de centros | EPC-05 | ✅ | ✅ | Dueño | 3 |
| 6 | Calendario de citas | EPC-06 | ✅ | ✅ | Dueño, veterinario | 2 |
| 7 | Carnet de salud digital | EPC-07 | ✅ | ✅ | Dueño | 3 |

## Requisitos funcionales (MVP)
| ID | Requisito | Historia |
|---|---|---|
| RF-01 | Crear y editar el perfil de la mascota | US-01 |
| RF-02 | Elegir categoría de síntomas, síntomas frecuentes y texto libre | US-02 |
| RF-03 | Indicar desde cuándo ocurren los síntomas | US-02 |
| RF-04 | Adjuntar hasta 3 imágenes JPG/PNG | US-03 |
| RF-05 | Registrar temperatura, peso y frecuencia cardíaca con validación por especie | US-04 |
| RF-06 | Mostrar preguntas de descarte al inicio; un "sí" lleva a Emergencia | US-05 |
| RF-07 | Calcular el nivel con las reglas del [protocolo](../03-triaje-clinico/protocolo-triaje.md) | US-05 |
| RF-08 | Guardar nivel sugerido y confirmado por separado | US-06 |
| RF-09 | Mostrar al veterinario **por qué** se sugirió el nivel | US-06 |
| RF-10 | Listar casos por nivel y luego por hora de llegada | US-07 |
| RF-11 | Mostrar aviso de que la app no sustituye al veterinario | US-05 |

## Detalle
[flujos-usuario.md](flujos-usuario.md) · [historias](historias/indice.md) · [requisitos no funcionales](requisitos-no-funcionales.md)
