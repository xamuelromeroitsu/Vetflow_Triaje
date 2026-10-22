# EPC-02 — Motor de Clasificación de Riesgo (Triaje)

Implementación del backend para la epica **EPC-02**: evaluar síntomas y signos
vitales para sugerir automáticamente el nivel de atención (Emergencia / Urgencia /
Consulta), con confirmación del veterinario.

---

## Regla absoluta

La carpeta `integrador/` se ignora por completo. Todo el "backend" vive dentro de
`vetflow_triaje/` como código Dart sobre Firebase (Auth, Firestore, Storage),
sin servidor propio.

Las reglas clínicas son **borrador** hasta que un veterinario las valide
(`docs/03-triaje-clinico/validacion-veterinaria.md`). No se inventan rangos ni
síntomas. El triaje **nunca baja de nivel** por datos incompletos, "no sé" o
signos vitales faltantes: ante la duda, subir.

---

## Cómo se hizo

### 1. Dominio `triage/` — lógica pura de negocio

Se crearon los siguientes archivos bajo
`lib/features/triage/`:

| Archivo | Propósito |
|---------|-----------|
| `domain/model/triage_level.dart` | Enum `TriageLevel` (consulta, urgencia, emergencia) con icono, texto, mensaje para el dueño y orden numérico. Nunca solo color: siempre ícono + texto. |
| `domain/model/triage_result.dart` | Resultado con `suggested` y `confirmed` por separado, `reasons`, `rulesVersion` y `pendingValidationRules`. |
| `domain/model/symptom_rule.dart` | Regla de síntoma con nivel base, categoría, ítem y especies aplicables (`appliesTo`). |
| `domain/model/species_clinical_profile.dart` | Perfil clínico por especie con estado `validated` / `pendingVet` y rangos de signos vitales. |
| `domain/model/red_flag_rule.dart` | Regla de descarte (señal de alarma). Un "sí" → Emergencia directa. |
| `domain/service/triage_engine.dart` | Motor de reglas puro (domain service): descarte → nivel por síntomas → ajuste por signos vitales (solo subir) → reglas de seguridad ("no sé" = mínimo Urgencia, faltan signos = no bajar de Urgencia). |
| `application/use_case/evaluate_triage.dart` | Caso de uso que orquesta el motor y devuelve `TriageResult`. |
| `application/use_case/confirm_triage.dart` | Caso de uso para que el veterinario confirme o corrija el nivel (guarda `suggested` y `confirmed` por separado). |

### 2. Reglas del motor (según `docs/03-triaje-clinico/protocolo-triaje.md`)

```
1. Si alguna pregunta de descarte == "sí"        → EMERGENCIA
2. nivel = max(nivel_base de síntomas)
3. nivel = max(nivel, ajuste_por_signos_vitales)  (solo subir, nunca bajar)
4. Si "no sé" o faltan signos vitales obligatorios → mínimo URGENCIA
5. El nivel nunca baja
```

Cada cambio en las reglas sube `rulesVersion` (ADR-0003). Las especies con
`pendingVet` no ajustan el nivel por signos vitales (ADR-0005): no se inventan
umbrales y se anota para revisión veterinaria.

---

## Qué utilicé

- **Arquitectura:** Clean + Hexagonal + Vertical Slicing
  (`docs/05-arquitectura/arquitectura-carpetas.md`).
- **Patrones:** Puerto/Repositorio, Value Objects, Domain Service
  (`TriageEngine`), `Result<T>` del kernel compartido.
- **Tecnología:** Dart puro (sin Flutter, sin Firebase) en el dominio, para que
  el motor sea 100% testeable con pruebas unitarias sin emulador.
- **Referencia de reglas clínicas:**
  - `docs/03-triaje-clinico/protocolo-triaje.md`
  - `docs/03-triaje-clinico/reglas-por-sintoma.md`
  - `docs/05-arquitectura/adr/0003-triaje-por-reglas-versionadas.md`
  - `docs/05-arquitectura/adr/0005-reglas-por-especie.md`

---

## Qué cambió

### Archivos creados

```
lib/features/triage/domain/model/triage_level.dart
lib/features/triage/domain/model/triage_result.dart
lib/features/triage/domain/model/symptom_rule.dart
lib/features/triage/domain/model/species_clinical_profile.dart
lib/features/triage/domain/model/red_flag_rule.dart
lib/features/triage/domain/service/triage_engine.dart
lib/features/triage/application/use_case/evaluate_triage.dart
lib/features/triage/application/use_case/confirm_triage.dart
```

### Archivos modificados

- `lib/app/di/app_dependencies.dart` — se agregó `TriageModule` al módulo raíz.
- `lib/app/di/triage_dependencies.dart` — nuevo módulo DI para triaje.
- `vetflow_triaje/firestore.rules` — reglas actualizadas para `visits` con
  campos de triaje (`suggested`, `confirmed`, `reasons`, `rulesVersion`).

### Estado del módulo raíz (`AppDependencies`)

Ahora agrupa `OwnerModule`, `PetModule`, `VisitModule`, `TriageModule` y
`QueueModule`.

---

## Estado nuevo del proyecto

- ✅ **EPC-01** (Captura y Registro de Mascotas y Síntomas): implementada en
  rama `backend-E1`.
- ✅ **EPC-02** (Motor de Clasificación de Riesgo / Triaje): implementada en
  rama `backend-E2-E3`. El motor calcula el nivel sugerido, pero **no se usa con
  público hasta validación veterinaria** (reglas clínicas en borrador).
- ⏳ **EPC-03** (Gestión de Colas y Derivación): implementada en la misma rama.
- ⚠️ Pendiente: validación veterinaria de rangos y síntomas antes de activar el
  triaje en la app móvil.

---

## Pendientes críticos (no asumir)

- Veterinario asesor que valide las reglas clínicas (`docs/07-gestion/preguntas-pendientes.md` #2).
- Rangos de signos vitales validados por veterinario (#6).
- País objetivo y normativa de protección de datos (#1, #11).
