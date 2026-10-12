# Product Brief

## En una frase
VetFlow ayuda a que los casos graves de mascotas se atiendan primero y a que el dueño sepa qué hacer, antes de llegar a la clínica.

## Problema
- En la clínica, casos graves y leves esperan en la misma fila.
- El dueño no sabe si es una urgencia o si puede pedir una cita.
- La recepción recoge la información a mano y sin un formato común.

## Propuesta de valor
| Para | Valor |
|---|---|
| Dueño | Saber en minutos si debe ir ya, hoy o con cita |
| Recepción | Datos ordenados y signos vitales capturados una sola vez |
| Veterinario | Cola priorizada y ficha del caso lista al llegar |
| Clínica | Menos saturación en sala de espera |

## Solución
Flujo guiado: preguntas de descarte rápido → mascota → síntomas → signos vitales → fotos → nivel sugerido → cola. Ver [flujos-usuario.md](../02-requisitos/flujos-usuario.md).

| Nivel | Significado |
|---|---|
| 🔴 Emergencia | Atención inmediata |
| 🟠 Urgencia | Atención pronto / el mismo día |
| 🟢 Consulta | Cita programada |

## Principios
1. **Ayuda a la decisión, no diagnóstico.** El veterinario confirma o corrige.
2. **Ante la duda, subir de nivel.**
3. **Seguridad antes que comodidad:** nunca bajar un nivel por datos incompletos.
4. **Pasos pequeños:** cada pieza se construye, prueba y cierra antes de la siguiente.
5. **Accesible:** pensado para una persona nerviosa, con una mano, en el móvil.

## Qué NO es
- No es telemedicina ni chat con veterinario.
- No receta ni diagnostica.
- No reemplaza la evaluación presencial.

## Métricas de éxito (a medir en la clínica piloto)
| Métrica | Meta inicial |
|---|---|
| Tiempo para completar el registro | < 3 minutos |
| Casos de emergencia clasificados como "Consulta" | 0 |
| Coincidencia nivel sugerido vs confirmado | A definir con el veterinario asesor |
| Casos abandonados a mitad del formulario | A medir |

## Documentos relacionados
[mvp-scope.md](mvp-scope.md) · [usuarios-y-personas.md](usuarios-y-personas.md) · [future-state.md](future-state.md)
