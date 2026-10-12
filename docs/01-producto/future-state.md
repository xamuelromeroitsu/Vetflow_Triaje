# Estado futuro

> Nada de esto entra en el MVP. Se documenta para no tomar hoy decisiones técnicas que lo bloqueen mañana.

## Visión: red de clínicas (B2B2C)
Un núcleo con empresas asociadas. Cada clínica tiene su panel aislado; los dueños descubren y usan cualquier clínica de la red según cercanía y disponibilidad.

## EPC-08 · Ecosistema multi-empresa
| ID | Historia |
|---|---|
| US-09 | **Onboarding de empresas:** como administrador de una clínica nueva, quiero registrarla con ubicación, horarios y especialidades, para empezar a recibir casos. |
| US-10 | **Mapa de clínicas:** como dueño con una urgencia, quiero ver clínicas cercanas ordenadas por distancia y saturación, para elegir la más eficiente. |
| US-11 | **Analítica B2B:** como dueño de una clínica, quiero ver volumen de casos y tiempos de respuesta, para evaluar mi operación. |

## Preparado desde el MVP
- `companyId` opcional en las visitas.
- Dueño y mascota fuera de la clínica ([ADR-0002](../05-arquitectura/adr/0002-duenos-y-mascotas-fuera-de-la-clinica.md)).
- Reglas de triaje versionadas (`rulesVersion`).

## Ideas sin compromiso
- Triaje asistido por IA y análisis de fotos (exige validación veterinaria fuerte).
- Notificaciones de turno.
- Carnet con QR para compartir historial entre clínicas.
- Suscripción por clínica.
