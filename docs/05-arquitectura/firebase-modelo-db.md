# Modelo de base de datos Firebase (Cloud Firestore)

**Estado:** propuesta para el MVP; requiere revisión de seguridad antes de
publicarse y validación veterinaria de los datos y reglas clínicas.

Este documento define la estructura recomendada para Firestore en VetFlow:
qué documentos se guardan, cómo se relacionan, qué consultas debe soportar,
cómo se integra con la arquitectura y qué decisiones quedan abiertas. Firestore
no tiene tablas ni columnas relacionales: guarda documentos con campos y
subcolecciones.

## 1. Decisión para el MVP

Usar colecciones principales separadas con IDs de documento y referencias por
ID:

```text
/users/{uid}              perfil vinculado a Firebase Auth
/owners/{ownerId}         datos mínimos del dueño
/pets/{petId}             mascota; ownerId identifica a su dueño en el MVP
/visits/{visitId}         captura de una visita; referencia petId
/companies/{companyId}    reservada para la fase de clínicas
  /staff/{uid}            personal de la clínica (fase posterior)
```

Las mascotas y los dueños no se anidan bajo una clínica: una mascota puede
atenderse en distintas clínicas. Las visitas son documentos de primer nivel
porque la cola clínica debe consultarse por clínica, estado, prioridad y fecha.
Esta decisión sigue la propuesta de [ADR-0002](adr/0002-duenos-y-mascotas-fuera-de-la-clinica.md).

Se usan subcolecciones cuando los documentos hijos pertenecen claramente a un
padre y se consultan dentro de ese ámbito, como el personal de una clínica. No
se guardan visitas bajo cada mascota en el MVP, porque la cola global de una
clínica es una consulta central.

## 2. Colecciones y campos

Los campos marcados como opcionales pueden omitirse o ser `null` de forma
consistente; las reglas y los adaptadores deben acordar cuál de las dos formas
se usa. Los nombres de campos se mantienen estables en `lowerCamelCase`.

### `users/{uid}`

El ID del documento es el UID emitido por Firebase Auth. Auth es la fuente de
verdad de las credenciales; este documento contiene solo el perfil y las
relaciones necesarias para la app.

| Campo | Tipo Firestore | Obligatorio | Uso |
|---|---|---:|---|
| `email` | string | sí | Email de la cuenta; no usarlo como ID |
| `role` | string | sí | MVP: `dueno`; `personal` se habilita con invitación y autorización confiable |
| `ownerId` | string/null | sí | ID de `/owners/{ownerId}` asociado, o `null` para cuentas sin dueño |
| `companyId` | string/null | sí | Clínica del personal; `null` en el MVP |
| `createdAt` | timestamp | sí | Creación del perfil, asignada de forma confiable |

El cliente no debe poder asignarse el rol `personal` ni cambiar `companyId`
libremente. No se guardan contraseñas ni tokens en Firestore.

### `owners/{ownerId}`

Representa a la persona responsable de una o más mascotas. Su ID es
independiente del UID; `users.ownerId` enlaza la cuenta autenticada con el
perfil. Esto permite modelar perfiles sin cuenta y evita usar datos personales
como identificadores.

| Campo | Tipo Firestore | Obligatorio | Uso |
|---|---|---:|---|
| `name` | string | sí | Nombre del dueño |
| `phone` | string | según flujo | Contacto; recopilar solo si el flujo lo necesita |
| `email` | string | opcional | Contacto si difiere del email de la cuenta |
| `createdAt` | timestamp | sí | Fecha de creación |
| `updatedAt` | timestamp | recomendado | Última actualización |

La identificación del dueño (teléfono, cédula u otra) sigue pendiente de
definición por país; no asumir una cédula ni guardarla antes de necesitarla.

### `pets/{petId}`

La mascota es global al sistema y no pertenece a una clínica concreta. En el
MVP, cada mascota tiene un dueño principal en `ownerId`.

| Campo | Tipo Firestore | Obligatorio | Uso |
|---|---|---:|---|
| `ownerId` | string | sí | ID de `/owners/{ownerId}` |
| `name` | string | sí | Nombre |
| `species` | string | sí | MVP documentado: `perro`, `gato`, `huron`, `conejo`, `ave`, `roedor`, `reptil` |
| `breed` | string | sí en el modelo actual | Raza; decidir si el formulario permitirá desconocida o mestiza antes de implementarlo |
| `ageMonths` | number entero | sí en el modelo actual | Edad expresada en meses |
| `sex` | string | opcional | Sexo, con valores permitidos por definir |
| `neutered` | bool | opcional | Indica esterilización/castración |
| `history` | string | opcional | Antecedentes necesarios para la atención |
| `allergies` | string | opcional | Alergias conocidas |
| `createdAt` | timestamp | recomendado | Fecha de creación |
| `updatedAt` | timestamp | recomendado | Última actualización |

No incluir edad, raza u otros datos no necesarios en una pantalla o flujo donde
no se usen. Las reglas clínicas y los rangos por especie siguen siendo borrador
hasta su validación veterinaria.

### `visits/{visitId}`

