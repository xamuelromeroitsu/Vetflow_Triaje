# Dueños (dominio `owners`)

Carpeta reservada para el dominio de dueños (ADR-0002: dueños fuera de la
clínica). **Sin código todavía.**

Cuando entre (con US-01), la estructura será:

```
domain/
├── model/       Owner
├── validation/  owner_validation.dart
└── port/        OwnerRepository
application/use_case/  CreateOwner
```

Adaptador en `infrastructure/persistence/owners/` (repositorio + mapper).
Pendiente: identificar al dueño por teléfono o por cédula
(`docs/07-gestion/preguntas-pendientes.md`, pregunta 4).
