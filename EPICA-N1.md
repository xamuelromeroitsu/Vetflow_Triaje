Plan de implementación del backend para **EPC-01** (Captura y Registro de Mascotas y Síntomas).

**Regla absoluta:** la carpeta `integrador/` se ignora por completo. Todo el "backend" vive dentro de `vetflow_triaje/` como código Dart sobre Firebase (Auth, Firestore, Storage), sin servidor propio.

---

## Arquitectura objetivo (respetando `docs/05-arquitectura/arquitectura-carpetas.md`)

```
lib/
├── app/
│   └── di/                 ← composición (módulos de inyección)
├── shared/
│   ├── domain/             ← kernel (Result, errores) ✅ existe
│   └── port/               ← puertos transversales (Clock, IdGenerator, Logger) ❌ falta
├── features/
│   ├── auth/               ✅ implementado
│   ├── owners/             ← dominio dueño ❌ solo README
│   ├── pets/               ← dominio mascota ❌ solo README
│   └── triage/             ← síntomas / signos vitales ❌ solo README
└── infrastructure/
    └── firebase/
        ├── auth/           ✅ existe
        ├── profile/        ✅ existe
        ├── owners/         ❌ falta
        ├── pets/           ❌ falta
        ├── visits/         ❌ falta
        └── storage/        ❌ falta (fotos)
```

---

## 1. Shared kernel — puertos transversales (bloqueante para tests deterministas)

Según ADR-0006 Fase A, el dominio no debe llamar `DateTime.now()` ni generar UUIDs directamente.

**Crear:**
- `lib/shared/port/clock.dart` — interfaz `Clock` con `now(): DateTime`
- `lib/shared/port/id_generator.dart` — interfaz `IdGenerator` con `generate(): String`
- `lib/shared/port/logger.dart` — interfaz `Logger` (opcional, para logs)

---

## 2. Dominio `owners/` — registro del dueño

El dueño está vinculado al usuario autenticado (`users/{uid}` de Firebase Auth).

**Crear:**
- `lib/features/owners/domain/model/owner.dart` — entidad `Owner` (id, name, phone, email, ownerId/uid, createdAt)
- `lib/features/owners/domain/port/owner_repository.dart` — puerto `OwnerRepository` (create, findById, findByPhone, update)
- `lib/features/owners/domain/validation/owner_validation.dart` — reglas de validación local (teléfono, email, nombre obligatorio)
- `lib/features/owners/application/use_case/register_owner.dart` — caso de uso `RegisterOwner`
- `lib/features/owners/application/use_case/update_owner.dart` — caso de uso `UpdateOwner`

---

## 3. Dominio `pets/` — registro de mascota

**Crear:**
- `lib/features/pets/domain/model/pet.dart` — entidad `Pet` (id, ownerId, name, species, breed, ageMonths, sex, neutered, history, allergies, createdAt, updatedAt)
- `lib/features/pets/domain/port/pet_repository.dart` — puerto `PetRepository` (create, findById, findByOwnerId, update)
- `lib/features/pets/domain/validation/pet_validation.dart` — validaciones (especies MVP: perro, gato, hurón, conejo, ave, roedor, reptil; edad en meses obligatoria)
- `lib/features/pets/application/use_case/register_pet.dart` — caso de uso `RegisterPet`
- `lib/features/pets/application/use_case/update_pet.dart` — caso de uso `UpdatePet`

---

## 4. Dominio `triage/` — síntomas y signos vitales (parte de EPC-01)

El motor de reglas de triaje no se escribe hasta validación veterinaria, pero EPC-01 incluye capturar síntomas y signos vitales. Se guarda en `visits/{visitId}`.

**Crear:**
- `lib/features/triage/domain/model/symptom_entry.dart` — value object de síntoma (category, items, notes, since)
- `lib/features/triage/domain/model/vital_signs.dart` — value object de signos vitales (tempC, weightKg, heartRate, flags) con rangos por especie (pendiente validación vet)
- `lib/features/triage/domain/port/` — si el dominio necesita persistir intermedio

---

## 5. Infraestructura Firebase — adaptadores de persistencia

**Crear:**
- `lib/infrastructure/firebase/owners/firestore_owner_repository.dart` — implementa `OwnerRepository` contra `owners/{ownerId}`
- `lib/infrastructure/firebase/owners/owner_mapper.dart` — traductor Firestore ↔ `Owner`
- `lib/infrastructure/firebase/pets/firestore_pet_repository.dart` — implementa `PetRepository` contra `pets/{petId}`
- `lib/infrastructure/firebase/pets/pet_mapper.dart` — traductor Firestore ↔ `Pet`
- `lib/infrastructure/firebase/visits/firestore_visit_repository.dart` — implementa puerto de visita contra `visits/{visitId}` (guarda síntomas, vitales, fotos)
- `lib/infrastructure/firebase/visits/visit_mapper.dart` — traductor Firestore ↔ `Visit`
- `lib/infrastructure/firebase/storage/pet_photo_storage.dart` — subida de fotos a Firebase Storage (rutas por usuario, ≤5 MB, JPG/PNG)