Cada documento representa una captura de triaje de una mascota. Se conserva
`suggested` separado de `confirmed` para no confundir la sugerencia del sistema
con la decisión del veterinario.

| Campo | Tipo Firestore | Obligatorio | Uso |
|---|---|---:|---|
| `petId` | string | sí | ID de `/pets/{petId}` |
| `companyId` | string/null | sí | Clínica destinataria; `null` en el MVP sin clínica |
| `redFlags` | map | sí | Respuestas de descarte definidas por el protocolo validado |
| `symptoms` | map | sí | `category`, `items`, `notes` y `since` según el flujo |
| `vitals` | map | sí | `tempC`, `weightKg`, `heartRate` y `flags`; permitir ausencia sin bajar el triaje |
| `photos` | array<string> | sí | Rutas de objetos en Storage, no imágenes embebidas |
| `triage` | map | sí | Sugerencia, confirmación, razones y versión de reglas |
| `status` | string | sí | En MVP: `pendiente`, `en_atencion`, `atendido` |
| `createdAt` | timestamp | sí | Fecha de creación |
| `updatedAt` | timestamp | sí | Fecha de última modificación |

Contenido de `triage`:

| Campo | Tipo Firestore | Obligatorio | Uso |
|---|---|---:|---|
| `suggested` | string | sí | Nivel sugerido por el motor; valores previstos: `emergencia`, `urgencia`, `consulta` |
| `confirmed` | string/null | sí | Nivel confirmado por veterinario; `null` hasta confirmación |
| `reasons` | array<string> | sí | Motivos que explican la sugerencia |
| `rulesVersion` | string | sí | Versión identificable del conjunto de reglas aplicado |

La persistencia no sustituye las invariantes del dominio: ante datos incompletos
o incertidumbre el nivel no baja; la confirmación veterinaria se registra por
separado; la app informa que no diagnostica. No inventar preguntas, signos,
rangos ni valores por defecto clínicos para completar el esquema. Consultar
[validacion-veterinaria.md](../03-triaje-clinico/validacion-veterinaria.md).

### Archivos de visitas

Las fotos viven en Firebase Storage; `visits.photos` guarda únicamente sus
rutas. La ruta debe vincularse con la visita y permitir que las reglas de
Storage comprueben la autorización sobre esa visita. El tipo de archivo, tamaño,
retención y permisos deben definirse y validarse antes de habilitar subidas.

## 3. Relaciones y consultas objetivo

```text
Firebase Auth UID ── users/{uid}.ownerId ── owners/{ownerId}
                                               │
                                               └── pets.ownerId
                                                     │
                                                     └── visits.petId
visits.companyId ── companies/{companyId} (fase de clínicas)
```

Las referencias son IDs, no copias completas de documentos. Para mostrar una
visita con datos de la mascota, el adaptador obtiene los documentos necesarios;
si más adelante se duplica algún dato para una lectura rápida, se define como
denormalización controlada y se documenta cómo mantenerlo consistente.

Consultas principales previstas:

| Necesidad | Consulta propuesta |
|---|---|
| Mascotas de un dueño | `pets` filtrado por `ownerId` |
| Historial de una mascota | `visits` filtrado por `petId`, ordenado por `createdAt` |
| Cola de una clínica | `visits` filtrado por `companyId` y `status`, ordenado por prioridad y fecha según definición funcional |
| Cuenta del usuario | lectura directa de `users/{uid}` |

Las consultas compuestas pueden requerir índices de Firestore. El índice de la
cola debe cerrarse cuando estén definidos los estados, el orden de prioridad y
las consultas reales de la UI. Firestore Rules no filtra resultados: las
consultas deben estar acotadas de forma que todos los documentos devueltos
cumplan las reglas.

## 4. Acceso y reglas que debe cumplir el proyecto

La identidad proviene de Firebase Auth (`request.auth.uid`); el token de Auth es
un JWT verificado por Firebase. Los custom claims son opcionales y, si se usan
para roles, deben asignarse desde un entorno confiable con Firebase Admin SDK,
nunca desde la app cliente.

| Recurso | Política objetivo |
|---|---|
| `users/{uid}` | Cada persona lee su perfil. El cliente no puede elevar su rol ni cambiar su clínica; creación limitada al alta permitida. |
| `owners/{ownerId}` | Acceso al dueño vinculado y al personal autorizado cuando exista una clínica. |
| `pets/{petId}` | Acceso al propietario vinculado; el personal solo según el alcance de clínica definido. |
| `visits/{visitId}` | Acceso al dueño de la mascota y al personal autorizado para la clínica; solo personal autorizado puede cambiar `confirmed`. |
| Escrituras | Requerir autenticación, validar campos/tipos/valores permitidos y preservar campos protegidos, incluidas las relaciones de propiedad. |
| Eliminación | Denegada por defecto hasta acordar un flujo de retención y solicitudes de borrado. |
| Storage | Validar autorización a la visita/mascota, ruta, tipo y tamaño del archivo. |

