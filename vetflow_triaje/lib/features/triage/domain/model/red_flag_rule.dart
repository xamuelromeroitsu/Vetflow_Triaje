/// Regla de descarte (señal de alarma).
///
/// Un "sí" en cualquier pregunta de descarte lleva directo a Emergencia.
/// Parte del protocolo de triaje (borrador).
library;

class RedFlagRule {
  const RedFlagRule({
    required this.id,
    required this.question,
    required this.appliesTo, // null = todas las especies
  });

  final String id;
  final String question;
  final List<String>? appliesTo;

  bool appliesToSpecies(String? species) {
    if (appliesTo == null || appliesTo!.isEmpty) return true;
    if (species == null) return false;
    return appliesTo!.contains(species.toLowerCase());
  }
}
