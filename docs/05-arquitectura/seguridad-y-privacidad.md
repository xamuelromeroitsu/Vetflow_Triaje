# Seguridad y privacidad

## Datos que se manejan
| Dato | Sensibilidad | Nota |
|---|---|---|
| Nombre, teléfono y email del dueño | Personal | Minimizar |
| Datos clínicos de la mascota | Sensible | Acceso restringido |
| Fotos | Sensible | Pueden mostrar personas o ubicaciones |

## Reglas de acceso (Firestore)
| Rol | Acceso |
|---|---|
| Dueño | Solo sus `owners`, `pets` y `visits` |
| Recepción / veterinario | `visits` de su clínica |
| Administrador | Lo anterior + `staff` de su clínica |

## Medidas
- Autenticación obligatoria para escribir.
- Validación de tipos y rangos en reglas de Firestore.
- Storage: solo JPG/PNG, máximo 5 MB, ruta por usuario.
- No guardar datos innecesarios del dueño.
- Aviso de privacidad claro en el primer uso.
- El dueño puede pedir borrar sus datos (definir proceso).

## Riesgo clínico
Un error de triaje es un riesgo de seguridad. Mitigación: [protocolo](../03-triaje-clinico/protocolo-triaje.md), validación veterinaria, confirmación humana y aviso al dueño.

## Pendiente
- Normativa de protección de datos del país objetivo (consultar con un profesional).
- Tiempo de conservación de fotos y visitas.
- Registro de accesos del personal.
