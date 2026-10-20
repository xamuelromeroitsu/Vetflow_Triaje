/// Entrada de síntoma para el triaje.
///
/// Parte de EPC-01: captura de síntomas y signos vitales.
/// Las reglas clínicas de interpretación son borrador hasta validación
/// veterinaria (docs/03-triaje-clinico/).
library;

class SymptomEntry {
  const SymptomEntry({
    required this.category,
    required this.items,
    this.notes,
    this.since,
  });

  final String category;
  final List<String> items;
  final String? notes;
  final String? since;
}
