# Agentes y skills del proyecto

Todo vive en la carpeta `.claude/` en la raíz del repo, junto con `CLAUDE.md`. Los agentes y skills son herramientas para **Claude Code**; no afectan al código de la app.

```
.claude/
├── agents/          ← agentes (cada uno es un .md con un rol)
└── skills/          ← skills (cada una es una carpeta con SKILL.md)
CLAUDE.md            ← reglas que Claude Code lee siempre
```

## Agentes (`.claude/agents/`)
| Agente | Para qué | Puede modificar archivos |
|---|---|---|
| `triage-clinical-reviewer` | Revisar reglas y código del triaje (nunca bajar nivel) | No |
| `firebase-architect` | Colecciones, reglas, índices, Storage, Auth | Sí |
| `flutter-developer` | Escribir pantallas, repositorios y lógica | Sí |
| `qa-tester` | Pruebas unitarias, de widgets, emulador y offline | Sí |
| `compliance-reviewer` | Privacidad, textos, terceros, accesibilidad | No |
| `docs-keeper` | Mantener documentación, estados y enlaces | Sí |
| `code-reviewer` | Revisar el diff antes de integrar | No |

## Skills (`.claude/skills/`)
| Skill | Cuándo se usa |
|---|---|
| `domain-modeling` | Cambiar colecciones, campos o soporte multi-empresa |
| `codebase-architecture` | Nueva feature, refactor, dónde va cada archivo |
| `flutter-mobile-ui` | Pantallas, componentes, colores, estados |
| `firebase-backend` | Auth, Firestore, reglas, Storage, offline, emulador |
| `tdd-triage` | Reglas de triaje y signos vitales, con pruebas primero |
| `offline-sync-review` | Bugs de sincronización, duplicados, modo avión |
| `accessibility-wcag` | Contraste, etiquetas, texto alternativo, teclado |
| `privacy-and-consent` | Datos mínimos, consentimientos, analítica, terceros, cookies |
| `legal-content-review` | Términos, afirmaciones, reseñas, reembolsos, imágenes |

## Qué usar en cada paso del plan
| Paso | Skills | Agentes |
|---|---|---|
| 0 · Base | `firebase-backend`, `codebase-architecture` | `flutter-developer`, `firebase-architect` |
| 1 · Mascota | `domain-modeling`, `flutter-mobile-ui`, `privacy-and-consent` | `flutter-developer`, `compliance-reviewer` |
| 2 · Síntomas | `flutter-mobile-ui`, `accessibility-wcag` | `flutter-developer`, `qa-tester` |
| 3 · Signos vitales | `flutter-mobile-ui`, `tdd-triage` | `flutter-developer`, `qa-tester` |
| 4 · Fotos | `firebase-backend`, `privacy-and-consent` | `firebase-architect`, `compliance-reviewer` |
| 5 · Offline | `offline-sync-review`, `firebase-backend` | `qa-tester`, `code-reviewer` |
| 6 · Triaje | `tdd-triage`, `legal-content-review` | `triage-clinical-reviewer`, `qa-tester` |
| 7 · Cola | `domain-modeling`, `firebase-backend` | `firebase-architect`, `code-reviewer` |

## Cómo se usan (Claude Code)
- Los agentes se pueden pedir por nombre ("usa el agente `code-reviewer` en mis cambios") y Claude Code también puede delegar solos según la descripción. Con `/agents` los ves y gestionas.
- Las skills se activan cuando la tarea coincide con su descripción.
- Verifica los detalles actuales de formato y ubicación en la documentación oficial de Claude Code: https://code.claude.com/docs/en/sub-agents

## Skills de terceros que mencionaste
Los nombres `improve-codebase-architecture`, `ui-taste`, `design-mobile-apps`, `vercel-react-best-practices`, `diagnosing-bugs` y `code-review` son skills de otras fuentes: no están incluidas aquí y no conozco su contenido exacto.
- Si las instalas desde su fuente, revisa su `SKILL.md` antes de usarlas.
- Las skills de este repo cubren las mismas necesidades pero ajustadas a VetFlow (Flutter, Firebase, triaje, privacidad).
- `vercel-react-best-practices` solo tendrá sentido si construyes un portal web en React/Next.js (Fase 2–4); no hace falta antes.

## Mantenimiento
Si una regla cambia (por ejemplo, el protocolo de triaje), se actualiza el documento en `docs/` y la skill o agente que lo cita, en el mismo commit.
