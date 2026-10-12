# Autenticación (dominio `auth`)

Dominio implementado: **registro, inicio de sesión y cierre de sesión con
rol** (`dueno` / `personal`). El rol se guarda en Firestore
`users/{uid}` y las reglas impiden que el cliente se lo cambie. El
auto-registro solo crea `dueno`; el personal se dará de alta por invitación
en Fase 2 (`docs/08-admin/sistema-admin.md`).

Estructura interna (ver `docs/05-arquitectura/arquitectura-carpetas.md`):

```
domain/
├── model/     AppUser, AuthAccount, Credentials, UserProfile, UserRole
├── validation/ auth_validation.dart
└── port/      AuthRepository, UserProfileRepository
application/use_case/  RegisterWithEmail, SignInWithEmail, SignOut
```

Los adaptadores de Firebase viven en
`infrastructure/firebase/{auth,profile}/` y se inyectan desde `app/di/`.

Para conectarlo a un proyecto real: `flutterfire configure` (regenera
`lib/firebase_options.dart`) + habilitar el proveedor Email/Contraseña en la
consola de Firebase + `firebase deploy --only firestore:rules`.
