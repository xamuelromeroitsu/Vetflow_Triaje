# Registro de riesgos

Probabilidad (P) e impacto (I): Alta / Media / Baja.

| # | Riesgo | P | I | Mitigación | Responsable |
|---|---|---|---|---|---|
| R-01 | Regla de triaje incorrecta (caso grave marcado como leve) | Media | Alta | Validación veterinaria, "ante la duda subir", confirmación humana, aviso al dueño | Veterinario / Producto |
| R-02 | El dueño ignora el aviso y confía solo en la app | Media | Alta | Aviso visible, lenguaje claro, recomendar siempre consultar | Producto |
| R-03 | Alcance que crece | Alta | Media | Respetar [mvp-scope](../01-producto/mvp-scope.md) | Producto |
| R-04 | Poca conectividad del usuario | Media | Media | Offline, resultado de emergencia sin conexión | Mobile |
| R-05 | Filtración de datos | Baja | Alta | Políticas RLS y de Storage, minimizar datos, revisar permisos | Backend |
| R-06 | Sin veterinario asesor | Media | Alta | Conseguirlo antes de H1 | Producto |
| R-07 | Nombre y marca sin definir | Media | Baja | Decidir en Fase 0 | Producto |
| R-08 | Costes de Supabase al crecer | Baja | Media | Monitorear uso; revisar en Fase 3 | Backend |
