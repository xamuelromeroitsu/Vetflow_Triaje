# US-12 · Ver directorio de clínicas veterinarias

**Épica:** EPC-06 · **Prioridad:** Alta · **Fase:** 3

**Como** dueño de mascota o personal de admisión, **quiero** ver un listado de clínicas veterinarias filtrado por especialidad y horario, **para** elegir la clínica adecuada según la necesidad de la mascota.

## Criterios de aceptación
- [ ] Listar clínicas disponibles con nombre, dirección, especialidades y horario de atención.
- [ ] Filtrar por especialidad (ej. medicina general, cirugía, dermatología, emergencias).
- [ ] Filtrar por horario (abiertas ahora, abiertas 24h, horario de guardia).
- [ ] Ordenar por cercanía (distancia estimada) cuando haya ubicación disponible.
- [ ] Mensaje claro si no hay clínicas que coincidan con los filtros.

## Escenario
```
Dado que el dueño filtra por especialidad "emergencias" y horario "abiertas 24h"
Cuando consulta el directorio
Entonces se muestran solo las clínicas de emergencia con atención 24 horas
```

## Fuera de alcance
- Reserva de cita directa desde el directorio (pertenece a EPC-07).
- Compra de productos o servicios de la clínica.

## Preguntas pendientes
- ¿Quién da de alta y actualiza las clínicas y sus horarios?
- ¿Cuál es la fuente de datos de especialidades y horarios?

## Diseño / pantallas
P-12 · directorio de clínicas con filtros y mapa

## Tareas
TAR-XX, TAR-XX
