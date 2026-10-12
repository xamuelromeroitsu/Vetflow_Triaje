# EPC-01 · Captura y registro de patologías/síntomas

## US-01 · Datos generales y antecedentes de la mascota
**Como** dueño de mascota, **quiero** ingresar los datos generales y antecedentes médicos del animal, **para** crear su perfil clínico inicial.

**Criterios de aceptación**
- [ ] Obligatorios: nombre, especie, raza, edad.
- [ ] Opcionales: sexo, esterilizado, antecedentes, alergias.
- [ ] Se guarda en Firestore y se puede consultar después.
- [ ] Error claro si falta un campo obligatorio.

**Pregunta pendiente:** ¿Se identifica al dueño por cédula o por teléfono?
**Componentes:** formulario de registro, colección `pets`.

## US-02 · Síntomas con texto guiado
**Como** dueño de mascota, **quiero** describir los síntomas con categorías y texto libre, **para** explicar con precisión qué le ocurre.

**Criterios de aceptación**
- [ ] Selector de categorías (digestivo, respiratorio, piel, movimiento, comportamiento, otro).
- [ ] Lista de síntomas frecuentes por categoría.
- [ ] Texto libre para observaciones.
- [ ] Campo "desde cuándo" (horas/días).

**Escenario**
```
Dado que el dueño eligió la categoría "digestivo"
Cuando selecciona "vómito" e indica "desde hace 2 días"
Entonces el síntoma queda guardado con su categoría y duración
```

## US-03 · Fotos de lesiones o reportes
**Como** personal de recepción (o dueño), **quiero** adjuntar fotos, **para** complementar el registro con evidencia visual.

**Criterios de aceptación**
- [ ] Carga de JPG y PNG.
- [ ] Límite: 5 MB por imagen, máximo 3 (propuesta).
- [ ] Vista previa antes de enviar.
- [ ] Mensaje claro si el archivo es demasiado grande o de otro tipo.

**Pregunta pendiente:** ¿Cuánto tiempo se conservan las imágenes?

## US-04 · Signos vitales básicos
**Como** personal de recepción o enfermería, **quiero** registrar temperatura, peso y frecuencia cardíaca, **para** adjuntarlos al reporte antes de la evaluación.

**Criterios de aceptación**
- [ ] Temperatura y peso obligatorios; frecuencia cardíaca opcional.
- [ ] Validación de rango de captura (evita errores de tipeo) según [signos vitales](../../03-triaje-clinico/signos-vitales-por-especie.md).
- [ ] Unidades fijas: °C y kg.
- [ ] Valores fuera del rango normal se guardan y se marcan; no se bloquean.

**Escenario**
```
Dado que la especie es "gato"
Cuando se ingresa temperatura 41.0 °C
Entonces el valor se guarda marcado como "fuera de rango normal"
 y el triaje lo tendrá en cuenta para subir el nivel
```
**Pregunta pendiente:** ¿Rangos normales por especie validados por el veterinario?
