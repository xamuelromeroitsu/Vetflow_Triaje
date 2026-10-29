# Estrategia de pruebas

| Tipo | Qué cubre | Cuándo |
|---|---|---|
| Unitarias | Motor de triaje, validadores de signos vitales | Siempre, desde el inicio |
| De widgets | Formularios y estados (cargando, error, éxito) | Por pantalla |
| Integración | Repositorios y flujo registro → visita → triaje con Supabase local | Antes de cada hito |
| Base de datos | Inserciones y políticas RLS de mascotas y visitas (pgTAP) | Antes de cada hito |
| Manuales en dispositivo | Cámara, fotos, offline, accesibilidad | Antes de cada hito |
| Clínicas | Casos del veterinario contra las reglas | Antes del piloto |

## Prioridad
1. **Motor de triaje:** mayor cobertura. Regla de oro: el resultado nunca es menor al esperado.
2. Validaciones de formulario.
3. Políticas de seguridad RLS de Supabase.
4. Offline y reintentos.

## Dispositivos de prueba
Al menos un Android de gama baja y uno reciente (completar con los reales).

## Pruebas de RLS

Con Supabase local iniciado y las migraciones aplicadas, ejecutar
`supabase test db`. La suite `vetflow_triaje/supabase/tests/rls_pets_visits.test.sql`
comprueba la inserción propia, el rechazo de escrituras cruzadas entre dueños,
la asignación del dueño de la visita, la conservación de los cuatro campos de
triaje y que el dueño no pueda confirmar ni bajar la sugerencia.

## Criterio de salida de un hito
Sin errores críticos abiertos y checklist de QA completo.
