/// Puerto (interfaz) del repositorio de cola.
library;

import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

abstract class QueueRepository {
  Future<Result<QueueEntry>> create(QueueEntry entry);

  Future<Result<QueueEntry?>> findById(String id);

  Future<Result<QueueEntry?>> findByVisitId(String visitId);

  Future<Result<List<QueueEntry>>> getPendingQueue({
    String? companyId,
  });

  Future<Result<QueueEntry>> update(QueueEntry entry);

  Future<Result<void>> assignRoomAndVeterinarian({
    required String queueEntryId,
    required String room,
    required String veterinarianId,
  });
}
