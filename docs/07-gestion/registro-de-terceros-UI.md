# Registro de terceros e integraciones

Cada servicio externo se anota aquí **antes** de integrarlo. Se revisa con `privacy-and-consent`.

| Servicio | Para qué | Datos que recibe | ¿Datos personales o de salud? | Consentimiento | Fase | Estado |
|---|---|---|---|---|---|---|
| Supabase Auth | Cuentas y roles | Correo/teléfono, id de usuario | Sí (identificación) | Necesario para el servicio | MVP | Documentar región y condiciones |
| Supabase Postgres | Base de datos | Datos de la tabla de privacidad | Sí | Necesario para el servicio | MVP | Documentar región y condiciones |
| Supabase Storage | Fotos | Imágenes | Sí | Casilla opcional de fotos | MVP | Bucket privado; documentar retención |
| Servicio de mapas | Directorio de clínicas | Ubicación aproximada del dueño | Sí (ubicación) | Permiso del sistema + explicación | 3 | Pendiente de elegir proveedor |
| Analítica de producto | Mejorar la app | Eventos de uso, sin datos de salud | A evitar | Casilla opcional | 2–3 | Pendiente de decidir |
| Notificaciones push | Avisos de turno | Token del dispositivo | Sí (identificador) | Permiso del sistema | 2–3 | Pendiente |
| Pasarela de pagos | Citas pagadas | Datos de pago | Sí | Según proveedor | Sin fecha | Fuera de alcance |

## Reglas
- No se envían datos de salud de la mascota ni identificadores del dueño a servicios de analítica.
- Para cada servicio: dónde se almacenan los datos, contrato o condiciones vigentes y cómo se borran.
- Revisar la lista antes de cada hito.
