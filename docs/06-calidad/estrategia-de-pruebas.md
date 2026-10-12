# Estrategia de pruebas

| Tipo | Qué cubre | Cuándo |
|---|---|---|
| Unitarias | Motor de triaje, validadores de signos vitales | Siempre, desde el inicio |
| De widgets | Formularios y estados (cargando, error, éxito) | Por pantalla |
| Integración | Flujo registro → triaje → cola con emuladores de Firebase | Antes de cada hito |
| Manuales en dispositivo | Cámara, fotos, offline, accesibilidad | Antes de cada hito |
| Clínicas | Casos del veterinario contra las reglas | Antes del piloto |

## Prioridad
1. **Motor de triaje:** mayor cobertura. Regla de oro: el resultado nunca es menor al esperado.
2. Validaciones de formulario.
3. Reglas de seguridad de Firestore.
4. Offline y reintentos.

## Dispositivos de prueba
Al menos un Android de gama baja y uno reciente (completar con los reales).

## Criterio de salida de un hito
Sin errores críticos abiertos y checklist de QA completo.
