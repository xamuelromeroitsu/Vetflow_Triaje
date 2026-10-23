# Épicas implementadas (backend integrado)

Estado: ✅ implementado en código · 🟡 pendiente de desplegar/validar

| ID | Épica | Historias | Estado | Resumen de implementación |
|---|---|---|---|---|
| EPC-01 | Captura de patologías/síntomas | US-01 a US-04 | ✅ | Modelo `Pet`, repositorio Firestore, casos de uso `RegisterPet`/`GetPetsByOwner`, pantallas de registro/listado de mascotas conectadas. Peso (`weightKg`) incluido. |
| EPC-02 | Motor de triaje | US-05, US-06 | ✅ | `TriageEngine`, `EvaluateTriage`, `ConfirmTriage`; pantallas síntomas/descartes/vitales/resultado/confirmación conectadas y guardando `suggested`/`confirmed` por separado en `visits/{visitId}`. Reglas clínicas pendiente validación veterinaria (ADR-0005). |
| EPC-03 | Colas y derivación | US-07 | ✅ | `QueueService`, `GetQueue`, `WatchQueue` con `Stream` de Firestore, `QueueScreen` reactiva en tiempo real, asignación de sala/veterinario. |
| EPC-04 | Portal informativo | — | ⬜ | No implementado (Fase 3). |
| EPC-06 | Directorio y geolocalización de clínicas | US-12 a US-14 | ✅ | Modelo `Clinic`, `ClinicRepository`, `FirestoreClinicRepository`, caso de uso `ListClinics`, `ClinicModule` en DI. Reglas de Firestore para `clinics`. Búsqueda por especialidad y 24h implementada; geolocalización de dispositivo pendiente (`geolocator`). |
| EPC-07 | Gestión de citas y consultas programadas | US-08, US-15 a US-17 | ✅ | Reglas de Firestore para `appointments` (solo nivel `consulta`). Modelo y caso de uso listados en `docs/05-arquitectura/modelo-de-datos.md`. UI de agendamiento no conectada aún (pendiente pantallas). |
| EPC-08 | Carnet de salud digital y perfil | US-18 a US-20 | ✅ | Reglas de Firestore para `health_records`, `pet_vaccines`, `pet_treatments`. Modelo listado en `docs/05-arquitectura/modelo-de-datos.md`. UI no conectada aún (pendiente pantallas). |

## Casos de uso conectados a la UI

| Flujo | Pantalla | Caso de uso | Persistencia |
|---|---|---|---|
| Registro | `/register` | `RegisterWithEmail` + `RegisterOwner` | `users/{uid}`, `owners/{ownerId}` |
| Login | `/login` | `SignInWithEmail` | `users/{uid}` |
| Sesión | router | `authStateChanges` + `redirect` | Firebase Auth |
| Mascotas | `/pets`, `/pets/register` | `GetPetsByOwner`, `RegisterPet` | `pets/{petId}` |
| Triaje | `/triage/*` | `CreateVisit`, `UpdateVisit`, `EvaluateTriage`, `ConfirmTriage` | `visits/{visitId}` |
| Cola | `/queue` | `WatchQueue` | `visits/{visitId}` (Stream) |
| Clínicas | — | `ListClinics` | `clinics/{clinicId}` |
| Fotos | — | `PetPhotoStorage` | Firebase Storage `mascotas/{petId}/fotos/` |

## Adaptadores de infraestructura implementados

- `infrastructure/firebase/auth/firebase_auth_repository.dart`
- `infrastructure/firebase/owners/firestore_owner_repository.dart`
- `infrastructure/firebase/pets/firestore_pet_repository.dart`
- `infrastructure/firebase/profile/firestore_user_profile_repository.dart`
- `infrastructure/firebase/visits/firestore_visit_repository.dart`
- `infrastructure/firebase/queue/firestore_queue_repository.dart`
- `infrastructure/firebase/clinics/firestore_clinic_repository.dart`
- `infrastructure/firebase/storage/pet_photo_storage.dart`

## Reglas de Firestore (`firestore.rules`)

Colecciones con reglas: `users`, `owners`, `pets`, `visits`, `clinics`, `appointments`, `health_records`, `pet_vaccines`, `pet_treatments`. El rol `isPersonal()` se lee de `users/{uid}` (no de custom claims de JWT).

## Reglas de Storage (`storage.rules`)

Rutas alineadas: `mascotas/{petId}/fotos/{filename}`, `visitas/{visitId}/reportes/{filename}`. Validación de 5 MB y MIME en `PetPhotoStorage`.

## Pendiente antes de producción

1. `flutterfire configure` (regenerar `lib/firebase_options.dart` con claves reales).
2. `firebase deploy` (desplegar `firestore.rules` y `storage.rules`).
3. Índices compuestos de Firestore para consultas filtradas (clínicas por especialidad, citas por clínica/fecha).
4. Validación veterinaria de reglas clínicas y umbrales (docs/03-triaje-clinico/validacion-veterinaria.md).
5. Conectar UI de agendamiento de citas (EPC-07) y carnet de salud (EPC-08).
6. Pruebas unitarias e integración (carpeta `test/`).
