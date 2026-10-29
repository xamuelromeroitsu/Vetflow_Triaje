# Triaje (dominio `triage`)

Carpeta reservada para el dominio de triaje (niveles, síntomas, signos
vitales y el motor de reglas). **Sin código todavía**: no se escribe hasta que
el veterinario valide las reglas (`docs/03-triaje-clinico/`).

Cuando entre, la estructura será:

```
domain/
├── model/     TriageLevel, SymptomRule, TriageInput, TriageResult, rangos
├── service/   TriageEngine (domain service puro, sin Flutter ni backend)
└── port/      (si el motor necesita leer/guardar algo)
application/use_case/  EvaluateTriage
```

Regla irreductible: **el nivel de triaje nunca baja** por datos incompletos,
"no sé" o signos vitales faltantes; ante la duda, sube. Las reglas clínicas
son borrador hasta validación veterinaria.
