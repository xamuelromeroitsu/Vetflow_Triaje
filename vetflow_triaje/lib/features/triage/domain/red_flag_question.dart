/// Preguntas de descarte (señales de alarma) del paso 1 del protocolo.
///
/// Se muestran primero; un "sí" lleva directo a emergencia.
/// Borrador pendiente de validación veterinaria.
library;

enum RedFlagQuestion {
  dificultadRespirar(
    '¿Le cuesta respirar o respira con la boca abierta (gato)?',
  ),
  convulsionesInconsciencia('¿Tiene convulsiones o está inconsciente?'),
  sangradoSinParar('¿Sangra sin parar?'),
  posibleToxico('¿Pudo haber ingerido veneno o un tóxico?'),
  golpeAtropello('¿Sufrió un golpe fuerte o atropello?'),
  abdomenHinchadoArcadas(
    '¿Tiene el abdomen hinchado con arcadas sin vomitar?',
  ),
  noPuedeOrinar('(Gato macho) ¿Intenta orinar y no puede?');

  const RedFlagQuestion(this.question);

  final String question;
}

/// Respuesta posible. "No sé" nunca baja el nivel.
enum RedFlagAnswer {
  si,
  no,
  noSe;

  String get storageValue => name;
}
