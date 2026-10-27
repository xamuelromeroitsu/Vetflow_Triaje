/// Servicio de ordenación de la cola.
///
/// Ordena las entradas por prioridad (nivel de triaje) y fecha de creación.
/// El nivel de triaje nunca baja: los casos más graves van primero.
library;

import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

class QueueService {
  const QueueService();

  /// Ordena la cola pendiente por prioridad descendente y fecha ascendente.
  List<QueueEntry> orderByPriority(List<QueueEntry> entries) {
    final sorted = List<QueueEntry>.from(entries);
    sorted.sort((a, b) {
      // Mayor nivel de triaje primero (más grave = primero).
      int levelValue(TriageLevel l) {
        if (l == TriageLevel.emergencia) return 3;
        if (l == TriageLevel.urgencia) return 2;
        if (l == TriageLevel.consulta) return 1;
        return 0;
      }
      final levelComparison = levelValue(b.triageLevel).compareTo(levelValue(a.triageLevel));
      if (levelComparison != 0) return levelComparison;
      // Mismo nivel: más antiguo primero.
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  /// Asigna posiciones numeradas a la cola ordenada.
  List<QueueEntry> withPositions(List<QueueEntry> orderedEntries) {
    final result = <QueueEntry>[];
    for (var i = 0; i < orderedEntries.length; i++) {
      final entry = orderedEntries[i];
      result.add(
        QueueEntry(
          id: entry.id,
          visitId: entry.visitId,
          petId: entry.petId,
          ownerId: entry.ownerId,
          triageLevel: entry.triageLevel,
          status: entry.status,
          assignedRoom: entry.assignedRoom,
          assignedVeterinarian: entry.assignedVeterinarian,
          position: i + 1,
          createdAt: entry.createdAt,
          updatedAt: entry.updatedAt,
        ),
      );
    }
    return result;
  }
}
