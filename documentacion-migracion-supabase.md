# Migración de Firebase a Supabase

## Estado

La aplicación Flutter usa Supabase como backend. La conexión requiere una clave
pública `anon`/`publishable` configurada localmente, y el esquema SQL debe
aplicarse al proyecto antes de que las operaciones remotas estén disponibles.
No se migraron datos: se confirmó que no hay datos reales de Firebase que
preservar.

## Configuración

Desde `vetflow_triaje/`, el archivo `.env` local está creado y excluido por
Git. Si falta, cópialo desde `.env.example`:

1. Reemplazar `REPLACE_WITH_SUPABASE_ANON_KEY` en `.env` con la clave
   `anon`/`publishable` del proyecto
   `mpcpojywownddppkcyzr`. No usar una clave `service_role`.
2. Mantener `.env` fuera de Git. La clave pública incluida en un binario móvil
   no es secreta; el aislamiento de datos depende de RLS y las políticas de
   Storage.
3. Aplicar todas las migraciones de `supabase/migrations/` en orden por nombre,
   mediante Supabase CLI o el SQL Editor, después de revisar las políticas y
   permisos.
4. Para permitir acceso inmediato después del registro, desactivar **Confirm
   email** en Supabase Dashboard → Authentication → Sign In / Providers →
   Email. Esto permite crear cuentas sin verificar primero la dirección de
   correo.

La URL configurada es `https://mpcpojywownddppkcyzr.supabase.co`. La clave real
no se incluyó en este repositorio ni se compartió en el chat; el `.env` local
contiene solo el marcador de posición y la inicialización lo rechaza. La base
remota no fue modificada desde este entorno.

## Cambios realizados

- Dependencias `supabase_flutter` y `flutter_dotenv`; se retiraron los paquetes
  Firebase.
- `lib/app/supabase_initializer.dart` carga y valida `.env` antes del arranque.
- `lib/main.dart` inicializa Supabase y conecta los adaptadores de
  autenticación, perfiles, dueños, mascotas, visitas, cola, clínicas y fotos.
- `lib/infrastructure/supabase/supabase_repositories.dart` implementa acceso a
  PostgreSQL y al bucket privado `pet-photos`.
- `supabase/migrations/` contiene migraciones SQL separadas y nombradas por su
  propósito. Deben aplicarse en orden por nombre para respetar sus
  dependencias:
  - `20261027000000_enable_pgcrypto.sql`: extensión para generar identificadores.
  - `20261027000100_create_user_profiles.sql`: perfil y rol del usuario.
  - `20261027000200_create_owners.sql`: datos de contacto de los dueños.
  - `20261027000300_create_pets.sql`: mascotas y sus datos básicos.
  - `20261027000400_create_clinics.sql`: directorio de clínicas.
  - `20261027000500_create_visits.sql`: casos de atención y datos de triaje.
  - `20261027000600_create_access_functions.sql`: funciones auxiliares.
  - `20261027000700_configure_triggers_and_rls.sql`: triggers y permisos por fila.
  - `20261027000800_configure_pet_photos_storage.sql`: bucket y permisos de fotos.
  - `20261027000900_enable_realtime.sql`: tablas publicadas en Realtime.
  Las tablas y funciones incluyen comentarios descriptivos.
- Se retiraron configuración FlutterFire, plugins Android, el plist y la
  referencia a Firebase en Xcode. Se conserva el Podfile de Flutter para iOS.

## Servicios y comprobación

El cliente usa Supabase Auth con correo/contraseña, Postgres para los datos y
Supabase Storage para fotos. Para comprobar la configuración:

```bash
cd vetflow_triaje
flutter pub get
flutter analyze
flutter test
flutter run
```

Comprobaciones ejecutadas en Linux: `flutter clean`, `flutter pub get`,
`flutter test` (22 pruebas) y `flutter build apk --debug` terminaron
correctamente. `flutter analyze` no reportó errores, pero finalizó con 30
avisos/infos en distintas partes del proyecto. No se pudo hacer una
prueba real de Auth ni hot restart: no hay clave válida ni una app Flutter
conectada en ejecución.

La autenticación, lecturas/escrituras y carga de fotos requieren que la clave
esté configurada, el esquema se haya aplicado, RLS esté habilitado y exista el
bucket `pet-photos` según la migración. El registro con inicio de sesión
inmediato requiere desactivar **Confirm email** en la configuración remota de
Supabase Auth; no se puede cambiar esa opción desde la app Flutter.

La compilación iOS debe verificarse en macOS con Xcode y CocoaPods; este entorno
Linux no puede compilar iOS.
