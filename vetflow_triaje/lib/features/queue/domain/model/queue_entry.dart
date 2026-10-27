/// Entrada de la cola de atención.
///
/// Ordenada por nivel de triaje (mayor gravedad primero) y fecha de creación.
library;

import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

/// Estado de una entrada de la cola de atención.
enum QueueStatus {
  pendiente,
  enAtencion,
  atendido,
  cancelado,
}

extension QueueStatusX on QueueStatus {
  String get value => switch (this) {
        QueueStatus.pendiente => 'pendiente',
        QueueStatus.enAtencion => 'en_atencion',
        QueueStatus.atendido => 'atendido',
        QueueStatus.cancelado => 'cancelado',
      };

  String get label => switch (this) {
        QueueStatus.pendiente => 'Pendiente',
        QueueStatus.enAtencion => 'En atención',
        QueueStatus.atendido => 'Atendido',
        QueueStatus.cancelado => 'Cancelado',
      };
}

class QueueEntry {
  const QueueEntry({
    required this.id,
    required this.visitId,
    required this.petId,
    required this.ownerId,
    required this.triageLevel,
    required this.status,
    this.assignedRoom,
    this.assignedVeterinarian,
    this.position,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String visitId;
  final String petId;
  final String ownerId;
  final TriageLevel triageLevel;
  final QueueStatus status;
  final String? assignedRoom;
  final String? assignedVeterinarian;
  final int? position;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Nivel numérico para ordenar (mayor = más grave).
  int get priorityValue => triageLevel.value;
}
