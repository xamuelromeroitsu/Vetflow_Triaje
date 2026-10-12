# ADR-0005 · Reglas específicas por especie en el motor de triaje

**Estado:** Aceptada (pendiente de validación veterinaria de los rangos)

## Contexto

El MVP cubre 7 especies (perro, gato, hurón, conejo, ave, roedor, reptil),
pero el borrador clínico solo tiene rangos y reglas acotadas para perro y
gato (`signos-vitales-por-especie.md`, `reglas-por-sintoma.md`). El motor
necesita decidir qué hacer cuando una especie no tiene valores validados.

## Decisión

1. **`SpeciesClinicalProfile` por especie** (`species_clinical_profile.dart`):
   rangos de temperatura/frecuencia cardíaca, estado (`validated` |
   `pendingVet`) y umbrales de edad (cachorro/geriátrico).
2. **Especies con `pendingVet`**: el motor **no ajusta el nivel** por sus
   signos vitales y lo anota en `pendingValidationRules` para revisión del
   veterinario. No se inventan umbrales.
3. **Síntomas acotados a una especie** (`SymptomRule.appliesTo`): si la regla
   no aplica a la especie del paciente, se ignora con un motivo explícito
   ("no aplica a X") y se anota como pendiente. Nunca sube ni baja por esa
   regla. La UI deberá ofrecer solo síntomas aplicables por especie
   (`TriageRules` se puede filtrar por `appliesTo`).
4. **Nivel nunca baja**: todas las decisiones anteriores solo pueden subir o
   mantener el nivel (red de seguridad: "no sé" o vitales obligatorios
   ausentes → mínimo 🟠).
5. Cada cambio en estas reglas sube `rulesVersion` (esta versión: 0.2).

## Consecuencias

- ✅ Crecimiento de especies sin inventar datos clínicos.
- ✅ Los motivos y las pendientes quedan auditables para el veterinario.
- ⚠️ Para especies nuevas el triaje se apoya en las reglas de seguridad
  (más conservador, menos preciso) hasta la validación.
- ⚠️ La UI debe filtrar síntomas por especie o el veterinario verá avisos
  de "no aplica".

## Pendiente

- Validar rangos de las 5 especies restantes.
- Definir umbrales de edad (cachorro/geriátrico) por especie.
- Definir si "gato macho" se modela como atributo del paciente.
