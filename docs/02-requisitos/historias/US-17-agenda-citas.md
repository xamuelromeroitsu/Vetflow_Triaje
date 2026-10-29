# US-17 · Gestionar agenda de citas (veterinario/administrativo)

**Épica:** EPC-07 · **Prioridad:** Alta · **Fase:** 2

**Como** veterinario o personal administrativo, **quiero** ver y gestionar la agenda de citas programadas de mi clínica, **para** organizar la atención y asignar salas/veterinarios.

## Criterios de aceptación
- [ ] Ver agenda del día/semana con citas programadas, hora, mascota, dueño y veterinario asignado.
- [ ] Asignar o reasignar veterinario y sala a una cita.
- [ ] Cambiar estado de la cita (programada → en curso → completada/cancelada).
- [ ] Ver motivos de cancelación o reprogramación si aplica.
- [ ] Solo el personal de la clínica (rol `personal`) puede gestionar la agenda.

## Escenario
```
Dado que el veterinario abre la agenda del día
Cuando selecciona una cita programada y marca "en curso"
Entonces el estado de la cita cambia a "en curso"
```

## Fuera de alcance
- Crear citas desde el lado del veterinario sin solicitud del dueño (opcional, fase posterior).
- Gestión de inventario o facturación de la consulta.

## Preguntas pendientes
- ¿Cada veterinario tiene su propia agenda o hay una agenda compartida por clínica?

## Diseño / pantallas
P-17 · agenda de citas de la clínica

## Tareas
TAR-XX, TAR-XX
