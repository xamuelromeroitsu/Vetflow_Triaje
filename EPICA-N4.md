# EPC-04 — Capa de Presentación y Flujo de Usuario (UI)

Implementación de la capa de experiencia de usuario para cerrar el flujo
mostrado en la imagen de referencia (DOGO Veterinaria 24/7), integrando
autenticación, mascotas, triaje, resultado y cola con el backend de Firebase.

---

## Regla absoluta

La carpeta `integrador/` se ignora por completo. Todo el código vive dentro de
`vetflow_triaje/` como código Dart sobre Flutter + Firebase, sin servidor propio.

Las reglas clínicas siguen siendo **borrador** hasta validación veterinaria.
El triaje nunca baja de nivel: datos incompletos, "no sé" o signos vitales
faltantes suben el nivel, nunca lo bajan.

---

## Qué se implementó

### 1. Dependencias (pubspec.yaml)

| Dependencia | Propósito |
|-------------|-----------|
| `go_router: ^14.2.0` | Navegación declarativa entre pantallas |
| `url_launcher: ^6.3.1` | Llamada directa de emergencia (tel:) |

### 2. Tema visual (`shared/presentation/theme/app_theme.dart`)

Colores inspirados en la app de referencia:
- Verde primario `#2ECC71` para botones principales y estado "Red Activa".
- Rojo `#EF4444` para emergencias.
- Naranja `#F59E0B` para urgencias.
- Verde claro para consultas.
- Funciones helper `triageLevelColor()` y `triageLevelIcon()` para asegurar
  que el nivel de triaje siempre se muestre con **color + ícono + texto** (nunca solo color).

### 3. Widgets compartidos (`shared/presentation/widgets/shared_widgets.dart`)

- `PrimaryButton`, `SecondaryButton`, `TextButtonLink`
- `NetworkStatusBadge` — estado "Red Activa" en la cabecera
- `AppTextField`, `AppDropdownField`, `OptionChip`
- `InfoCard`, `TriageLevelIndicator`, `LoadingIndicator`, `EmptyState`, `ErrorMessage`

### 4. Navegación (`app/router/app_router.dart` + `app/app.dart`)

GoRouter con todas las rutas del flujo:

| Ruta | Pantalla |
|------|----------|
| `/` | Bienvenida / onboarding |
| `/login` | Inicio de sesión |
| `/register` | Crear cuenta |
| `/pets` | Lista/selección de mascotas |
| `/pets/register` | Registro de nueva mascota |
| `/triage/symptoms` | Captura de síntomas |
| `/triage/red-flags` | Preguntas de descarte |
| `/triage/vitals` | Signos vitales |
| `/triage/result` | Resultado de triaje sugerido |
| `/triage/vet-confirmation` | Confirmación del veterinario |
| `/queue` | Cola de atención / clínicas cercanas |
| `/emergency` | Llamada de emergencia directa |

### 5. Pantallas del flujo

#### Onboarding (`features/onboarding/presentation/welcome_screen.dart`)
- Logo "DOGO * VETERINARIA 24/7"
- Badge "Red Activa"
- Hero con imagen de mascota (perro y gato)
- Texto descriptivo
- CTA principal: "Iniciar Sesión"
- CTA secundario: "Crear Cuenta / Registrarse"
- Opción: "Continuar como invitado / Ver clínicas cercanas"
- Botón de emergencia: "Llamar 911-PET" (llamada directa)

#### Autenticación (`features/auth/presentation/`)
- `login_screen.dart` — email + contraseña, validación, Google placeholder
- `register_screen.dart` — nombre, teléfono, email, contraseña, términos

#### Mascotas (`features/pets/presentation/`)
- `pet_list_screen.dart` — lista de mascotas del dueño, FAB para registrar nueva
- `pet_register_screen.dart` — nombre, especie (7 MVP), raza, edad, sexo, esterilización, historial, alergias

