/// Caso de uso: asignar sala y veterinario a una entrada de cola.
library;

import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/queue/domain/port/queue_repository.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class AssignRoomAndVeterinarian {
  const AssignRoomAndVeterinarian({required this.queueRepository});

  final QueueRepository queueRepository;

  Future<Result<QueueEntry>> call({
    required String queueEntryId,
    required String room,
    required String veterinarianId,
  }) async {
    return queueRepository.assignRoomAndVeterinarian(
      queueEntryId: queueEntryId,
      room: room,
      veterinarianId: veterinarianId,
    );
  }
}
