# Especificación técnica

## Stack
| Capa | Tecnología | Nota |
|---|---|---|
| App móvil | Flutter | Android primero |
| Autenticación | Supabase Auth | Email/contraseña; teléfono a evaluar |
| Base de datos | Supabase Postgres | RLS; sincronización remota |
| Archivos | Supabase Storage | Bucket privado para fotos |
| Lógica de triaje | Dart en la app (MVP) | Evaluar Supabase Edge Functions si crece |
| Portal web | Por decidir | Ver [preguntas pendientes](../07-gestion/preguntas-pendientes.md) |

## Estructura de código
Clean + Hexagonal + Vertical Slicing (detalle en
[arquitectura-carpetas.md](arquitectura-carpetas.md)):

```
vetflow_triaje/lib/
├── app/            conexiones (arranque + inyección en app/di/)
├── shared/         kernel común de dominio (Result, errores)
├── features/       un slice vertical por dominio
│   ├── auth/       domain/ (model, validation, port) + application/
│   ├── triage/     (dominio del triaje, sin código aún)
│   └── …
└── infrastructure/ adaptadores: supabase/ (driven) y presentation/ (UI)
```

Estado: auth, perfiles, dueños, mascotas, visitas, cola, clínicas y fotos tienen
adaptadores Supabase. Las reglas clínicas siguen pendientes de validación
veterinaria.

## Principios técnicos
- El **motor de triaje no depende de la UI** y se prueba con pruebas unitarias.
- Reglas en un archivo versionado (`rulesVersion`).
- Toda escritura valida datos en el móvil **y** en políticas RLS de Postgres y
  Storage.
- La persistencia offline y la sincronización diferida deben resolverse en una
  capa local; Supabase no sustituye automáticamente la caché offline del
  backend anterior.

## Abiertas
Gestor de estado (Provider / Riverpod / Bloc) y navegación: decidir en el Paso 0 con un ADR.

## Más detalle
[modelo-de-datos.md](modelo-de-datos.md) · [seguridad-y-privacidad.md](seguridad-y-privacidad.md) · [adr/](adr/README.md)
