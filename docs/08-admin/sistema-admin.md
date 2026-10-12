# Sistema de administración (portal del personal)

El mockup de login tiene dos accesos: **Personal clínico** y **Dueños de mascotas**.

## Roles
| Rol | Puede |
|---|---|
| Recepción / enfermería | Registrar casos y signos vitales, ver la cola |
| Veterinario | Ver cola, confirmar o corregir triaje, atender |
| Administrador | Todo lo anterior + gestionar personal y clínica |

## Funciones por fase
| Función | Rol | Fase |
|---|---|---|
| Iniciar sesión como personal | Todos | MVP |
| Ver cola por prioridad | Recepción, veterinario | MVP |
| Confirmar o corregir nivel | Veterinario | MVP |
| Marcar caso como atendido | Veterinario | MVP |
| Alta y baja de personal | Administrador | 2 |
| Gestión de citas | Recepción, veterinario | 2 |
| Horarios y especialidades | Administrador | 3 |
| Métricas (casos por nivel, tiempos de espera) | Administrador | 4 |

## Pantallas previstas
Login de personal · Cola · Detalle del caso · Gestión de personal (F2) · Configuración de clínica (F3).

## Decisiones pendientes
- ¿Portal web en el MVP o el personal usa la misma app?
- ¿Cómo se crean las cuentas: invitación del administrador o alta manual?
