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
3. Aplicar `supabase/migrations/20261027000000_initial_schema.sql` mediante
   Supabase CLI o el SQL Editor, después de revisar las políticas y permisos.

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
- `supabase/migrations/20261027000000_initial_schema.sql` define tablas,
  índices, funciones auxiliares y triggers en orden de dependencia, perfiles
  desde `auth.users`, políticas RLS, Storage y Realtime.
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
bucket `pet-photos` según la migración. La confirmación de correo puede requerir
confirmar la cuenta antes del primer inicio de sesión.

La compilación iOS debe verificarse en macOS con Xcode y CocoaPods; este entorno
Linux no puede compilar iOS.
