/// Especies reconocidas por las reglas de triaje.
///
/// El alcance definitivo de especies del MVP está pendiente
/// (docs/07-gestion/preguntas-pendientes.md, pregunta 5). Estas son las que
/// aparecen en el borrador clínico.
library;

enum Species {
  perro,
  gato,
}

extension SpeciesX on Species {
  String get label => switch (this) {
        Species.perro => 'Perro',
        Species.gato => 'Gato',
      };

  /// Valor que se guarda en Firestore (docs/05-arquitectura/modelo-de-datos.md).
  String get storageValue => name;
}
