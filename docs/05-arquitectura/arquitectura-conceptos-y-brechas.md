# Arquitectura: conceptos, diferencias, diagnóstico y glosario

Este documento explica **las cuatro estructuras** que usa VetFlow, cómo se aplican
hoy en el código, qué falta para llegar al "100" y el vocabulario que usamos al
hablar de arquitectura.

Es el compañero de [arquitectura-carpetas.md](arquitectura-carpetas.md): aquel
dice **dónde va cada cosa**; este dice **por qué está así y qué sigue**.

## 0 · En una página

VetFlow combina cuatro estructuras, y **no compiten**: cada una responde una
pregunta distinta.

| Estructura | Pregunta que responde | En una frase |
|---|---|---|
| Hexagonal (puertos y adaptadores) | ¿Cómo protejo el dominio del exterior? | El dominio no sabe que existe Firebase. |
| DDD (táctico) | ¿Cómo modelo el dominio por dentro? | Agregados, value objects y eventos donde el dominio es complejo. |
| Clean Architecture | ¿Hacia dónde apuntan las dependencias? | Siempre hacia el dominio, nunca hacia fuera. |
| Vertical Slicing | ¿Cómo organizo el código por dominio? | Un slice completo por dominio, no capas técnicas globales. |

**Diagnóstico honesto:** el núcleo hexagonal ya está completo (hexágono con
puertos, casos de uso como in-ports, adaptadores driven, composition root y
shared kernel) → somos un **90**. Lo que falta son las piezas que *cruzan* los
bordes (ver §5). La propuesta de cierre está en
[ADR-0006](adr/0006-cierre-de-brechas-arquitectura.md).

## 1 · Qué pregunta responde cada una

| Estructura | Responde a |
|---|---|
| **Hexagonal** | ¿Cómo protejo el dominio del exterior? (puertos / adaptadores) |
| **DDD** | ¿Cómo modelo el dominio por dentro? |
| **Clean** | ¿Hacia dónde apuntan las dependencias? |
| **Vertical slicing** | ¿Cómo organizo el código por dominio? |

Regla mental: **el slicing elige las carpetas, el hexágono manda en los bordes,
clean fija la dirección de las flechas y DDD modela el interior** cuando el
dominio lo merece (el triaje sí; un CRUD de mascotas, no).

## 2 · Aplicado a VetFlow

### 2.1 · Hexagonal (Ports & Adapters) — proteger el dominio

El dominio (las reglas) vive en el centro y **no sabe nada** de Flutter ni de
Firebase. Todo lo externo entra y sale por **puertos** (interfaces) que los
**adaptadores** implementan.

| Pieza hexagonal | Dónde vive hoy (ejemplo de `auth`) |
|---|---|
| Puerto (out-port) | `features/auth/domain/port/auth_repository.dart` |
| Puerto (out-port) | `features/auth/domain/port/user_profile_repository.dart` |
| Caso de uso (in-port) | `features/auth/application/use_case/sign_in_with_email.dart` |
| Adaptador driven | `infrastructure/firebase/auth/firebase_auth_repository.dart` |
| Adaptador driven | `infrastructure/firebase/profile/firestore_user_profile_repository.dart` |
| Composition root | `app/di/auth_dependencies.dart` |
| Adaptador driving (UI) | *previsto*: `infrastructure/presentation/` (llega con las pantallas) |

**Por qué:** gracias a esto los 5 tests de `test/features/auth/` corren con
dobles en memoria, sin emulador ni credenciales; y si algún día cambiamos
Firebase por otro backend, solo se toca `app/di/` y los adaptadores.

### 2.2 · Clean Architecture — la dirección de las flechas

Una sola regla: **las dependencias apuntan siempre hacia el dominio**. Lo de
dentro no importa lo de fuera.

