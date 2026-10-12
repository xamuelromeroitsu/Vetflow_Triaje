/// Categorías de síntomas (US-02).
library;

enum SymptomCategory {
  digestivo('Digestivo'),
  respiratorio('Respiratorio'),
  piel('Piel'),
  movimiento('Movimiento'),
  comportamiento('Comportamiento'),
  otro('Otro');

  const SymptomCategory(this.label);

  final String label;

  String get storageValue => name;
}
