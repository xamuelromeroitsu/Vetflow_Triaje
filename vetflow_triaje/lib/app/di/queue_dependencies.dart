/// Módulo de inyección de dependencias para cola.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/queue/application/use_case/assign_room_veterinarian.dart';
import 'package:vetflow_triaje/features/queue/application/use_case/get_queue.dart';
import 'package:vetflow_triaje/features/queue/application/use_case/next_turn.dart';
import 'package:vetflow_triaje/features/queue/application/use_case/watch_queue.dart';
import 'package:vetflow_triaje/features/queue/domain/port/queue_repository.dart';
import 'package:vetflow_triaje/features/queue/domain/service/queue_service.dart';
import 'package:vetflow_triaje/infrastructure/firebase/queue/firestore_queue_repository.dart';

class QueueModule {
  const QueueModule({
    required this.getQueue,
    required this.assignRoomAndVeterinarian,
    required this.nextTurn,
    required this.watchQueue,
  });

  factory QueueModule.create({FirebaseFirestore? firestore}) {
    final queueRepository = FirestoreQueueRepository(firestore: firestore);
    final queueService = QueueService();
    return QueueModule(
      getQueue: GetQueue(
        queueRepository: queueRepository,
        queueService: queueService,
      ),
      assignRoomAndVeterinarian: AssignRoomAndVeterinarian(
        queueRepository: queueRepository,
      ),
      nextTurn: NextTurn(queueRepository: queueRepository),
      watchQueue: WatchQueue(
        queueRepository: queueRepository,
        queueService: queueService,
      ),
    );
  }

  final GetQueue getQueue;
  final AssignRoomAndVeterinarian assignRoomAndVeterinarian;
  final NextTurn nextTurn;
  final WatchQueue watchQueue;
}
