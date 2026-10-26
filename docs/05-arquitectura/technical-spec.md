# Especificación técnica

## Stack
| Capa | Tecnología | Nota |
|---|---|---|
| App móvil | Flutter | Android primero |
| Autenticación | Firebase Auth | Email/contraseña; teléfono a evaluar |
| Base de datos | Cloud Firestore | Persistencia offline activada |
| Archivos | Firebase Storage | Fotos |
| Lógica de triaje | Dart en la app (MVP) | Pasa a Cloud Functions si crece |
| Portal web | Por decidir | Ver [preguntas pendientes](../07-gestion/preguntas-pendientes.md) |

## Estructura de código
Clean + Hexagonal + Vertical Slicing (detalle en
[arquitectura-carpetas.md](arquitectura-carpetas.md)):

```
app/lib/
├── app/            conexiones (arranque + inyección en app/di/)
├── shared/         kernel común de dominio (Result, errores)
├── features/       un slice vertical por dominio
│   ├── auth/       domain/ (model, validation, port) + application/
│   ├── triage/     (dominio del triaje, sin código aún)
│   └── …
└── infrastructure/ adaptadores: firebase/ (driven) y presentation/ (UI)
```

Estado: solo `auth` implementado; `triage`, `pets` y `owners` tienen su
carpeta documentada, a la espera de sus historias.

## Principios técnicos
- El **motor de triaje no depende de la UI** y se prueba con pruebas unitarias.
- Reglas en un archivo versionado (`rulesVersion`).
- Toda escritura valida datos en el móvil **y** en reglas de Firestore.
- Modo offline: persistencia local + reenvío automático.

## Abiertas
Gestor de estado (Provider / Riverpod / Bloc) y navegación: decidir en el Paso 0 con un ADR.

## Más detalle
[firebase-modelo-db.md](firebase-modelo-db.md) · [seguridad-y-privacidad.md](seguridad-y-privacidad.md) · [adr/](adr/README.md)
