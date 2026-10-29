/// Nivel de triaje veterinario.
///
/// Niveles: Emergencia (🔴), Urgencia (🟠), Consulta (🟢).
/// El orden numérico indica gravedad: mayor número = mayor prioridad.
library;

enum TriageLevel {
  consulta,
  urgencia,
  emergencia,
}

extension TriageLevelX on TriageLevel {
  /// Valor numérico para comparar y ordenar (mayor = más grave).
  int get value => switch (this) {
        TriageLevel.consulta => 1,
        TriageLevel.urgencia => 2,
        TriageLevel.emergencia => 3,
      };

  /// Icono asociado al nivel (nunca solo color).
  String get icon => switch (this) {
        TriageLevel.consulta => '🟢',
        TriageLevel.urgencia => '🟠',
        TriageLevel.emergencia => '🔴',
      };

  /// Texto legible para el dueño.
  String get label => switch (this) {
        TriageLevel.consulta => 'Consulta',
        TriageLevel.urgencia => 'Urgencia',
        TriageLevel.emergencia => 'Emergencia',
      };

  /// Qué se le comunica al dueño (texto del protocolo).
  String get message => switch (this) {
        TriageLevel.consulta => 'Sin riesgo inmediato. Agenda una cita.',
        TriageLevel.urgencia => 'Necesita atención pronto. Debe ser atendido hoy.',
        TriageLevel.emergencia => 'Riesgo de vida. Ve ya a una clínica.',
      };

  /// Devuelve el nivel de mayor gravedad entre dos.
  static TriageLevel max(TriageLevel a, TriageLevel b) =>
      a.value >= b.value ? a : b;

  /// Devuelve el nivel de mayor gravedad de una lista.
  static TriageLevel maxOf(List<TriageLevel> levels) {
    if (levels.isEmpty) return TriageLevel.consulta;
    return levels.fold<TriageLevel>(
      TriageLevel.consulta,
      (current, next) => max(current, next),
    );
  }
}

/// Estado de validación clínica de una especie.
enum SpeciesClinicalState {
  validated,
  pendingVet,
}

extension SpeciesClinicalStateX on SpeciesClinicalState {
  String get value => switch (this) {
        SpeciesClinicalState.validated => 'validated',
        SpeciesClinicalState.pendingVet => 'pendingVet',
      };
}
