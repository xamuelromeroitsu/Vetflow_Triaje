# US-15 · Agendar cita programada (caso Consulta)

**Épica:** EPC-07 · **Prioridad:** Alta · **Fase:** 2

**Como** dueño de mascota con nivel de triaje "Consulta", **quiero** agendar una consulta veterinaria programada, **para** descongestionar las salas de espera y atender casos leves con hora asignada.

## Criterios de aceptación
- [ ] Agendar cita eligiendo mascota, clínica, veterinario (si aplica), fecha y hora disponible.
- [ ] Solo permitir agendar cuando el triaje sugerido sea "Consulta" (no emergencia ni urgencia).
- [ ] Mostrar horarios disponibles del veterinario/clínica para la fecha elegida.
- [ ] Confirmar la cita y generar un turno de cita programada.
- [ ] Enviar recordatorio o confirmación de la cita agendada.

## Escenario
```
Dado que el triaje de la mascota resultó en nivel "Consulta"
Cuando el dueño elige fecha y hora disponibles y confirma
Entonces se crea una cita programada con estado "programada"
```

## Fuera de alcance
- Atención de emergencias/urgencias sin cita (pertenece a EPC-01/EPC-02 y cola EPC-03).
- Pagos o prepago de la cita.

## Preguntas pendientes
- ¿Cuánto tiempo antes se permite cancelar o reprogramar una cita?
- ¿Se requiere pago o prepago para confirmar la cita?

## Diseño / pantallas
P-15 · agenda y agendamiento de cita

## Tareas
TAR-XX, TAR-XX
