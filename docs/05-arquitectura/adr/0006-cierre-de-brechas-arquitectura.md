# ADR-0006 · Cierre de brechas de arquitectura (del 90 al 100)

**Estado:** Propuesta
**Fecha:** 2026-10-14

## Contexto

La app arrancó con el núcleo hexagonal completo: hexágono con puertos, casos de
uso como in-ports, adaptadores driven contra Firebase, composition root en
`app/di/` y shared kernel (`shared/domain/`). Eso ya nos da la escalabilidad
buscada y los tests de dominio corren con dobles, sin emulador.

Lo que falta son las piezas que **cruzan los bordes** (diagnóstico detallado en
[arquitectura-conceptos-y-brechas.md](../arquitectura-conceptos-y-brechas.md#5--diagnóstico-honesto-del-90-al-100)):

1. Sin `Clock` / `IdGenerator` / `Logger` como puertos transversales en
   `shared/`, el dominio usaría `DateTime.now()` o UUID directo: tests no
   deterministas y dependencias ocultas.
2. Sin domain events + publisher, avisar al veterinario de un caso crítico
   acoplaría el triaje a las notificaciones.
3. Sin traducción de errores infra → dominio, una `FirebaseAuthException` podría
   escapar al dominio y el puerto perdería su sentido.
4. Sin contract tests, nadie verifica que el adaptador de Firestore cumple
   realmente el contrato del puerto.
5. Sin `shared/testing/`, cada test reescribe sus dobles en memoria.

## Decisión

Adoptar el cierre de brechas por fases, sin reescribir lo construido:

- **Fase A (con `auth`, ahora):** puertos transversales en
  `shared/port/` (`Clock`, `IdGenerator`, `Logger`); `shared/testing/` con dobles
  reutilizables; mapeo de errores infra → dominio en `infrastructure/`; contract
  test del adaptador contra el puerto.
- **Fase B (con `triage`):** domain events + publisher; modelado DDD táctico del
  bounded context (aggregate `TriageSession`, value objects, eventos);
  anti-corruption layer / context map para los datos de paciente; pruebas de
  `firestore.rules`.
- **Fase C (con la UI):** pipeline de aplicación (decoradores transversales) y
  `app/config/` por entorno; adaptador driving en `infrastructure/presentation/`.

El árbol objetivo queda como **propuesta**; [arquitectura-carpetas.md](../arquitectura-carpetas.md)
sigue siendo la estructura en vigor hasta que esta ADR se acepte.

## Consecuencias

- ✅ Dominio determinista y testeable sin emulador ni credenciales.
- ✅ El veterinario puede validar las reglas (`rulesVersion`) sin tocar
  infraestructura; los eventos desacoplan notificaciones del motor de triaje.
- ✅ Cambiar de backend sigue tocando solo `app/di/` y los adaptadores.
- ⚠️ Más archivos e indirección (puertos transversales, pipeline) que mantener.
- ⚠️ Los contract tests exigen emulador de Firestore en CI (coste de setup).
- ⚠️ DDD táctico añade complejidad; se limita a `triage`, no se impone a
  `pets`/`owners` (CRUD simple).

## Alternativas consideradas

- **Mantener el 90 actual:** el dominio funciona, pero arrastra dependencias
  ocultas (`DateTime.now()`, excepciones de Firebase) que terminan como bugs en
  tests y en producción.
- **Rehacer la arquitectura desde cero con DDD primero:** desperdicia lo ya
  construido y validado en `auth`; el hexagonal actual ya da la escalabilidad
  buscada.
- **DDD completo en todos los contextos:** sobrecoste en contextos CRUD; se
  aplica táctico solo donde el dominio es complejo (triage).
