# Seguridad y privacidad

## Datos que se manejan
| Dato | Sensibilidad | Nota |
|---|---|---|
| Nombre, teléfono y email del dueño | Personal | Minimizar |
| Datos clínicos de la mascota | Sensible | Acceso restringido |
| Fotos | Sensible | Pueden mostrar personas o ubicaciones |

## Controles de acceso (Supabase)
| Rol | Acceso |
|---|---|
| Dueño | Solo sus `owners`, `pets` y `visits` |
| Recepción / veterinario | `visits` de su clínica y mascotas asociadas |
| Administrador | Permisos por definir para gestión de personal |

El rol se guarda en `public.user_profiles` y las políticas RLS lo consultan.
El auto-registro solo crea `dueno`; el personal se da de alta por invitación.
El cliente no debe cambiar su rol, `owner_id` ni `company_id`.

## Medidas
- Autenticación obligatoria para escribir.
- Validación de tipos y rangos en constraints SQL, RLS y políticas de Storage.
- Storage: bucket privado `pet-photos`, JPG/PNG, máximo 5 MB y ruta por
  mascota.
- No guardar datos innecesarios del dueño.
- Aviso de privacidad claro en el primer uso.
- El dueño puede pedir borrar sus datos (definir proceso).

## Riesgo clínico
Un error de triaje es un riesgo de seguridad. Mitigación: [protocolo](../03-triaje-clinico/protocolo-triaje.md), validación veterinaria, confirmación humana y aviso al dueño.

## Pendiente
- Normativa de protección de datos del país objetivo (consultar con un profesional).
- Tiempo de conservación de fotos y visitas.
- Registro de accesos del personal.
- Revisar/validar políticas y triggers de la migración SQL con el equipo antes
  de aplicar a producción.
