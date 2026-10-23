/// Caso de uso: observar la cola pendiente en tiempo real.
library;

import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/queue/domain/port/queue_repository.dart';
import 'package:vetflow_triaje/features/queue/domain/service/queue_service.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class WatchQueue {
  const WatchQueue({
    required this.queueRepository,
    required this.queueService,
  });

  final QueueRepository queueRepository;
  final QueueService queueService;

  Stream<Result<List<QueueEntry>>> call({String? companyId}) {
    return queueRepository.watchPendingQueue(companyId: companyId).map(
          (result) => result.when(
            ok: (entries) {
              final ordered = queueService.orderByPriority(entries);
              final withPos = queueService.withPositions(ordered);
              return Result.ok(withPos);
            },
            failure: (error) => Result.failure(error),
          ),
        );
  }
}
