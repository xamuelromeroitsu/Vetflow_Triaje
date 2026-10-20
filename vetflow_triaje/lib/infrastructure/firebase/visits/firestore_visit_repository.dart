/// Adaptador de Firestore para [VisitRepository].
///
/// Escribe y lee documentos en la colección `visits/{visitId}`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/visits/visit_mapper.dart';

class FirestoreVisitRepository implements VisitRepository {
  FirestoreVisitRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _visits =>
      _firestore.collection('visits');

  @override
  Future<Result<Visit>> create(Visit visit) async {
    try {
      final docRef = _visits.doc(visit.id.isEmpty ? _generateId() : visit.id);
      await docRef.set(VisitMapper.toMap(visit));
      final saved = Visit(
        id: docRef.id,
        petId: visit.petId,
        companyId: visit.companyId,
        redFlags: visit.redFlags,
        symptoms: visit.symptoms,
        vitals: visit.vitals,
        photos: visit.photos,
        triage: visit.triage,
        status: visit.status,
        createdAt: visit.createdAt,
        updatedAt: visit.updatedAt,
      );
      return Result.ok(saved);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo crear la visita',
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
  Future<Result<Visit?>> findById(String id) async {
    try {
      final doc = await _visits.doc(id).get();
      if (!doc.exists) {
        return Result.ok(null);
      }
      final visit = VisitMapper.fromMap(doc.id, doc.data());
      if (visit == null) {
        return Result.failure(
          const DomainError(message: 'La visita no se pudo leer'),
        );
      }
      return Result.ok(visit);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo leer la visita',
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
  Future<Result<Visit>> update(Visit visit) async {
    try {
      await _visits.doc(visit.id).update(VisitMapper.toMap(visit));
      return Result.ok(visit);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo actualizar la visita',
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

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