En nuestro árbol: nada de `features/` ni `shared/` importa `infrastructure/` o
`app/` (regla en [arquitectura-carpetas.md](arquitectura-carpetas.md#regla-de-dependencia)).

```
app  ──conoce──▶  features  ◀──implementa──  infrastructure
                     │
                     └──▶  shared/domain/  (kernel común)
```

### 2.3 · Vertical Slicing — organizar por dominio

En vez de capas técnicas globales (`/models`, `/services` para toda la app),
cada dominio lleva **todo lo suyo junto**: `features/triage/` tendrá su `domain/`
y su `application/` completos. Cambiar el triaje no obliga a tocar `pets` ni
`owners`, y encaja con nuestra metodología de *una historia = una rama*.

### 2.4 · DDD táctico — modelar el dominio por dentro

DDD aporta piezas de modelado para reglas complejas. El protocolo clínico de
triaje encaja perfecto (ver [protocolo-triaje.md](../03-triaje-clinico/protocolo-triaje.md)):

- **Bounded context:** `features/triage/` es su propio contexto, con su lenguaje
  (Emergencia / Urgencia / Consulta).
- **Aggregate root** (`TriageSession`): protege las invariantes. Toda mutación
  pasa por sus métodos, así que "un *sí* en descarte ⇒ Emergencia" no se puede
  saltar por accidente.
- **Value objects** (`SeverityLevel`, `VitalSigns`, `Species`): inmutables y se
  validan al construirse (p. ej. rangos por especie, ADR-0005).
- **Domain events** (`CriticalSignsDetected`, `LevelConfirmed`): avisan de algo
  que pasó sin acoplar el triaje a las notificaciones.

Cada regla clínica se vuelve una invariante imposible de esquivar:

| Regla clínica (documentada) | Dónde vive en DDD |
|---|---|
| Un "sí" en descarte ⇒ Emergencia | `TriageSession` (invariante) |
| "No sé" ⇒ mínimo Urgencia | `TriStateAnswer` + reglas del motor |
| Signos vitales solo pueden **subir** el nivel | `TriageRulesEngine` (`SeverityLevel.max`) |
| Faltan signos obligatorios ⇒ no baja de Urgencia | regla de seguridad del motor |
| Sugerido vs confirmado (para medir) | el agregado guarda ambos + `LevelConfirmed` |
| Ante la duda, subir | regla explícita de `TriageRules` |
| Rangos por especie (perro / gato) | `VitalSigns` + `Species` + `TriageRules` versionado |

**Importante:** DDD se *aplica*, no se *instala* en todas partes. `pets/` y
`owners/` pueden quedarse como CRUD simple; el modelado táctico se reserva para
donde el dominio es complejo (triage). Las reglas clínicas siguen siendo
**borrador** hasta que el veterinario las valide
([validacion-veterinaria.md](../03-triaje-clinico/validacion-veterinaria.md)).

## 3 · Cómo se combinan (ejemplo: registrar un dueño)

1. La pantalla (futura, `infrastructure/presentation/`) llama al caso de uso.
2. `application/use_case/RegisterWithEmail` valida y orquesta.
3. Pide al **puerto** `AuthRepository` crear la cuenta (no sabe que es Firebase).
4. Pide al **puerto** `UserProfileRepository` guardar el perfil con rol.
5. `infrastructure/firebase/` es quien realmente habla con Firebase.

Lectura por capas: el **slicing** puso a `auth` en su propia carpeta; el
**hexágono** aisló Firebase tras los puertos; **clean** obligó a que el dominio
no mire hacia fuera; y cuando el triaje entre, **DDD** modelará sus invariantes.

## 4 · Diferencias (errores comunes)

| Confusión habitual | Corrección |
|---|---|
| "Clean y Hexagonal son lo mismo" | Son familia, no sinónimos: hexagonal = *bordes con puertos*; clean = *dirección de las dependencias*. Se usan juntas y se llevan bien. |
| "DDD es otra arquitectura" | No: DDD es *modelado*, se ejecuta **dentro** del hexágono, no lo sustituye. |
| "Si uso DDD todo debe ser agregado" | No: donde el dominio es simple (CRUD), el modelado táctico sobra. |
| "Vertical slicing es solo cambiar nombres de carpetas" | Es aislar dominios completos; la prueba es que tocar uno no obliga a tocar los demás. |

## 5 · Diagnóstico honesto: del 90 al 100

Núcleo hexagonal ya completo: puertos, casos de uso como in-ports, adaptadores
driven, composition root (`app/di/`) y shared kernel. Lo que falta son las
piezas que cruzan los bordes:

| # | Gap | Por qué importa | Estado |
|---|---|---|---|
| 1 | Puertos transversales en `shared/` (`Clock`, `IdGenerator`, `Logger`) | Hoy el dominio usaría `DateTime.now()` / UUID directo → tests no deterministas, dependencia oculta | Pendiente |
| 2 | Domain events + publisher | Un caso crítico detectado debe poder avisar al veterinario sin acoplar triage a notificaciones | Pendiente |
| 3 | Traducción de errores infra → dominio | Si `FirebaseAuthException` se escapa al dominio, el puerto pierde sentido | Pendiente |
| 4 | Contract tests | Los dobles prueban el dominio, pero nadie prueba que Firestore **cumple** el puerto | Pendiente |
| 5 | Anti-corruption layer / context map | El triaje necesitará datos del paciente; si importa directo de otro contexto, los bordes se filtran | Pendiente (con triage) |
| 6 | Pipeline de aplicación | Validación, logging y transacciones se repetirían en cada caso de uso | Pendiente |
| 7 | `app/config/` por entorno | dev / prod / emulador mezclados en el arranque | Pendiente |
| 8 | Tests de `firestore.rules` | La doble validación (móvil + reglas) solo es real si las reglas se prueban | Pendiente |
| 9 | Driving adapter de entrada (UI) | El hexágono hoy solo tiene un lado; sin `presentation/` el in-port no se ejerce | **Roadmap** (la doc ya lo prevé) |
| 10 | `shared/testing/` | Dobles reutilizables evitan reescribir `FakeClock` y repositorios en memoria en cada test | Pendiente |

**Nota:** el punto 9 no es deuda, es roadmap. Los puntos **1-4 y 10** son la
deuda real hoy; 5-8 llegan con sus features.

## 6 · Árbol objetivo (100/100) — *propuesta*

Nuestro árbol actual, completado. **Es una propuesta** (ver ADR-0006), no la
estructura en vigor:

```
lib/
├── app/
│   ├── app.dart                     widget raíz (existe)
│   ├── config/                      ← #7: entornos (dev/prod/emulador) + FirebaseOptions
│   └── di/                          composition root + pipelines (#6, #7)
├── features/                        bounded contexts
│   ├── auth/                        en vigor (referencia viva)
│   └── triage/
│       ├── domain/
│       │   ├── model/{aggregate,entity,value_object,event}/   ← #2 domain events
│       │   ├── service/             motor de reglas puro (previsto en technical-spec)
│       │   ├── port/                out-ports del contexto
│       │   └── validation/
│       ├── application/
│       │   ├── use_case/            in-ports (existe)
│       │   └── pipeline/            ← #6: decoradores transversales
│       └── infrastructure/firestore/ ← adaptador driven + ACL (#5)
├── shared/
│   ├── domain/                      kernel común: Result, errores (existe)
│   ├── port/                        ← #1: Clock, IdGenerator, Logger
│   └── testing/                     ← #10: dobles reutilizables
└── infrastructure/
    ├── firebase/                    adaptadores driven (existe)
    └── presentation/                ← #9: UI (adaptador driving)
```

## 7 · Cómo lo aplico (orden sugerido)

| Fase | Cuándo | Qué entra |
|---|---|---|
| A | Ya, con `auth` | #1 puertos transversales en `shared/port/` · #10 `shared/testing/` · #3 mapeo de errores infra → dominio · #4 contract test del adaptador contra el puerto |
| B | Con `triage` | #2 domain events + publisher · modelo DDD táctico (aggregate, value objects, eventos) · #5 ACL / context map · #8 pruebas de `firestore.rules` |
| C | Con la UI | #6 pipeline de aplicación (decoradores) · #7 `app/config/` · adaptador driving en `infrastructure/presentation/` |

Cada fase entra por su historia de usuario y su rama; no hay que parar la app
para hacerlo.

## 8 · Glosario

| Término | Significado (con ejemplo en VetFlow) |
|---|---|
| **Puerto (port)** | Interfaz que el dominio *necesita* y define él mismo. `AuthRepository`. |
| **Adaptador** | Implementación concreta de un puerto, con tecnología real. `FirebaseAuthRepository`. |
| **Adaptador driven / driving** | Driven = hacia fuera (Firebase); driving = hacia dentro (la UI que invoca al caso de uso). |
| **In-port / out-port** | In-port = punto de entrada al dominio (caso de uso); out-port = punto de salida (repositorio). |
| **Caso de uso (use case)** | Una operación del negocio orquestada: `RegisterWithEmail`. |
| **Composition root** | Único sitio donde se conectan mitades: `app/di/`. |
| **Regla de dependencia** | Las flechas de imports apuntan al dominio; `features/` nunca importa `infrastructure/`. |
| **Hexágono / dominio** | El interior protegido: `features/<dominio>/domain/`. |
| **Shared kernel** | Primitivas comunes a todos los dominios: `shared/domain/` (Result, errores). |
| **Bounded context** | Frontera de un dominio con su propio lenguaje: `features/triage/`. |
| **Agregado (aggregate)** | Grupo de objetos tratados como una unidad, con una raíz. `TriageSession`. |
| **Aggregate root** | La única puerta de entrada del agregado; protege las invariantes. `TriageSession`. |
| **Entidad** | Objeto con identidad propia dentro del dominio. `SymptomEntry`. |
| **Value object** | Objeto inmutable definido por sus valores, validado al construirse. `SeverityLevel`, `VitalSigns`. |
| **Invariante** | Regla que nunca puede violarse. "Un *sí* en descarte ⇒ Emergencia". |
| **Domain event** | Algo que pasó en el dominio y otros pueden escuchar. `CriticalSignsDetected`. |
| **Domain service** | Lógica de dominio que no cabe en una entidad. El motor de reglas de triaje. |
| **Anti-corruption layer (ACL)** | Traductor que evita que el modelo de otro contexto contamine el nuestro. |
| **Context map** | Mapa de cómo se relacionan los bounded contexts (qué habla con quién). |
| **Mapper** | Traduce entre formato externo y entidad. `UserProfileMapper` (Firestore ↔ entidad). |
| **Doble / doble en memoria** | Implementación falsa de un puerto para tests. Los `FakeAuthRepository` de `test/`. |
| **Contract test** | Prueba que verifica que un adaptador real cumple el contrato del puerto. |
| **Pipeline / decorador** | Envoltura transversal de un caso de uso (validación, logging, transacción). |
| **Vertical slice** | Carpeta con todo lo de un dominio. `features/triage/`. |
| **`rulesVersion`** | Versión de las reglas de triaje aplicadas; se guarda con el resultado (ADR-0003). |

## 9 · Referencias

- [arquitectura-carpetas.md](arquitectura-carpetas.md) · estructura en vigor
- [technical-spec.md](technical-spec.md) · stack y principios técnicos
- [ADR-0001 · Flutter + Firebase](adr/0001-flutter-y-firebase.md)
- [ADR-0003 · Triaje por reglas versionadas](adr/0003-triaje-por-reglas-versionadas.md)
- [ADR-0006 · Cierre de brechas de arquitectura](adr/0006-cierre-de-brechas-arquitectura.md) (propuesta)
- [protocolo-triaje.md](../03-triaje-clinico/protocolo-triaje.md) · reglas que el dominio debe respetar
