# EPC-03 — Gestión de Colas y Derivación

Implementación del backend para la epica **EPC-03**: ordenar los casos por
prioridad en tiempo real, asignar sala o veterinario y mostrar al dueño su turno.

---

## Regla absoluta

La carpeta `integrador/` se ignora por completo. Todo el "backend" vive dentro de
`vetflow_triaje/` como código Dart sobre Firebase (Auth, Firestore, Storage),
sin servidor propio.

---

## Cómo se hizo

### 1. Dominio `queue/` — lógica pura de negocio

Se crearon los siguientes archivos bajo `lib/features/queue/`:

| Archivo | Propósito |
|---------|-----------|
| `domain/model/queue_entry.dart` | Entrada de cola con `visitId`, `petId`, `ownerId`, `triageLevel`, `status`, `assignedRoom`, `assignedVeterinarian`, `position`, fechas. |
| `domain/model/queue_status.dart` | Enum `QueueStatus` (pendiente, en_atencion, atendido, cancelado) con etiqueta legible. |
| `domain/port/queue_repository.dart` | Puerto `QueueRepository`: crear, buscar, obtener cola pendiente, actualizar, asignar sala/veterinario. |
| `domain/service/queue_service.dart` | Servicio de ordenación: ordena por prioridad (nivel de triaje descendente) y fecha de creación ascendente. Asigna posiciones numeradas. |
| `application/use_case/get_queue.dart` | Caso de uso: obtener la cola ordenada por prioridad. |
| `application/use_case/assign_room_veterinarian.dart` | Caso de uso: asignar sala y veterinario a una entrada de cola. |
| `application/use_case/next_turn.dart` | Caso de uso: atender el siguiente turno (marca como `en_atencion`). |

### 2. Ordenación de la cola

La cola se ordena por:
1. **Nivel de triaje** (mayor gravedad primero: emergencia > urgencia > consulta).
2. **Fecha de creación** (más antiguo primero dentro del mismo nivel).

Esto garantiza que los casos críticos sean atendidos primero, respetando la
regla de que el triaje nunca baja de nivel.

---

## Qué utilicé

- **Arquitectura:** Clean + Hexagonal + Vertical Slicing
  (`docs/05-arquitectura/arquitectura-carpetas.md`).
- **Patrones:** Puerto/Repositorio, Domain Service (`QueueService`),
  `Result<T>` del kernel compartido.
- **Tecnología:** Dart puro en dominio; adaptador de Firestore para persistencia
  en `visits/{visitId}` (reusa la colección de visitas con campos de cola).
- **Dependencias:** `cloud_firestore` (ya en `pubspec.yaml`).

---

## Qué cambió

### Archivos creados

```
lib/features/queue/domain/model/queue_entry.dart
lib/features/queue/domain/model/queue_status.dart
lib/features/queue/domain/port/queue_repository.dart
lib/features/queue/domain/service/queue_service.dart
lib/features/queue/application/use_case/get_queue.dart
lib/features/queue/application/use_case/assign_room_veterinarian.dart
lib/features/queue/application/use_case/next_turn.dart
lib/infrastructure/firebase/queue/firestore_queue_repository.dart
lib/infrastructure/firebase/queue/queue_mapper.dart
lib/app/di/queue_dependencies.dart
```

### Archivos modificados

- `lib/app/di/app_dependencies.dart` — se agregó `QueueModule` al módulo raíz.
- `vetflow_triaje/firestore.rules` — reglas para `visits` incluyen campos de
  cola (`status`, `assignedRoom`, `assignedVeterinarian`, `position`).

---

## Estado nuevo del proyecto

- ✅ **EPC-01** (Captura y Registro de Mascotas y Síntomas): implementada en
  rama `backend-E1`.
- ✅ **EPC-02** (Motor de Clasificación de Riesgo / Triaje): implementada en
  rama `backend-E2-E3` (pendiente validación veterinaria).
- ✅ **EPC-03** (Gestión de Colas y Derivación): implementada en
  rama `backend-E2-E3`. La cola ordena por prioridad de triaje y permite asignar
  sala y veterinario.

### Módulo raíz (`AppDependencies`)

Ahora agrupa cinco módulos: `OwnerModule`, `PetModule`, `VisitModule`,
`TriageModule` y `QueueModule`.

---

## Pendientes críticos (no asumir)

- Veterinario asesor que valide las reglas clínicas (`docs/07-gestion/preguntas-pendientes.md` #2).
- Rangos de signos vitales validados por veterinario (#6).
- País objetivo y normativa de protección de datos (#1, #11).
- Pantalla UI para mostrar el turno al dueño (pendiente de implementación móvil).
