/// Caso de uso: atender el siguiente turno de la cola.
///
/// Marca la entrada como en_atencion y devuelve la entrada actualizada.
library;

import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/queue/domain/port/queue_repository.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class NextTurn {
  const NextTurn({required this.queueRepository});

  final QueueRepository queueRepository;

  Future<Result<QueueEntry>> call({required String queueEntryId}) async {
    final existing = await queueRepository.findById(queueEntryId);
    final entry = existing.valueOrNull;
    if (entry == null) {
      return Result.failure(
        const DomainError(message: 'Entrada de cola no encontrada'),
      );
    }

    if (entry.status != QueueStatus.pendiente) {
      return Result.failure(
        const DomainError(message: 'La entrada no está pendiente'),
      );
    }

    final updated = QueueEntry(
      id: entry.id,
      visitId: entry.visitId,
      petId: entry.petId,
      ownerId: entry.ownerId,
      triageLevel: entry.triageLevel,
      status: QueueStatus.enAtencion,
      assignedRoom: entry.assignedRoom,
      assignedVeterinarian: entry.assignedVeterinarian,
      position: entry.position,
      createdAt: entry.createdAt,
      updatedAt: DateTime.now(),
    );

    return queueRepository.update(updated);
  }
}
