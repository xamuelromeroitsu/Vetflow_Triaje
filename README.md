# 🐾 VetFlow Triaje

App móvil (Flutter + Supabase) donde el dueño de una mascota describe los síntomas y el sistema **sugiere** un nivel de prioridad: 🔴 Emergencia · 🟠 Urgencia · 🟢 Consulta. El veterinario confirma. A futuro, base de una red de clínicas veterinarias.

> **Estado:** Aplicación Flutter en desarrollo; migración de backend a Supabase implementada. Para configurar y ejecutar la app, consulta [la guía de migración](documentacion-migracion-supabase.md).

## Empieza aquí
| Si quieres… | Lee |
|---|---|
| Entender el proyecto en 5 minutos | [docs/01-producto/product-brief.md](docs/01-producto/product-brief.md) |
| Saber qué se construye primero | [docs/01-producto/mvp-scope.md](docs/01-producto/mvp-scope.md) |
| Ver el orden de trabajo | [docs/07-gestion/planificacion.md](docs/07-gestion/planificacion.md) |
| Ver todos los documentos | [docs/README.md](docs/README.md) |
| Colaborar | [CONTRIBUTING.md](CONTRIBUTING.md) |

## Stack previsto
Flutter · Supabase Auth · PostgreSQL con RLS · Supabase Storage.

## Estructura del repo
```
Vetflow_Triaje/
├── README.md · CONTRIBUTING.md · CHANGELOG.md
├── docs/        ← documentación previa al código
└── vetflow_triaje/ ← aplicación Flutter y migraciones de Supabase
```

## ⚠️ Aviso
VetFlow es una herramienta de **ayuda a la decisión**. No diagnostica ni sustituye la evaluación de un veterinario.
