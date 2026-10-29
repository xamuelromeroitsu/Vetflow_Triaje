# US-13 · Encontrar la clínica más cercana

**Épica:** EPC-06 · **Prioridad:** Alta · **Fase:** 3

**Como** dueño de mascota, **quiero** ver la clínica veterinaria más cercana a mi ubicación actual, **para** reducir traslados innecesarios en emergencias.

## Criterios de aceptación
- [ ] Detectar ubicación actual del dispositivo (GPS) con consentimiento del usuario.
- [ ] Calcular y mostrar la clínica más cercana en distancia.
- [ ] Mostrar distancia estimada y tiempo aproximado de traslado.
- [ ] Permitir buscar manualmente por dirección si el GPS no está disponible o el usuario lo prefiere.
- [ ] Nunca bloquear el triaje por falta de geolocalización (ante la duda, subir nivel de triaje).

## Escenario
```
Dado que el usuario otorga permiso de ubicación
Cuando abre la pantalla de clínica más cercana
Entonces se muestra la clínica más próxima con distancia y tiempo estimado
```

## Fuera de alcance
- Navegación paso a paso (turn-by-turn) hacia la clínica.
- Llamada automática a la clínica (solo mostrar teléfono).

## Preguntas pendientes
- ¿Se usa Google Maps / Apple Maps como proveedor de mapas y geocodificación?

## Diseño / pantallas
P-13 · clínica más cercana con mapa y distancia

## Tareas
TAR-XX, TAR-XX
