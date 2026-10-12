# Protocolo de triaje

> ⚠️ **Borrador.** Debe ser revisado y aprobado por un veterinario antes de usarse con público. Ver [validacion-veterinaria.md](validacion-veterinaria.md).

## Niveles
| Nivel | Icono | Significado | Qué se le dice al dueño |
|---|---|---|---|
| Emergencia | 🔴 | Riesgo de vida | Ve ya a una clínica |
| Urgencia | 🟠 | Necesita atención pronto | Debe ser atendido hoy |
| Consulta | 🟢 | Sin riesgo inmediato | Agenda una cita |

## Paso 1 · Preguntas de descarte (señales de alarma)
Se muestran **primero**. Un "sí" lleva directo a 🔴.
1. ¿Le cuesta respirar o respira con la boca abierta (gato)?
2. ¿Tiene convulsiones o está inconsciente?
3. ¿Sangra sin parar?
4. ¿Pudo haber ingerido veneno o un tóxico?
5. ¿Sufrió un golpe fuerte o atropello?
6. ¿Tiene el abdomen hinchado con arcadas sin vomitar?
7. (Gato macho) ¿Intenta orinar y no puede?

## Paso 2 · Nivel por síntomas
Cada síntoma tiene un nivel base ([reglas-por-sintoma.md](reglas-por-sintoma.md)). Se toma el **más alto** de los seleccionados.

## Paso 3 · Ajuste por signos vitales
Signos fuera de rango pueden **subir** el nivel, nunca bajarlo ([signos-vitales-por-especie.md](signos-vitales-por-especie.md)).

## Paso 4 · Reglas de seguridad
| Situación | Regla |
|---|---|
| Respuesta "no sé" a una pregunta de descarte | Mínimo 🟠 |
| Faltan signos vitales obligatorios | No se puede bajar de 🟠 |
| Cachorro, gatito o animal geriátrico | Subir un nivel si el resultado es 🟢 (a validar) |
| Dos o más síntomas 🟠 | Valorar 🔴 (a validar) |
| Duda | Subir de nivel |

## Pseudocódigo
```
if alguna_pregunta_descarte == "sí":        return EMERGENCIA
nivel = max(nivel_base(s) for s in síntomas)
nivel = max(nivel, ajuste_por_signos_vitales)
if respuesta_no_sé or faltan_signos:         nivel = max(nivel, URGENCIA)
return nivel, motivo, rulesVersion
```

## Revisión por el veterinario
El veterinario ve el nivel sugerido **y el motivo**, y puede cambiarlo. Se guardan ambos (`suggested` y `confirmed`) para medir y mejorar las reglas.
