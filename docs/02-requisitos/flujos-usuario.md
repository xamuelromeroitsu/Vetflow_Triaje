# Flujos de usuario

## Flujo 1 · Registro y triaje (dueño)
```
Abrir app
  └─▶ Preguntas de descarte (¿respira mal? ¿convulsiona? ¿sangra? ¿tóxico? ¿trauma?)
        ├─ Sí a alguna ─▶ 🔴 EMERGENCIA: "Ve ya a una clínica" (mostrar clínica/teléfono)
        └─ No ─▶ Elegir o crear mascota (US-01)
                   └─▶ Síntomas: categoría + lista + texto + desde cuándo (US-02)
                         └─▶ Signos vitales (US-04)
                               └─▶ Fotos opcionales (US-03)
                                     └─▶ Calcular nivel (US-05)
                                           └─▶ Resultado 🔴🟠🟢 + qué hacer + aviso
                                                 └─▶ Caso entra a la cola (US-07)
```

## Flujo 2 · Confirmación (veterinario)
```
Ver cola ─▶ Abrir caso ─▶ Ver síntomas, signos, fotos y motivo del nivel
   ─▶ Confirmar o corregir nivel ─▶ Atender ─▶ Marcar como atendido
```

## Flujo 3 · Sin conexión
```
Dueño llena el formulario sin internet
  ─▶ Se guarda localmente
  ─▶ Al volver la conexión se envía solo
  ─▶ Si el nivel es 🔴 y no hay conexión: mostrar mensaje "ve ya a una clínica" sin esperar al envío
```

## Reglas de comportamiento
- Las preguntas de descarte van **primero**, antes de pedir datos largos.
- Si el dueño responde "no sé" a una pregunta clave, se trata como posible riesgo (no baja el nivel).
- El resultado de Emergencia nunca depende de que se complete todo el formulario.
