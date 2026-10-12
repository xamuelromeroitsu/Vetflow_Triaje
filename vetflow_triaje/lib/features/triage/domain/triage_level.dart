/// Nivel de triaje sugerido o confirmado.
///
/// Regla de producto: el nivel **nunca** se comunica solo con color;
/// siempre icono + texto (docs/01-producto + protocolo de triaje).
library;

enum TriageLevel {
  emergencia,
  urgencia,
  consulta,
}

extension TriageLevelX on TriageLevel {
  String get label => switch (this) {
        TriageLevel.emergencia => 'Emergencia',
        TriageLevel.urgencia => 'Urgencia',
        TriageLevel.consulta => 'Consulta',
      };

  /// Icono obligatorio junto al color.
  String get icon => switch (this) {
        TriageLevel.emergencia => '🔴',
        TriageLevel.urgencia => '🟠',
        TriageLevel.consulta => '🟢',
      };

  int get severity => switch (this) {
        TriageLevel.emergencia => 3,
        TriageLevel.urgencia => 2,
        TriageLevel.consulta => 1,
      };

  /// Qué se le dice al dueño (protocolo de triaje).
  String get adviceToOwner => switch (this) {
        TriageLevel.emergencia => 'Ve ya a una clínica',
        TriageLevel.urgencia => 'Debe ser atendido hoy',
        TriageLevel.consulta => 'Agenda una cita',
      };

  /// Sube un nivel sin pasarse de emergencia. Nunca baja.
  TriageLevel get raised => switch (this) {
        TriageLevel.emergencia => TriageLevel.emergencia,
        TriageLevel.urgencia => TriageLevel.emergencia,
        TriageLevel.consulta => TriageLevel.urgencia,
      };

  static TriageLevel fromStorage(String value) => switch (value) {
        'emergencia' => TriageLevel.emergencia,
        'urgencia' => TriageLevel.urgencia,
        'consulta' => TriageLevel.consulta,
        _ => throw ArgumentError.value(value, 'value', 'Nivel de triaje desconocido'),
      };
}

/// Devuelve el nivel más alto de los dos.
TriageLevel maxLevel(TriageLevel a, TriageLevel b) =>
    a.severity >= b.severity ? a : b;
