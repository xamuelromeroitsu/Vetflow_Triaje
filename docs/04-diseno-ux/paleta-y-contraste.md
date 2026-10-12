# Paleta y contraste

Estilo: **moderno, cálido y tranquilo**, acorde a una veterinaria. Parte del turquesa del logo, con fondos claros y detalles cálidos.

Los ratios están calculados con la fórmula WCAG. Meta: texto 4,5:1 · componentes de interfaz 3:1.

## Colores
| Token | Hex | Uso |
|---|---|---|
| Primario | `#1F7A6B` | Botones, enlaces, marca |
| Primario oscuro | `#0F4F45` | Texto sobre menta, encabezados |
| Menta | `#E3F3EF` | Superficies suaves, tarjetas |
| Fondo | `#F7FAF9` | Fondo de pantallas |
| Texto | `#17302B` | Texto principal |
| Texto secundario | `#4A5F5A` | Ayudas, etiquetas |
| Borde de campos | `#6F8A84` | Bordes de inputs y controles |
| Acento cálido | `#E8A33D` | Detalles decorativos (no para texto sobre blanco) |
| Emergencia | `#B3261E` | Nivel 🔴 |
| Urgencia | `#9A4A00` | Nivel 🟠 |
| Consulta | `#1B6E3A` | Nivel 🟢 |

## Contrastes comprobados
| Combinación | Ratio | Resultado |
|---|---|---|
| Blanco sobre Primario | 5,18:1 | ✅ AA |
| Texto sobre Fondo | 13,38:1 | ✅ AAA |
| Texto secundario sobre Fondo | 6,50:1 | ✅ AA |
| Texto sobre Menta | 12,27:1 | ✅ AAA |
| Primario oscuro sobre Menta | 8,24:1 | ✅ AAA |
| Emergencia sobre blanco / blanco sobre Emergencia | 6,54:1 | ✅ AA |
| Urgencia sobre blanco / blanco sobre Urgencia | 6,26:1 | ✅ AA |
| Consulta sobre blanco / blanco sobre Consulta | 6,29:1 | ✅ AA |
| Texto sobre Acento cálido | 6,52:1 | ✅ AA |
| Borde de campos sobre Fondo | 3,54:1 | ✅ componentes (3:1) |
| Primario sobre Fondo (enlaces) | 4,93:1 | ✅ AA |

⚠️ Un borde más claro (por ejemplo `#B7C9C4`) da solo 1,64:1 y **no pasa**; por eso los bordes de campos usan `#6F8A84`.

## Reglas
1. El nivel de triaje nunca se comunica solo con color: color + icono + texto ("Emergencia", "Urgencia", "Consulta").
2. El acento cálido es decorativo; no se usa como color de texto sobre fondo claro.
3. Los estados de error y selección llevan icono o texto además del color.
4. Si se cambia un color, recalcular el contraste antes de aprobarlo.
5. Modo oscuro: pendiente (el portal del mockup lo usa); definir tokens equivalentes y recalcular.

## Pendiente
- Confirmar con el diseño final del logo.
- Probar la paleta con personas daltónicas o con un simulador.
