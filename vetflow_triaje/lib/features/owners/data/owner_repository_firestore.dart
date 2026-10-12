/// Adaptador de Firestore para [OwnerRepository].
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/owners/data/owner_codec.dart';
import 'package:vetflow_triaje/features/owners/domain/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/owner_repository.dart';

class OwnerRepositoryFirestore implements OwnerRepository {
  OwnerRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _owners =>
      _firestore.collection('owners');

  @override
  Future<Result<Owner>> create(Owner owner) async {
    try {
      final doc = owner.id.isEmpty ? _owners.doc() : _owners.doc(owner.id);
      final saved = Owner(
        id: doc.id,
        name: owner.name,
        phone: owner.phone,
        email: owner.email,
        createdAt: owner.createdAt ?? DateTime.now(),
      );
      await doc.set(OwnerCodec.toMap(saved));
      return Result.ok(saved);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo guardar el dueño',
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
  Future<Result<Owner>> getById(String ownerId) async {
    try {
      final doc = await _owners.doc(ownerId).get();
      final owner = OwnerCodec.fromMap(ownerId, doc.data());
      if (owner == null) {
        return Result.failure(
          const DomainError(message: 'El dueño no existe'),
        );
      }
      return Result.ok(owner);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo leer el dueño',
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
  Stream<Owner?> watchById(String ownerId) {
    return _owners.doc(ownerId).snapshots().map(
          (doc) => OwnerCodec.fromMap(ownerId, doc.data()),
        );
  }
}
