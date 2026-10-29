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
3. Aplicar las migraciones versionadas de `supabase/migrations/` al proyecto
   remoto después de revisar las políticas y permisos.

## Migraciones, seed y pooler

El esquema actual del MVP está en
[`20261027000000_initial_schema.sql`](vetflow_triaje/supabase/migrations/20261027000000_initial_schema.sql):
`user_profiles`, `owners`, `pets`, `visits` y `clinics`, además de RLS,
funciones, Storage y Realtime. No editar una migración que ya se aplicó en un
entorno compartido; agregar una migración nueva para cada cambio de esquema.
`appointments`, `health_records`, `pet_vaccines` y `pet_treatments` están en el
modelo futuro y se incorporarán con sus historias, constraints y políticas RLS.

`supabase/config.toml` configura `seed.sql` para el entorno local. El seed solo
crea una clínica de demostración con datos ficticios; no crea cuentas, dueños,
mascotas ni visitas. `supabase db reset` reconstruye la base **local** y ejecuta
el seed. No usar `db reset` contra el proyecto remoto. `supabase db push` aplica
migraciones pendientes, no ejecuta el seed.

Para desplegar:

1. Instalar Supabase CLI y autenticarse con `supabase login`.
2. Desde `vetflow_triaje/`, enlazar el proyecto con
   `supabase link --project-ref mpcpojywownddppkcyzr`.
3. En el Dashboard, copiar el URI de **Shared Pooler / Session mode** y
   cargarlo en `SUPABASE_DB_URL` en la sesión local de PowerShell (sin incluirlo
   en comandos guardados). Revisar primero con
   `supabase db push --dry-run --db-url "$env:SUPABASE_DB_URL"` y, si el plan es
   correcto, ejecutar
   `supabase db push --db-url "$env:SUPABASE_DB_URL"`. Limpiar la variable al
   terminar con `Remove-Item Env:SUPABASE_DB_URL`. No guardar el URI en Git,
   `.env` móvil, logs ni comandos compartidos.
4. El seed local no se aplica a remoto; cargar datos reales de clínicas solo
   tras validarlos.

Para operaciones CLI/migraciones, elegir el pooler en modo **session** (puerto
5432) si la red no alcanza la conexión directa, por ejemplo por IPv4. Evitar el
modo **transaction** (puerto 6543) para este flujo. La app móvil no usa ese URI:
`supabase_flutter` se conecta a `https://<project-ref>.supabase.co` por HTTPS
con la clave pública `anon`/publishable; no exponer una contraseña PostgreSQL
ni una clave `service_role` en Flutter.

La URL configurada es `https://mpcpojywownddppkcyzr.supabase.co`. La clave real
no se incluye en el repositorio ni se comparte en el chat; `.env` permanece
local y excluido por Git. La base remota no fue modificada desde este entorno.

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
- `supabase/config.toml` y `supabase/seed.sql` habilitan datos ficticios
  únicamente para la base local.
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
avisos/infos en distintas partes del proyecto. No se ha verificado el registro
real contra Auth; la clave local está configurada, pero no se validó contra el
proyecto remoto. El hot restart requiere una app Flutter conectada.

La autenticación, lecturas/escrituras y carga de fotos requieren que la clave
esté configurada, las migraciones se hayan aplicado, RLS esté habilitado y
exista el bucket `pet-photos` según la migración. La confirmación de correo
puede requerir confirmar la cuenta antes del primer inicio de sesión.

### Si falla el registro de una cuenta

`seed.sql` solo agrega una clínica de demostración: no crea usuarios de Auth ni
prueba el flujo de registro. La app registra mediante `auth.signUp`; revisa el
detalle mostrado por la app y los logs de **Auth** en Supabase para distinguir
un correo duplicado, una restricción de contraseña o un error del trigger de
base de datos.

El trigger de `20261027000000_initial_schema.sql` crea `user_profiles`. Para
que también se guarden nombre y teléfono cuando Supabase requiere confirmar el
correo (y aún no hay sesión móvil), aplica además
`20261028000000_registration_owner_metadata.sql` al proyecto remoto. Las
pruebas locales del seed o de RLS no aplican migraciones al proyecto remoto ni
validan Auth.

La compilación iOS debe verificarse en macOS con Xcode y CocoaPods; este entorno
Linux no puede compilar iOS.
