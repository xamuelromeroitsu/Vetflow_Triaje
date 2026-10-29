# Arquitectura de carpetas

VetFlow Triaje usa una combinación de **Clean Architecture** (reglas de
dependencia) + **Arquitectura Hexagonal** (puertos y adaptadores) +
**Vertical Slicing** (cada dominio completo en su carpeta).

El árbol de `lib/` se lee en tres zonas:

```
lib/
├── app/             LA APLICACIÓN   → las conexiones (arranque + inyección)
├── features/        LOS DOMINIOS    → la lógica de negocio (el hexágono)
├── shared/          el kernel común → primitivas de dominio
└── infrastructure/  LA INFRAESTRUCTURA → adaptadores de servicios externos
```

## 1 · `app/` — la aplicación (las conexiones)

- `app.dart`: widget raíz.
- `di/`: **único sitio que conoce las dos mitades**: crea los adaptadores de
  `infrastructure/` y los inyecta en los puertos del dominio.
- Los adaptadores de backend viven en `infrastructure/`; el dominio depende
  únicamente de sus puertos.

## 2 · `features/` — los dominios (la lógica de negocio)

Cada carpeta es un *slice* vertical: contiene todo lo de ese dominio y no
depende de los demás slices.

```
features/<dominio>/
├── domain/            EL HEXÁGONO: no importa Flutter ni el backend
│   ├── model/         entidades y value objects (AppUser, UserProfile…)
│   ├── validation/    reglas puras (email válido, contraseña mínima…)
│   ├── service/       domain services (el motor de triaje vivirá aquí)
│   └── port/          interfaces = PUERTOS que el dominio necesita
├── application/       casos de uso (in-ports): orquestan el dominio
│   └── use_case/      RegisterWithEmail, SignInWithEmail, SignOut…
└── presentation/      pantallas y widgets propios de este dominio
    ├── screens/
    └── widgets/
```

Estado actual: `auth/`, `owners/`, `pets/`, `triage/`, `queue/` y `clinics/`
tienen carpeta e implementación propia. `infrastructure/supabase/` contiene
adaptadores de Auth, Postgres y Storage para esos dominios. La UI está conectada
a los casos de uso de autenticación, mascotas, visitas, triaje, cola y clínicas.
Cada pantalla llama a casos de uso; los widgets de presentación reciben datos y
callbacks, y no acceden directamente a Supabase.

## 3 · `infrastructure/` — lo externo al negocio

Implementa los puertos del dominio y recibe las interacciones del usuario:

```
infrastructure/
├── supabase/          adaptadores de salida (driven adapters)
│   ├── Auth → AuthRepository
│   ├── Postgres → repositorios de perfiles, dueños, mascotas, visitas, cola y clínicas
│   └── Storage → almacenamiento privado de fotos
```

## Regla de dependencia

```
app  ──conoce──▶  features  ◀──implementa──  infrastructure
                    │
                    └──▶  shared/domain/  (kernel común)
```

- Nada de `features/` ni `shared/` apunta hacia `infrastructure/` o `app/`.
- Los **puertos** (`domain/port/`) apuntan siempre hacia afuera; los
  **adaptadores** (`infrastructure/`) apuntan hacia dentro. Por eso el dominio
  se puede probar con dobles en memoria, sin servicios remotos.

## Traducción de conceptos

| Concepto hexagonal | Dónde vive aquí |
|---|---|
| Hexágono / dominio | `features/<dominio>/domain/` |
| Puerto (out-port) | `features/<dominio>/domain/port/` |
| Caso de uso (in-port) | `features/<dominio>/application/use_case/` |
| Adaptador driven | `infrastructure/supabase/` |
| Adaptador driving | `features/<dominio>/presentation/` |
| Mapper | mappers internos (Postgres ↔ entidad) |
| Composition root | `app/di/` |

## Ejemplo: registro de un dueño

1. La pantalla de `features/owners/presentation/` llama al caso de uso.
2. `application/use_case/RegisterWithEmail` valida y orquesta.
3. Pide al **puerto** `AuthRepository` crear la cuenta (no conoce el proveedor).
4. Pide al **puerto** `UserProfileRepository` guardar el perfil con rol.
5. `infrastructure/supabase/` es quien realmente habla con Supabase.

Por eso `flutter test` corre con dobles y pasa sin configuración de Supabase.
