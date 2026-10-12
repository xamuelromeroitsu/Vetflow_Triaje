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
└── infrastructure/  LA INFRAESTRUCTURA → todo lo externo (Firebase, widgets)
```

## 1 · `app/` — la aplicación (las conexiones)

- `app.dart`: widget raíz.
- `di/`: **único sitio que conoce las dos mitades**: crea los adaptadores de
  `infrastructure/` y los inyecta en los puertos del dominio.
- Si cambias Firebase por otro backend, solo se toca esta carpeta.

## 2 · `features/` — los dominios (la lógica de negocio)

Cada carpeta es un *slice* vertical: contiene todo lo de ese dominio y no
depende de los demás slices.

```
features/<dominio>/
├── domain/            EL HEXÁGONO: no importa Flutter ni Firebase
│   ├── model/         entidades y value objects (AppUser, UserProfile…)
│   ├── validation/    reglas puras (email válido, contraseña mínima…)
│   ├── service/       domain services (el motor de triaje vivirá aquí)
│   └── port/          interfaces = PUERTOS que el dominio necesita
├── application/       casos de uso (in-ports): orquestan el dominio
│   └── use_case/      RegisterWithEmail, SignInWithEmail, SignOut…
```

Estado actual: solo `features/auth/` está implementado. `triage/`, `pets/` y
`owners/` tienen su carpeta creada y documentada; se rellenan cuando entren
sus historias.

## 3 · `infrastructure/` — lo externo al negocio

Implementa los puertos del dominio y recibe las interacciones del usuario:

```
infrastructure/
├── firebase/          adaptadores de salida (driven adapters)
│   ├── auth/          Firebase Auth → implementa el puerto AuthRepository
│   └── profile/       Firestore users/{uid} → UserProfileRepository + mapper
└── presentation/      adaptador de entrada: pantallas, widgets e inputs
                       (se crea cuando llegue la UI)
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
  se puede probar con dobles en memoria, sin Firebase ni emulador.

## Traducción de conceptos

| Concepto hexagonal | Dónde vive aquí |
|---|---|
| Hexágono / dominio | `features/<dominio>/domain/` |
| Puerto (out-port) | `features/<dominio>/domain/port/` |
| Caso de uso (in-port) | `features/<dominio>/application/use_case/` |
| Adaptador driven | `infrastructure/firebase/` |
| Adaptador driving | `infrastructure/presentation/` (futuro) |
| Mapper | `user_profile_mapper.dart` (Firestore ↔ entidad) |
| Composition root | `app/di/` |

## Ejemplo: registro de un dueño

1. La pantalla (futura, `infrastructure/presentation/`) llama al caso de uso.
2. `application/use_case/RegisterWithEmail` valida y orquesta.
3. Pide al **puerto** `AuthRepository` crear la cuenta (no sabe que es Firebase).
4. Pide al **puerto** `UserProfileRepository` guardar el perfil con rol.
5. `infrastructure/firebase/` es quien realmente habla con Firebase.

Por eso `flutter test` corre con dobles y pasa sin configuración de Firebase.
