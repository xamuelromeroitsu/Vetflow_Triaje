/// Códec entre documentos de Firestore (visits/{visitId}) y [QueueEntry].
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

class QueueMapper {
  const QueueMapper._();

  static QueueEntry? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    final petId = data['petId'];
    final ownerId = data['ownerId'];
    if (petId is! String || ownerId is! String) return null;

    final triageMap = data['triage'] as Map? ?? {};
    final levelValue = triageMap['suggested'] as String?;

    return QueueEntry(
      id: id,
      visitId: id,
      petId: petId,
      ownerId: ownerId,
      triageLevel: _parseLevel(levelValue),
      status: _parseStatus(data['status'] as String?),
      assignedRoom: data['assignedRoom'] as String?,
      assignedVeterinarian: data['assignedVeterinarian'] as String?,
      position: data['position'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toMap(QueueEntry entry) => {
        'petId': entry.petId,
        'ownerId': entry.ownerId,
        'status': entry.status.value,
        'triage': {
          'suggested': entry.triageLevel.value,
        },
        if (entry.assignedRoom != null)
          'assignedRoom': entry.assignedRoom,
        if (entry.assignedVeterinarian != null)
          'assignedVeterinarian': entry.assignedVeterinarian,
        if (entry.position != null) 'position': entry.position,
        if (entry.createdAt != null) 'createdAt': entry.createdAt,
        if (entry.updatedAt != null) 'updatedAt': entry.updatedAt,
      };

  static TriageLevel _parseLevel(String? value) {
    switch (value) {
      case 'emergencia':
        return TriageLevel.emergencia;
      case 'urgencia':
        return TriageLevel.urgencia;
      default:
        return TriageLevel.consulta;
    }
  }

  static QueueStatus _parseStatus(String? value) {
    switch (value) {
      case 'en_atencion':
        return QueueStatus.enAtencion;
      case 'atendido':
        return QueueStatus.atendido;
      case 'cancelado':
        return QueueStatus.cancelado;
      default:
        return QueueStatus.pendiente;
    }
  }
}