---

## 6. Composición / Inyección de dependencias

**Crear:**
- `lib/app/di/owner_dependencies.dart` — `OwnerModule`
- `lib/app/di/pet_dependencies.dart` — `PetModule`
- `lib/app/di/visit_dependencies.dart` — `VisitModule`
- `lib/app/di/app_dependencies.dart` — módulo raíz que agrega `AuthModule`, `OwnerModule`, `PetModule`

**Modificar:**
- `lib/app/di/auth_dependencies.dart` — si `RegisterOwner` depende del `AuthRepository`

---

## 7. Reglas de seguridad Firestore (`firestore.rules`)

**Modificar:** reemplazar placeholders y agregar reglas reales:

| Colección | Lectura | Escritura |
|---|---|---|
| `users/{uid}` | usuario autenticado | creación en registro, update propio perfil |
| `owners/{ownerId}` | dueño autenticado o personal de clínica | dueño crea su perfil (`ownerId == auth.uid`) |
| `pets/{petId}` | dueño o personal | creación si `ownerId` pertenece al usuario autenticado |
| `visits/{visitId}` | dueño o personal | creación por dueño o personal |
| `{document=**}` | denegar por defecto | denegar por defecto |

Validar tipos y campos obligatorios en `create`/`update` (no solo en la app).

---

## 8. Offline-first (requisito de EPC-01)

**Modificar:**
- `lib/main.dart` — inicializar `FirebaseFirestore.instance` con `PersistenceEnabled` (offline) y configurar `FirebaseApp` antes de `runApp`.

---

## Archivos a CREAR (lista consolidada)

```
lib/shared/port/clock.dart
lib/shared/port/id_generator.dart
lib/shared/port/logger.dart

lib/features/owners/domain/model/owner.dart
lib/features/owners/domain/port/owner_repository.dart
lib/features/owners/domain/validation/owner_validation.dart
lib/features/owners/application/use_case/register_owner.dart
lib/features/owners/application/use_case/update_owner.dart

lib/features/pets/domain/model/pet.dart
lib/features/pets/domain/port/pet_repository.dart
lib/features/pets/domain/validation/pet_validation.dart
lib/features/pets/application/use_case/register_pet.dart
lib/features/pets/application/use_case/update_pet.dart

lib/features/triage/domain/model/symptom_entry.dart
lib/features/triage/domain/model/vital_signs.dart

lib/infrastructure/firebase/owners/firestore_owner_repository.dart
lib/infrastructure/firebase/owners/owner_mapper.dart
lib/infrastructure/firebase/pets/firestore_pet_repository.dart
lib/infrastructure/firebase/pets/pet_mapper.dart
lib/infrastructure/firebase/visits/firestore_visit_repository.dart
lib/infrastructure/firebase/visits/visit_mapper.dart
lib/infrastructure/firebase/storage/pet_photo_storage.dart

lib/app/di/owner_dependencies.dart
lib/app/di/pet_dependencies.dart
lib/app/di/visit_dependencies.dart
lib/app/di/app_dependencies.dart
```

## Archivos a MODIFICAR (lista consolidada)

```
lib/firestore.rules          ← reglas reales para owners, pets, visits + deny by default
lib/main.dart                ← Firestore offline persistence + DI wiring
lib/app/di/auth_dependencies.dart  ← ajuste si RegisterOwner usa AuthRepository
lib/pubspec.yaml             ← solo si falta alguna dependencia (ej. uuid, firebase_storage ya está)
```

---

## Orden sugerido de implementación

1. **Shared kernel** (`shared/port/*`) — tests deterministas sin `DateTime.now()` directo.
2. **Dominio owners + pets** (model, port, validation, use_case) — lógica pura, testeable sin Firebase.
3. **Infraestructura Firestore** (adaptadores + mappers) — conectar con `owners/{ownerId}`, `pets/{petId}`, `visits/{visitId}`.
4. **Storage** — fotos de mascota.
5. **DI modules** (`app/di/*`) — componer adaptadores y casos de uso.
6. **Reglas Firestore** (`firestore.rules`) — seguridad obligatoria antes de desplegar.
7. **Offline** — configurar persistencia en Firestore al arranque (`main.dart`).

---

## Preguntas abiertas antes de implementar

1. **¿Quién puede crear mascotas?** ¿Solo el dueño autenticado (`auth.uid == ownerId`) o también personal de recepción/veterinario (`personal`)?
2. **¿Dueño identificado por `auth.uid` o por cédula/teléfono?** (pregunta pendiente #4 en `docs/07-gestion/preguntas-pendientes.md`)
3. **¿Dónde se guardan síntomas y signos vitales en esta fase?** ¿Directo en `visits/{visitId}` o hay una colección intermedia?
4. **¿Usar paquete `uuid` o generar IDs en el cliente?** (para `IdGenerator` en `shared/port/`)

¿Quieres que detalle algún archivo en particular (modelo de `Pet`, reglas de Firestore, DI module) antes de pasar a implementar?