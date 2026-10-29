# Autenticación (dominio `auth`)

Dominio implementado: **registro, inicio de sesión y cierre de sesión con
rol** (`dueno` / `personal`). El rol se guarda en `public.user_profiles`
y las políticas RLS impiden que el cliente se lo cambie. El
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

Los adaptadores Supabase viven en
`infrastructure/supabase/` y se inyectan desde `app/di/`.

Para conectarlo al proyecto real, configurar `SUPABASE_URL` y
`SUPABASE_ANON_KEY` en `.env`, habilitar Email en Supabase Auth y aplicar la
migración SQL con sus políticas RLS. Para iniciar sesión inmediatamente tras
crear una cuenta, desactivar **Confirm email** en Supabase Dashboard, en
Authentication → Sign In / Providers → Email. Con esta opción desactivada, la
dirección de correo no se verifica durante el registro.
