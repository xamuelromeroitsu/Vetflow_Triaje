# US-19 · Registrar vacunas y tratamientos

**Épica:** EPC-08 · **Prioridad:** Media · **Fase:** 3

**Como** veterinario, **quiero** registrar vacunas aplicadas y tratamientos recetados en el carnet de salud de la mascota, **para** mantener el historial actualizado y disponible para futuras atenciones.

## Criterios de aceptación
- [ ] Registrar vacuna con nombre, fecha de aplicación, próxima fecha por vencer y lote (opcional).
- [ ] Registrar tratamiento con medicamento, dosis, frecuencia, duración y fecha de inicio/fin.
- [ ] Vincular la vacuna o tratamiento a una mascota específica.
- [ ] Marcar vacunas como vencidas o por vencer según la fecha actual.
- [ ] Solo el veterinario (rol `personal`) puede crear/modificar vacunas y tratamientos.

## Escenario
```
Dado que el veterinario atiende a una mascota
Cuando registra una vacuna aplicada con fecha y próxima dosis
Entonces la vacuna queda guardada en el carnet de salud de la mascota
```

## Fuera de alcance
- Registro de vacunas por el dueño (solo lectura; escritura de veterinario).
- Inventario de vacunas de la clínica.

## Preguntas pendientes
- ¿Se envía alerta al dueño cuando una vacuna está por vencer?

## Diseño / pantallas
P-19 · registro de vacunas y tratamientos

## Tareas
TAR-XX, TAR-XX