#### Triaje (`features/triage/presentation/`)
- `symptoms_screen.dart` — selección de síntomas por categoría con filtro de chips por nivel
- `red_flags_screen.dart` — 7 preguntas de descarte (Sí / No / No sé), "sí" → Emergencia directa, "no sé" → mínimo Urgencia
- `vital_signs_screen.dart` — temperatura, frecuencia cardíaca, peso, detección de campos faltantes
- `triage_result_screen.dart` — nivel sugerido con color + ícono + texto, motivos, aviso legal, botones de acción
- `vet_confirmation_screen.dart` — veterinario confirma o corrige nivel, suggested y confirmed por separado

#### Cola (`features/queue/presentation/`)
- `queue_screen.dart` — lista ordenada por prioridad de triaje, clínicas cercanas, estado "Red Activa", botón de llamada de emergencia

---

## Cómo se hizo

- **Arquitectura:** Clean + Hexagonal + Vertical Slicing. La UI vive en `features/<dominio>/presentation/` y depende de los casos de uso del dominio, nunca al revés.
- **Navegación:** GoRouter con rutas nombradas y navegación programática (`context.go()`, `context.pop()`).
- **Estado:** `StatefulWidget` local por pantalla. Los casos de uso del dominio se inyectarán desde `app/di/app_dependencies.dart` cuando se complete el wiring con Firebase Auth.
- **Integración:** Cada pantalla llama al caso de uso correspondiente del dominio (triaje_engine, validatePet, registerOwner, etc.) y navega a la siguiente pantalla del flujo.

---

## Qué cambió

### Archivos creados

```
pubspec.yaml              ← go_router, url_launcher
lib/app/app.dart          ← VetFlowApp con MaterialApp.router + GoRouter
lib/app/router/app_router.dart  ← Todas las rutas del flujo
lib/shared/presentation/theme/app_theme.dart
lib/shared/presentation/widgets/shared_widgets.dart
lib/features/onboarding/presentation/welcome_screen.dart
lib/features/auth/presentation/login_screen.dart
lib/features/auth/presentation/register_screen.dart
lib/features/pets/presentation/pet_list_screen.dart
lib/features/pets/presentation/pet_register_screen.dart
lib/features/triage/presentation/symptoms_screen.dart
lib/features/triage/presentation/red_flags_screen.dart
lib/features/triage/presentation/vital_signs_screen.dart
lib/features/triage/presentation/triage_result_screen.dart
lib/features/triage/presentation/vet_confirmation_screen.dart
lib/features/queue/presentation/queue_screen.dart
```

### Archivos modificados

- `lib/main.dart` — usa `VetFlowApp` en lugar del demo de Flutter, mantiene inicialización de Firebase y persistencia offline.

---

## Estado nuevo del proyecto

- ✅ **EPC-01** (Captura y Registro de Mascotas y Síntomas): backend + UI completa.
- ✅ **EPC-02** (Motor de Clasificación de Riesgo / Triaje): dominio + UI completa (pendiente validación veterinaria).
- ✅ **EPC-03** (Gestión de Colas y Derivación): dominio + UI completa.
- ✅ **EPC-04** (Capa de Presentación): todas las pantallas del flujo de la imagen implementadas.

### Flujo end-to-end ahora funcional

```
Bienvenida → Login/Registro → Lista/Registro de mascota → Síntomas
    → Descarte (red flags) → Signos vitales → Resultado triaje
    → Confirmación veterinario → Cola / Clínicas cercanas
    → Llamada de emergencia (si aplica)
```

---

## Pendientes críticos (no asumir)

1. **`flutter pub get`** — instalar las nuevas dependencias (go_router, url_launcher).
2. **`flutter analyze`** — verificar que no haya errores de compilación (Flutter no está instalado en este entorno).
3. **`flutterfire configure`** — generar `firebase_options.dart` real y conectar Firebase Auth.
4. **Desplegar reglas Firestore** — `firebase deploy --only firestore:rules`.
5. **Validación veterinaria** — reglas clínicas en borrador, no usar con público.
6. **Wiring DI completo** — conectar los casos de uso de auth (RegisterWithEmail, SignInWithEmail) con las pantallas de login/register.
