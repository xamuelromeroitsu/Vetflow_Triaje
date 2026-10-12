# Mascotas (dominio `pets`)

Carpeta reservada para el dominio de mascotas (US-01). **Sin código todavía.**

Cuando entre la historia (TAR-04/TAR-05), la estructura será:

```
domain/
├── model/       Pet (+ Species cuando el MVP defina las especies)
├── validation/  pet_validation.dart (espejo de firestore.rules)
└── port/        PetRepository
application/use_case/  CreatePet, ListPetsByOwner
```

El adaptador de Firestore vivirá en `infrastructure/persistence/pets/`
(repositorio + mapper), inyectado desde `app/di/`. Campos obligatorios:
nombre, especie, raza, edad (`docs/02-requisitos/historias/EPC-01-captura.md`).
