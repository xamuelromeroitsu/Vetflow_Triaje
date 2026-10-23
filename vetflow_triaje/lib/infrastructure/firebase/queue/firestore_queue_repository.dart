/// Adaptador de Firestore para [QueueRepository].
///
/// Lee y escribe entradas de cola en la colección `visits/{visitId}`
/// usando los campos `triage`, `status`, `assignedRoom`, `assignedVeterinarian`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/queue/domain/model/queue_status.dart';
import 'package:vetflow_triaje/features/queue/domain/port/queue_repository.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class FirestoreQueueRepository implements QueueRepository {
  FirestoreQueueRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _visits =>
      _firestore.collection('visits');

  QueueEntry _docToEntry(String docId, Map<String, dynamic> data) {
    final triageMap = data['triage'] as Map? ?? {};
    final levelValue = triageMap['suggested'] as String? ?? 'consulta';
    final statusValue = data['status'] as String? ?? 'pendiente';

    return QueueEntry(
      id: docId,
      visitId: docId,
      petId: data['petId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      triageLevel: _parseLevel(levelValue),
      status: _parseStatus(statusValue),
      assignedRoom: data['assignedRoom'] as String?,
      assignedVeterinarian: data['assignedVeterinarian'] as String?,
      position: data['position'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  TriageLevel _parseLevel(String? value) {
    switch (value) {
      case 'emergencia':
        return TriageLevel.emergencia;
      case 'urgencia':
        return TriageLevel.urgencia;
      default:
        return TriageLevel.consulta;
    }
  }

  QueueStatus _parseStatus(String? value) {
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

  @override
  Future<Result<QueueEntry>> create(QueueEntry entry) async {
    try {
      final docRef = _visits.doc(entry.id.isEmpty ? _generateId() : entry.id);
      await docRef.set({
        'petId': entry.petId,
        'ownerId': entry.ownerId,
        'status': entry.status.value,
        'triage': {
          'suggested': entry.triageLevel.value,
          'confirmed': null,
          'reasons': <String>[],
          'rulesVersion': '0.2',
        },
        'assignedRoom': entry.assignedRoom,
        'assignedVeterinarian': entry.assignedVeterinarian,
        'position': entry.position,
        'createdAt': entry.createdAt,
        'updatedAt': entry.updatedAt,
      });
      return Result.ok(entry.copyWith(id: docRef.id));
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo crear la entrada de cola',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<QueueEntry?>> findById(String id) async {
    try {
      final doc = await _visits.doc(id).get();
      if (!doc.exists) return Result.ok(null);
      return Result.ok(_docToEntry(doc.id, doc.data()!));
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo leer la entrada de cola',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<QueueEntry?>> findByVisitId(String visitId) async {
    return findById(visitId);
  }

  @override
  Future<Result<List<QueueEntry>>> getPendingQueue({
    String? companyId,
  }) async {
    try {
      var query = _visits.where('status', isEqualTo: QueueStatus.pendiente.value);

      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }

      final snapshot = await query.get();
      final entries = <QueueEntry>[];
      for (final doc in snapshot.docs) {
        entries.add(_docToEntry(doc.id, doc.data()));
      }
      return Result.ok(entries);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo obtener la cola pendiente',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Stream<Result<List<QueueEntry>>> watchPendingQueue({
    String? companyId,
  }) {
    var query = _visits.where('status', isEqualTo: QueueStatus.pendiente.value);

    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    }

    return query.snapshots().map((snapshot) {
      final entries = <QueueEntry>[];
      for (final doc in snapshot.docs) {
        entries.add(_docToEntry(doc.id, doc.data()));
      }
      return Result.ok(entries);
    });
  }

  @override
  Future<Result<QueueEntry>> update(QueueEntry entry) async {
    try {
      await _visits.doc(entry.id).update({
        'status': entry.status.value,
        'assignedRoom': entry.assignedRoom,
        'assignedVeterinarian': entry.assignedVeterinarian,
        'position': entry.position,
        'updatedAt': entry.updatedAt,
      });
      return Result.ok(entry);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo actualizar la entrada de cola',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<void>> assignRoomAndVeterinarian({
    required String queueEntryId,
    required String room,
    required String veterinarianId,
  }) async {
    try {
      await _visits.doc(queueEntryId).update({
        'assignedRoom': room,
        'assignedVeterinarian': veterinarianId,
        'updatedAt': DateTime.now(),
      });
      return const Result.ok(null);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo asignar sala y veterinario',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}

/// Extensión para permitir copiar una entrada con nuevo id.
extension QueueEntryCopy on QueueEntry {
  QueueEntry copyWith({String? id}) => QueueEntry(
        id: id ?? this.id,
        visitId: visitId,
        petId: petId,
        ownerId: ownerId,
        triageLevel: triageLevel,
        status: status,
        assignedRoom: assignedRoom,
        assignedVeterinarian: assignedVeterinarian,
        position: position,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