La política exacta para personal y el acceso entre clínicas requieren definirse
antes de la fase de clínicas. No basta con ocultar datos en Flutter. Las reglas
son el control del servidor y deben verificarse con casos autorizados y
denegados usando Firebase Emulator Suite o pruebas equivalentes antes de
desplegar. No copiar reglas a Firebase Console hasta que compilen y pasen esas
pruebas.

En el MVP, si el motor calcula el nivel sugerido dentro de la app, Firestore
Rules puede validar quién escribe y la forma de los datos, pero no demostrar
que el cálculo clínico del cliente sea correcto. Si se necesita garantizar el
cálculo frente a un cliente manipulado, habrá que mover esa decisión a un
backend confiable en una fase posterior. La confirmación veterinaria debe
autorizarse por separado y nunca sobrescribir la sugerencia original.

**Estado actual:** el archivo de reglas de la app está en
[`vetflow_triaje/firestore.rules`](../../vetflow_triaje/firestore.rules). La
versión existente es un borrador y debe corregirse y probarse; este documento
no la declara segura ni lista para producción.

Para la seguridad y minimización de datos, ver
[seguridad-y-privacidad.md](seguridad-y-privacidad.md).

## 5. Adaptación a la arquitectura Flutter

Firestore es infraestructura, no modelo de dominio. La forma de documento no
debe filtrarse a `features/*/domain/`.

```text
features/<dominio>/domain/
  entidades, validaciones e interfaces (puertos), sin imports Firebase
features/<dominio>/application/
  casos de uso que coordinan captura y consulta
infrastructure/firebase/
  adaptadores Firestore, DTOs/mappers y traducción de errores
app/di/
  composición e inyección de adaptadores
```

Por ejemplo, `features/pets` define su modelo y puerto de repositorio; un
adaptador en `infrastructure/firebase/` traduce ese modelo al documento
`pets/{petId}`. Los casos de uso no dependen de `cloud_firestore`. Así se
mantienen pruebas de dominio sin conexión, emulador ni credenciales, y se puede
reemplazar el backend sin reescribir reglas clínicas. Esta distribución sigue
[arquitectura-carpetas.md](arquitectura-carpetas.md).

## 6. Alcance, decisiones abiertas y evolución

### Dentro del MVP

- Colecciones independientes `users`, `owners`, `pets` y `visits`.
- Un dueño principal por mascota (`pets.ownerId`).
- `companyId` nulo hasta que el flujo de clínicas forme parte del alcance.
- Captura de síntomas, signos vitales, fotos y datos de triaje con campos
  definidos aquí; las reglas clínicas quedan bloqueadas hasta validación.
- Persistencia offline contemplada por el stack; definir y probar resolución de
  conflictos antes de usarla en flujos concurrentes.

### No cerrar todavía

- Varios dueños por mascota, permisos de cuidador o transferencia de propiedad.
- Roles, invitaciones, pertenencia de personal y acceso entre clínicas.
- Identificador legal del dueño, retención/borrado de datos y normativa del país.
- Valores clínicos, síntomas permitidos y rangos que requieran veterinario.

Si el MVP requiere varios dueños, no ampliar el array de IDs sin definir quién
puede agregar o retirar propietarios y cómo se revoca el acceso. Una evolución
posible es una colección de relación (por ejemplo, `petOwners/{relationId}` con
`petId`, `ownerId`, `role` y `status`), diseñada para consultar en ambos
sentidos y protegida por reglas; debe decidirse con los requisitos reales.

### Escalabilidad

Las colecciones principales con IDs estables permiten crecer sin mover todas
las mascotas bajo una clínica y soportan consultas globales de visitas. Firestore
escala este patrón mediante índices; la escalabilidad no elimina el costo de
lecturas, el límite de tamaño de documentos ni la necesidad de paginar listas.
Por tanto:

- Paginar historiales y colas; no descargar colecciones completas.
- Mantener documentos acotados y guardar archivos en Storage.
- Crear solo índices que correspondan a consultas concretas.
- Evitar contadores o documentos compartidos que reciban escrituras excesivas;
  medir antes de optimizar.
- Revisar particionado, retención y límites de lectura cuando el uso real lo
  justifique; no introducir complejidad de multi-clínica en el MVP.

El modelo puede evolucionar, pero cambios de estructura requieren migración y
lectura temporal compatible si hay datos existentes. Cada decisión que altere
la arquitectura se registra como ADR y se actualiza aquí.

## 7. Criterios de aceptación del modelo

- [ ] Cada campo del MVP tiene tipo, necesidad y responsable de escritura claros.
- [ ] No se guardan credenciales, tokens ni datos personales innecesarios.
- [ ] Las pruebas de reglas cubren acceso autorizado y denegado por colección.
- [ ] El cliente no puede cambiar roles ni relaciones de propiedad por sí solo; solo personal autorizado puede registrar una confirmación veterinaria.
- [ ] Las consultas necesarias tienen filtros, orden, paginación e índices definidos.
- [ ] La persistencia offline y los conflictos se prueban en dispositivo.
- [ ] Los campos y comportamientos clínicos reciben validación veterinaria antes
      de uso real.
