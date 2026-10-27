# Matriz de cumplimiento

> **No es asesoría legal.** Las leyes dependen del país objetivo, que sigue pendiente ([preguntas-pendientes](../07-gestion/preguntas-pendientes.md)). Los textos legales finales debe revisarlos un profesional.

**Aplica a:** 📱 app móvil · 🌐 portal web (Fase 2 en adelante) · ambos

| # | Tema | ¿Aplica? | Cómo se aplica en VetFlow | Fase | Skill / agente |
|---|---|---|---|---|---|
| 1 | Política de privacidad | 📱🌐 Sí | Obligatoria antes de recoger datos reales; esquema en [esquema-politica-privacidad.md](esquema-politica-privacidad.md) | MVP (antes del piloto) | `privacy-and-consent` |
| 2 | Datos de negocio (clínicas) | 🌐 Sí | Separados por `companyId`; las métricas B2B se agregan sin datos personales | 4 | `domain-modeling` |
| 3 | Solo datos necesarios | 📱 Sí | Cada campo se justifica con el triaje; pedir lo demás después o no pedirlo | MVP | `privacy-and-consent` |
| 4 | Formularios accesibles por teclado | 📱🌐 Sí | Orden de foco, teclado por campo, "Siguiente/Enviar", etiquetas | MVP | `accessibility-wcag` |
| 5 | Política de cookies | 🌐 Solo web | La app no usa cookies de navegador; el portal web sí necesitará banner y política | 2+ | `privacy-and-consent` |
| 6 | Integraciones de terceros | 📱🌐 Sí | Supabase desde el inicio; mapas y analítica después; todo en [registro-de-terceros.md](registro-de-terceros.md) | MVP / 3 | `privacy-and-consent` |
| 7 | Eliminar reseñas falsas | 📱🌐 Cuando existan reseñas | Directorio de clínicas (EPC-05): reseña solo con visita real, moderación, denuncias | 3 | `legal-content-review` |
| 8 | Política de reembolso | 📱🌐 Solo si hay pagos | No aplica al MVP; definir si hay citas pagadas o suscripción | 2–4 | `legal-content-review` |
| 9 | Leyes locales | 📱🌐 Sí | Depende del país; listar y revisar con un profesional | Antes del piloto | `legal-content-review` |
| 10 | Texto alternativo | 📱🌐 Sí | `semanticLabel` en imágenes informativas; decorativas fuera del lector | MVP | `accessibility-wcag` |
| 11 | Contraste de colores | 📱🌐 Sí | Paleta comprobada en [paleta-y-contraste.md](../04-diseno-ux/paleta-y-contraste.md) | MVP | `accessibility-wcag`, `flutter-mobile-ui` |
| 12 | Colores modernos y acordes a veterinaria | 📱🌐 Sí | Turquesa del logo + fondos claros + acento cálido | MVP | `flutter-mobile-ui` |
| 13 | Consentimiento de cookies | 🌐 Solo web | Banner con aceptar/rechazar con el mismo peso visual, categorías y registro | 2+ | `privacy-and-consent` |
| 14 | Derechos de imágenes (copyright) | 📱🌐 Sí | Registrar origen y licencia; las imágenes de IA solo como referencia; fotos de usuarios con términos | MVP | `legal-content-review` |
| 15 | Sitios y app accesibles | 📱🌐 Sí | Meta WCAG 2.1 AA; pruebas con TalkBack/VoiceOver | MVP | `accessibility-wcag` |
| 16 | Consentimiento en formularios | 📱🌐 Sí | Casillas sin marcar, uno por finalidad, se guarda qué/cuándo/versión; la emergencia no se bloquea | MVP | `privacy-and-consent` |
| 17 | Seguimiento de analítica | 📱🌐 Sí | Desactivada hasta aceptar; sin datos de salud ni identificadores del dueño | 2–3 | `privacy-and-consent` |
| 18 | Etiquetas claras | 📱🌐 Sí | Etiqueta visible por campo, unidades visibles (°C, kg), obligatorios indicados con texto | MVP | `flutter-mobile-ui`, `accessibility-wcag` |
| 19 | Términos y condiciones | 📱🌐 Sí | Esquema con profesional; aceptación al registrarse | MVP (antes del piloto) | `legal-content-review` |
| 20 | Afirmaciones sin respaldo | 📱🌐 Sí | Sin "diagnóstico", sin cifras de precisión sin estudio, sin "certificados" sin prueba | MVP | `legal-content-review`, `compliance-reviewer` |

## Lo que más importa en el MVP
1. **Texto del aviso al dueño** (ayuda a la decisión, no diagnóstico) aprobado por el veterinario.
2. **Datos mínimos** y política de privacidad antes de usar datos reales.
3. **Consentimientos separados**, sin casillas premarcadas y sin bloquear nunca la emergencia.
4. **Accesibilidad básica** (contraste, etiquetas, teclado) desde la primera pantalla.
5. **Registro de terceros** (Supabase) completado antes del piloto.

## Lo que puede esperar
Cookies y su banner (portal web) · reseñas (directorio) · reembolsos (pagos) · analítica.

## Preguntas abiertas
- País objetivo → define las leyes de protección de datos y de consumo aplicables.
- ¿La app guardará algo más que lo del triaje (por ejemplo ubicación del dueño)?
- ¿Habrá analítica de producto en el piloto?
- ¿Quién será responsable del tratamiento de datos: VetFlow o cada clínica?
