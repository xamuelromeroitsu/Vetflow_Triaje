# Signos vitales por especie

> ⚠️ Valores de **referencia general** para empezar. Un veterinario debe confirmarlos antes de usarlos (varían por raza, edad y tamaño).

## Rangos normales de referencia
| Especie | Temperatura (°C) | Frecuencia cardíaca (lpm) | Estado |
|---|---|---|---|
| Perro | 38.3 – 39.2 | 60 – 140 (más alta en cachorros y razas pequeñas) | 🟡 borrador (ADR-0001/0003) |
| Gato | 38.1 – 39.2 | 140 – 220 | 🟡 borrador |
| Hurón | 37.8 – 39.4 | 140 – 220 | ⬜ sin validar (no ajusta nivel) |
| Conejo | 38.5 – 40.0 | 140 – 220 | ⬜ sin validar (no ajusta nivel) |
| Ave | 40.0 – 42.0 | 140 – 220 | ⬜ sin validar (no ajusta nivel) |
| Roedor | 37.0 – 39.0 | 140 – 220 | ⬜ sin validar (no ajusta nivel) |
| Reptil | 25.0 – 35.0 | 140 – 220 | ⬜ sin validar (no ajusta nivel) |

Las especies marcadas ⬜ están en el motor como referencia, pero **no
ajustan el nivel de triaje** hasta que el veterinario las valide
(ADR-0005). No se inventan umbrales.

## Rangos de captura (evitar errores de tipeo)
No son clínicos; solo impiden valores imposibles al escribir.
| Campo | Mínimo | Máximo |
|---|---|---|
| Temperatura | 30 °C | 45 °C |
| Peso | 0.05 kg | 120 kg |
| Frecuencia cardíaca | 20 lpm | 300 lpm |

## Uso en el triaje
| Condición | Efecto |
|---|---|
| Valor fuera de rango normal | Se marca; puede subir el nivel |
| Valor extremo (umbral a definir con el veterinario) | Sube a 🔴 |
| Valor faltante | No se puede bajar de 🟠 |

## Pendiente
- Umbrales de "extremo" por especie.
- Peso: ¿se compara con el peso esperado por raza?
- Otras especies (conejo, ave, etc.) si entran al alcance.
