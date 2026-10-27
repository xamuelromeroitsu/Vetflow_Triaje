# Registro de mascota con diseño DOGO y arquitectura real del proyecto

## Objetivo
Adaptar el módulo de registro de mascota con la referencia visual entregada por el mockup DOGO al proyecto Flutter de VetFlow Triaje, integrándolo con la arquitectura existente del dominio, la validación y el flujo de navegación de la app.

## Alcance
- Reusar la estructura vertical por features y casos de uso ya presente en el proyecto.
- Mantener la lógica de negocio separada de la UI.
- Integrar una pantalla de registro con un diseño clínico, moderno y usable en móvil.
- Soportar tanto el flujo del dueño de la mascota como el flujo del personal clínico.
- Hacer la pantalla compatible con modo local/demo cuando no hay acceso real a Firebase.

## Origen del diseño
Se tomó la referencia visual del mockup de Stitch DOGO presentado en la carpeta del proyecto y se adaptó a la estructura real de Flutter:
- `stitch_dogo_veterinary_triage_app/.../code.html`
- `stitch_dogo_veterinary_triage_app/.../DESIGN.md`

La intención fue no copiar el mockup como HTML estático, sino traducir sus atributos visuales y de flujo a la app actual: selección de especie, foto opcional, campos reales de mascota, sexo, esterilización, historial y alergias.

## Cambios aplicados en el código

### 1) Pantalla de registro
Se reescribió la pantalla principal de registro en:
- `vetflow_triaje/lib/features/pets/presentation/pet_register_screen.dart`

Incluye:
- cabecera con identidad DOGO,
- selector de rol: Dueño / Personal clínico,
- diseño en estilo Clinical Mint,
- campos para nombre, especie, raza, edad, peso, sexo, esterilización,
- historial clínico y alergias,
- validación de campos obligatorios,
- botón de guardado con flujo de navegación hacia el siguiente paso del triaje.

### 2) Integración con el modelo de dominio
Se aprovechó la capa de dominio ya existente:
- `features/pets/domain/model/pet.dart`
- `features/pets/domain/validation/pet_validation.dart`
- `features/pets/application/use_case/register_pet.dart`

La nueva pantalla se conecta con este caso de uso para mantener la lógica de negocio en la capa correcta y evitar que la UI conozca detalles internos del almacenamiento.

### 3) Tema visual compatible
Se usó la paleta y estilo ya definidos para la app clínica:
- `vetflow_triaje/lib/shared/presentation/theme/app_theme_clinical_mint.dart`

Esto aseguró que la pantalla no se viera como un componente aislado, sino como parte del sistema visual del producto.

### 4) Compatibilidad con la ausencia de Firebase
Se mantuvo una estrategia de fallback local para que la app pueda arrancar aunque no exista acceso real a la base de datos:
- se usa un `ownerId` local de demo si no hay usuario autenticado,
- la pantalla sigue funcionando para validar el flujo visual y la lógica UX,
- cuando exista el proyecto real de Firebase se conectará la persistencia real sin romper la UI.

## Reglas clínicas y de producto respetadas
- El triaje nunca baja de nivel por datos incompletos.
- La app no diagnostica; se comunica la orientación del triaje, no un diagnóstico final.
- El usuario puede ser dueño o personal clínico; la pantalla se ajusta a ambos roles.
- Los datos mínimos y útiles para triaje se guardan y se validan, sin sobrecaptura innecesaria.

## Estado de validación
Se ejecutó la compilación del proyecto para verificar que el módulo quedó integrado correctamente:

```bash
cd /home/edilver/Escritorio/Vetflow_Triaje/vetflow_triaje
flutter build web --release
```

Resultado verificado:
- `✓ Built build/web`

Esto confirma que el proyecto compila con la pantalla revisada y que la integración no rompe la app web en su estado actual.

## Pendiente real para producción
La persistencia real de mascotas requiere acceso legítimo a Firebase y a los proyectos/credenciales reales del cliente. Mientras no exista ese acceso, la app puede seguir funcionando en local/demo, pero la base de datos real queda pendiente de activar.

## Recomendación de siguiente paso
1. Conectar Firebase Auth y Firestore reales.
2. Habilitar la colección de mascotas según el modelo de datos del proyecto.
3. Sustituir el `ownerId` demo por el usuario autenticado real.
4. Validar el flujo completo de registro en dispositivo móvil y web.

## Resumen
El módulo quedó adaptado al estilo DOGO y se integró en la arquitectura real de Flutter del proyecto. La pantalla es funcional, visualmente coherente y compilable, con fallback local para entorno sin Firebase y lista para conexión real cuando se disponga del entorno correcto.
