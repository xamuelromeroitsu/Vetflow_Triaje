/// Caso de uso: obtener la cola ordenada por prioridad.
library;

import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/queue/domain/port/queue_repository.dart';
import 'package:vetflow_triaje/features/queue/domain/service/queue_service.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class GetQueue {
  const GetQueue({
    required this.queueRepository,
    required this.queueService,
  });

  final QueueRepository queueRepository;
  final QueueService queueService;

  Future<Result<List<QueueEntry>>> call({String? companyId}) async {
    final result = await queueRepository.getPendingQueue(
      companyId: companyId,
    );
    final entries = result.valueOrNull;
    if (entries == null) {
      return Result.failure(
        result.errorOrNull ??
            const Exception('No se pudo obtener la cola'),
      );
    }

    final ordered = queueService.orderByPriority(entries);
    final withPos = queueService.withPositions(ordered);
    return Result.ok(withPos);
  }
}
