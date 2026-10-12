# Checklist de QA · Captura (EPC-01)

## Formularios
- [ ] No deja continuar con campos obligatorios vacíos.
- [ ] Mensajes de error claros y junto al campo.
- [ ] Texto largo y caracteres especiales no rompen el guardado.
- [ ] Doble toque en "Enviar" no crea dos registros.

## Signos vitales
- [ ] Rechaza valores imposibles (por ejemplo temperatura 99).
- [ ] Marca valores fuera de rango normal sin bloquearlos.
- [ ] Usa °C y kg siempre.

## Fotos
- [ ] Acepta JPG y PNG; rechaza otros formatos.
- [ ] Rechaza archivos de más de 5 MB.
- [ ] Máximo 3 imágenes.
- [ ] Permiso de cámara/galería denegado muestra mensaje útil.

## Sin conexión
- [ ] Llenar el formulario en modo avión no pierde datos.
- [ ] Al volver la conexión, se envía solo.
- [ ] Mensaje claro del estado ("guardado, se enviará al conectar").
- [ ] Resultado de emergencia visible sin conexión.

## Accesibilidad
- [ ] El nivel de triaje se entiende sin ver el color.
- [ ] Botones de al menos 48 px.
- [ ] Funciona con texto del sistema grande.
