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

## Estructura de código prevista
```
app/lib/
├── core/           tema, constantes, utilidades
├── features/
│   ├── pets/
│   ├── symptoms/
│   ├── vitals/
│   ├── photos/
│   ├── triage/     reglas + motor (sin dependencias de UI)
│   └── queue/
└── main.dart
```

## Principios técnicos
- El **motor de triaje no depende de la UI** y se prueba con pruebas unitarias.
- Reglas en un archivo versionado (`rulesVersion`).
- Toda escritura valida datos en el móvil **y** en reglas de Firestore.
- Modo offline: persistencia local + reenvío automático.

## Abiertas
Gestor de estado (Provider / Riverpod / Bloc) y navegación: decidir en el Paso 0 con un ADR.

## Más detalle
[modelo-de-datos.md](modelo-de-datos.md) · [seguridad-y-privacidad.md](seguridad-y-privacidad.md) · [adr/](adr/README.md)
