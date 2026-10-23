# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [Sin publicado]
### Añadido
- Estructura inicial de documentación (producto, requisitos, triaje clínico, diseño, arquitectura, calidad, gestión).

## [0.1.0] - 2026-10-23
### Añadido
- Épicas EPC-06 (Directorio y geolocalización de clínicas), EPC-07 (Gestión de citas y consultas programadas) y EPC-08 (Carnet de salud digital y perfil) con sus criterios de aceptación.
- Historias de usuario US-12 a US-20 con criterios de aceptación, escenarios y tareas.
- Tareas TAR-19 a TAR-29 en el backlog de gestión.
- Modelo de datos extendido: colecciones `clinics`, `appointments`, `health_records`, `pet_vaccines`, `pet_treatments`.
- Reglas de Firestore para las nuevas colecciones (`clinics`, `appointments`, `health_records`, `pet_vaccines`, `pet_treatments`).
- `AuthModule` integrado en `AppDependencies` (DI raíz).
- Pantallas de registro y login conectadas a `RegisterWithEmail`, `RegisterOwner` y `SignInWithEmail` reales.
- Ciclo de sesión con redirección por rol en el router (`/login`, `/register`, `/pets`).
- Campo `weightKg` en `Pet`, mapper, validación y formulario de registro de mascota.
- Casos de uso `CreateVisit` y `UpdateVisit`; cada visita se persiste en `visits/{visitId}`.
- Pantallas de triaje (síntomas, descarte, signos vitales, resultado, confirmación veterinaria) conectadas y guardando en la visita.
- Cola en tiempo real con `Stream` de Firestore (`watchPendingQueue`) y `QueueScreen` reactiva.
- Módulo de clínicas: modelo `Clinic`, `ClinicRepository`, `FirestoreClinicRepository`, caso de uso `ListClinics` y `ClinicModule`.
- `PetPhotoStorage` con rutas alineadas a `storage.rules` y validación de 5 MB / MIME.
- `isPersonal()` en reglas de Firestore lee el rol de `users/{uid}` (no de custom claims de JWT).
- Documentación de arquitectura de carpetas y modelo de datos actualizada con los nuevos dominios implementados.
