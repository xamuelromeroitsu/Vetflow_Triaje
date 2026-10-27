# Integración UI Login/Onboarding (Stitch Clinical Mint) con Backend VetFlow

Fecha: $(date -Iseconds)

## Objetivo
Adaptar las pantallas del módulo de login/onboarding extraídas de Stitch (design "Clinical Mint") a Flutter + Dart, modularizarlas siguiendo la arquitectura del proyecto (features/auth, shared/theme, app/router) e integrarlas con el backend Firebase/Auth + DI existente.

## Fuentes
- Descargas: 
  - `/home/edilver/Descargas/stitch_dogo_veterinary_triage_app_login_pantalla_1` (onboarding/welcome)
  - `/home/edilver/Descargas/stitch_dogo_veterinary_triage_app_login_pantalla_2` (login con switch dueño/personal)
- Design system: `DESIGN.md` (Clinical Mint - Inter, paleta, spacing, componentes)
- HTML mockups analizados: `code.html`

## Arquitectura del proyecto (base)
- Clean Architecture por features: `lib/features/*/{domain,application,presentation}`
- Infraestructura: `lib/infrastructure/firebase/*`
- DI: `lib/app/di/*`, `AppDependencies` (`lib/app/di/app_dependencies.dart`)
- Router: `lib/app/router/app_router.dart` (GoRouter)
- Auth: `AuthRepository` (puerto) + `FirebaseAuthRepository` + `SignInWithEmail`, `RegisterWithEmail`, `SignOut`
- UserProfile/Owner: `UserProfileRepositoryFirestore`, `RegisterOwner` 
- Tema existente: `lib/shared/presentation/theme/app_theme.dart`

## Cambios realizados

### 1) Tema Clinical Mint
**Archivo:** `lib/shared/presentation/theme/app_theme_clinical_mint.dart`
- Colores basados en `DESIGN.md` (primaryContainer `#32C798`, surfaces mint/slate, error `#BA1A1A`, etc.)
- Tipografía Inter con jerarquía (headlineLarge/Medium/Small, body/label)
- `InputDecorationTheme` con fondos suaves (`#F4F9F6`)
- Integrado en `MaterialApp.router` via `clinicalMintTheme`

### 2) Componentes modulares (auth)
**Directorio:** `lib/features/auth/presentation/widgets/`
- `auth_widgets.dart`:
  - `AuthHeader` (logo DOGO + "Veterinaria 24/7" + indicador "Red Activa" style)
  - `RoleSwitcher` (Dueño de Mascota / Personal Clínico) - refleja comportamiento del HTML
  - `AuthTextField` (label + campo con prefijo/sufijo)
  - `PrimaryActionButton` (botón primario con loading)

### 3) Pantallas adaptadas a Flutter
**Directorio:** `lib/features/auth/presentation/screens/`
- `onboarding_welcome_clinical_mint.dart` (ruta `/`)
  - Header con logo/emergencia + badge "Red Activa"
  - Imagen hero (Unsplash como placeholder, reemplazable por asset)
  - CTAs: "Iniciar Sesión" -> `/login`, "Crear Cuenta / Registrarse" -> `/register`, "Continuar como invitado / Ver clínicas cercanas" -> `/queue`
  - Banner de emergencia con estilo Clinical Mint
- `login_screen_clinical_mint.dart` (ruta `/login`)
  - Card "Atención y Triaje 24/7"
  - RoleSwitcher (Dueño/Personal) con hint contextual
  - Formulario email/contraseña con validación (mínimo 6 chars)
  - Toggle visibilidad contraseña
  - Integración con `SignInWithEmail` desde `AppDependencies.authModule`
  - Navegación a `/pets` tras login exitoso
  - Botones sociales (Google/Apple) UI-only (hooks para futuro)
  - Link a registro `/register`

### 4) Integración con router/app
**Archivos modificados:**
- `lib/app/router/app_router.dart`: rutas `/` y `/login` apuntan a las nuevas pantallas Clinical Mint. Se mantienen rutas existentes (`/register`, `/pets`, `/triage/*`, `/queue`, `/emergency`).
- `lib/app/app.dart`: usa `clinicalMintTheme` en lugar de `appTheme` anterior.

## Integración con backend (cómo se conecta)
- DI: `main.appDependencies.authModule.signInWithEmail` usado directamente (patrón ya existente en `login_screen.dart`)
- Flujo auth: `SignInWithEmail` llama a `AuthRepository` (Firebase) y opcionalmente valida perfil vía `UserProfileRepository` según implementación
- Post-login: redirección a `/pets` (igual que lógica anterior). Redirect global en router sigue activo basado en `FirebaseAuth.instance.currentUser`
- Registro: `/register` sigue usando `RegisterScreen` existente (con `RegisterWithEmail` + `RegisterOwner`)

## Recursos/tecnologías usadas
- **Flutter** (Material 3) - UI
- **Dart** - lógica
- **go_router** `^14.2.0` - navegación
- **firebase_core/auth/firestore/storage** - backend existente
- **Google Fonts Inter** (referenciado en diseños; tema usa familia Inter)
- **Material Symbols Outlined** (estilo de iconos en mockups)
- **Unsplash** - placeholders de imágenes (reemplazar por assets locales)

## Modularidad
- Widgets reutilizables en `features/auth/presentation/widgets/`
- Pantallas en `features/auth/presentation/screens/` (separadas de pantallas legacy)
- Tema centralizado en `shared/presentation/theme/`
- Sin romper capas domain/application/infrastructure/di
- Fácil toggle entre pantallas legacy/nuevas editando router

## Notas de implementación
- Las pantallas nuevas son **UI-first** pero conectadas a casos de uso reales (`SignInWithEmail`)
- Validaciones mantienen lógica existente (email regex, password >=6)
- El switch "Dueño/Personal" cambia copy/placeholder; lógica de roles se maneja en backend (Firestore `users/{uid}`)
- Emergencia banner es UI (llamar número pendiente de integrar con `url_launcher` si se desea)

## Próximos pasos sugeridos
1. Crear assets locales (logo, ilustraciones) y reemplazar URLs Unsplash
2. Migrar completamente `LoginScreen`/`WelcomeScreen` legacy o eliminar
3. Implementar Google/Apple sign-in si aplica
4. Aplicar mismo estilo a `RegisterScreen` (pantalla "crear cuenta")
5. Añadir fuentes Inter en `pubspec.yaml` si no hay
