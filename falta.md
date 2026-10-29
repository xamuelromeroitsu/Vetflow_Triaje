# Estado de pendientes de integración

Revisión del backend Flutter al 27-10-2026. La migración del cliente de Firebase
a Supabase está implementada en el código; esto no significa que el proyecto
remoto esté listo ni que todas las historias de producto estén terminadas.

## Completado en el repositorio

- Cliente Flutter con `supabase_flutter` y `flutter_dotenv`; inicialización
  validada antes de arrancar la app.
- Adaptadores de Supabase para Auth (registro, inicio y cierre de sesión),
  perfiles, dueños, mascotas, visitas, cola, clínicas y fotos.
- Esquema PostgreSQL inicial con constraints, RLS, Storage privado y Realtime en
  `vetflow_triaje/supabase/migrations/20261027000000_initial_schema.sql`.
- Dependencias y configuración FlutterFire retiradas del proyecto móvil.
- Validación local: `flutter clean`, `flutter pub get`, 22 pruebas y compilación
  APK Android debug completadas.

## Bloqueado por configuración externa

1. **Clave del proyecto:** sustituir el marcador de posición de
   `vetflow_triaje/.env` por la clave pública `anon`/`publishable`. No usar
   `service_role`. La clave real no está disponible en este entorno.
2. **Despliegue del esquema:** revisar y aplicar la migración SQL al proyecto
   Supabase `mpcpojywownddppkcyzr`. No se hicieron cambios en la base remota.
3. **Prueba real de Auth y datos:** comprobar proveedor Email, registro,
   confirmación de correo, inicio/cierre de sesión, políticas RLS y Storage en
   un dispositivo después de configurar la clave y desplegar el esquema.

Estos pendientes corresponden a TAR-02/TAR-03 (pasos remotos) y TAR-17
(validación QA); el detalle está en
[backlog-tareas.md](docs/07-gestion/backlog-tareas.md).

## Pendientes de producto que no se resuelven con la migración

- UI y validación del alta/edición de mascota, síntomas y signos vitales
  (TAR-04 a TAR-09).
- Selector de fotos y pruebas de fallos/offline; el adaptador de Storage ya
  existe, pero no sustituye la integración UI ni la sincronización offline
  (TAR-10 a TAR-12).
- No activar ni inventar reglas clínicas: el motor permanece sujeto a
  validación veterinaria (TAR-14 y TAR-18; ver
  [validacion-veterinaria.md](docs/03-triaje-clinico/validacion-veterinaria.md)).
- Completar la pantalla de descarte, la UI y pruebas de cola, clínicas, citas y
  carnet de salud
  (TAR-15 y TAR-19 a TAR-29).
- Añadir contract tests para RLS/Storage y pruebas de integración del flujo;
  las pruebas unitarias actuales no verifican el proyecto remoto.

Por tanto, el código base de la migración está listo para configurar, pero el
backend aún no se puede certificar como operativo ni listo para producción
hasta completar los tres bloqueos externos.
