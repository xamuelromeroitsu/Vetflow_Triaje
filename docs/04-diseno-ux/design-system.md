# Design system (base)

## Principios
1. **Calma:** el usuario está preocupado; sin ruido visual.
2. **Una acción principal por pantalla.**
3. **Nunca solo color:** el nivel de triaje usa color + icono + texto.
4. **Texto simple:** sin jerga clínica para el dueño.

## Niveles de triaje (componente `TriageBadge`)
| Nivel | Icono | Etiqueta | Color |
|---|---|---|---|
| Emergencia | ⚠️ | "Emergencia" | Rojo |
| Urgencia | ❗ | "Urgencia" | Naranja |
| Consulta | ✔️ | "Consulta" | Verde |

## Tokens (por definir)
| Token | Valor |
|---|---|
| Color primario | Turquesa/verde del logo (definir hex) |
| Color emergencia / urgencia / consulta | Definir con contraste adecuado |
| Tipografía | Por definir |
| Espaciado base | 8 px |
| Radio de bordes | Redondeado (como en los mockups) |

## Accesibilidad
- Contraste de texto suficiente (AA).
- Tamaño de toque mínimo 48 px.
- Textos escalables con el tamaño de fuente del sistema.

## Componentes del MVP
`TriageBadge` · `PetCard` · `SymptomChip` · `VitalInput` · `PhotoPicker` · `QueueItem` · `PrimaryButton`
