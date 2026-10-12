# ADR-0002 · Dueño y mascota fuera de la clínica

**Estado:** Propuesta

## Contexto
El borrador inicial ponía `patients` dentro de `companies`. Una mascota puede ir a varias clínicas.

## Decisión
`owners` y `pets` son colecciones globales; cada clínica solo guarda `visits` con `companyId`.

## Consecuencias
- ✅ Sin duplicar la mascota por clínica; prepara el carnet digital y la red.
- ⚠️ Las reglas de seguridad son más finas (qué clínica ve qué).
- ⚠️ Hay que definir qué datos del historial ve cada clínica.
