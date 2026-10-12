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
| species | string | `perro`, `gato` |
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

## Índices previstos
`visits` por (`companyId`, `status`, nivel de triaje, `createdAt`) para la cola.

## Pendiente
Identificador del dueño (teléfono vs cédula) y manejo de mascotas con varios dueños.
