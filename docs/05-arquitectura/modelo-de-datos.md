# Modelo de datos (Firestore)

## Estructura
```
/owners/{ownerId}
/pets/{petId}
/visits/{visitId}
/users/{uid}                     perfil y rol del usuario autenticado
/companies/{companyId}          (Fase 4)
   └─ /staff/{staffId}
```

## owners
| Campo | Tipo | Notas |
|---|---|---|
| name | string | |
| phone | string | Identificador posible |
| email | string | |
| createdAt | timestamp | |

## users
Perfil del usuario autenticado (Firebase Auth). Aquí vive el **rol**; las
reglas de Firestore lo leen y el auto-registro solo puede crear `dueno`.
El `personal` (recepción, veterinario, administrador) se dará de alta por
invitación en Fase 2 (ver `docs/08-admin/sistema-admin.md`).

| Campo | Tipo | Notas |
|---|---|---|
| email | string | Email de la cuenta |
| role | string | `dueno` · `personal` |
| ownerId | string/null | Documento de dueño asociado |
| companyId | string/null | Clínica (personal, Fase 4) |
| createdAt | timestamp | |


## pets
| Campo | Tipo | Notas |
|---|---|---|
| ownerId | string | |
| name | string | Obligatorio |
| species | string | 7 especies del MVP, sin acento: `perro`, `gato`, `huron`, `conejo`, `ave`, `roedor`, `reptil` (ADR-0005) |
| breed | string | Obligatorio |
| ageMonths | number | Obligatorio |
| sex | string | Opcional |
| neutered | bool | Opcional |
| history | string | Antecedentes |
| allergies | string | |

## visits
| Campo | Tipo | Notas |
|---|---|---|
| petId | string | |
| companyId | string/null | Null en MVP |
| redFlags | map | Respuestas de descarte |
| symptoms | map | category, items, notes, since |
| vitals | map | tempC, weightKg, heartRate, flags |
| photos | array<string> | Rutas en Storage |
| triage | map | suggested, confirmed, reasons, rulesVersion |
| status | string | `pendiente`, `en_atencion`, `atendido` |
| createdAt / updatedAt | timestamp | |

```json
{
  "petId": "abc123",
  "companyId": null,
  "redFlags": { "breathing": false, "seizures": false, "bleeding": false, "toxic": false, "trauma": false },
  "symptoms": { "category": "digestivo", "items": ["vómito"], "notes": "", "since": "2 días" },
  "vitals": { "tempC": 39.1, "weightKg": 12.4, "heartRate": 110, "flags": [] },
  "photos": [],
  "triage": { "suggested": "urgencia", "confirmed": null, "reasons": ["vómito repetido"], "rulesVersion": "0.1" },
  "status": "pendiente"
}
```

## clinics

Directorio de clínicas veterinarias (EPC-06).

| Campo | Tipo | Notas |
|---|---|---|
| name | string | Nombre de la clínica |
| address | string | Dirección completa |
| phone | string | Teléfono de contacto |
| email | string | Correo de contacto |
| specialties | array<string> | Especialidades (ej. medicina general, cirugía, dermatología, emergencias) |
| hours | map | Horario de atención por día de la semana |
| emergency24h | bool | Atiende urgencias 24 horas |
| services | array<string> | Servicios (hospitalización, laboratorio, imágenes, urgencias) |
| createdAt / updatedAt | timestamp | |

## appointments

Citas programadas para casos de nivel "Consulta" (EPC-07).

| Campo | Tipo | Notas |
|---|---|---|
| petId | string | Mascota |
| ownerId | string | Dueño |
| clinicId | string | Clínica atendente |
| veterinarianId | string/null | Veterinario asignado |
| dateTime | timestamp | Fecha y hora de la cita |
| status | string | `programada`, `confirmada`, `en_curso`, `completada`, `cancelada`, `reprogramada` |
| triageLevel | string | Debe ser `consulta` |
| reason | string | Motivo de la consulta |
| createdAt / updatedAt | timestamp | |

## health_records

Carnet de salud digital de la mascota (EPC-08). Un registro por mascota.

| Campo | Tipo | Notas |
|---|---|---|
| petId | string | Mascota |
| ownerId | string | Dueño |
| medicalHistory | string | Historial clínico y antecedentes |
| allergies | string | Alergias |
| emergencyContacts | array<{name, relation, phone}> | Contactos de emergencia |
| referenceClinicId | string/null | Clínica de referencia / veterinario habitual |
| createdAt / updatedAt | timestamp | |

## pet_vaccines

Vacunas aplicadas a una mascota (EPC-08).

| Campo | Tipo | Notas |
|---|---|---|
| petId | string | Mascota |
| name | string | Nombre de la vacuna |
| dateApplied | timestamp | Fecha de aplicación |
| nextDue | timestamp/null | Próxima dosis por vencer |
| lot | string/null | Lote de la vacuna |
| createdAt | timestamp | |

## pet_treatments

Tratamientos recetados a una mascota (EPC-08).

| Campo | Tipo | Notas |
|---|---|---|
| petId | string | Mascota |
| medication | string | Medicamento |
| dose | string | Dosis |
| frequency | string | Frecuencia de administración |
| startDate | timestamp | Fecha de inicio |
| endDate | timestamp/null | Fecha de fin |
| status | string | `activo`, `completado`, `cancelado` |
| createdAt | timestamp | |

## Índices previstos
`visits` por (`companyId`, `status`, nivel de triaje, `createdAt`) para la cola.
`appointments` por (`clinicId`, `dateTime`, `status`) para la agenda.
`clinics` por (`specialties`, `emergency24h`) para el directorio.

## Pendiente
Identificador del dueño (teléfono vs cédula) y manejo de mascotas con varios dueños.
