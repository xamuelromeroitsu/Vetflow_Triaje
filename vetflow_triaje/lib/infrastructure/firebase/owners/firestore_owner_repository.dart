/// Adaptador de Firestore para [OwnerRepository].
///
/// Escribe y lee documentos en la colección `owners/{ownerId}`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/port/owner_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/owners/owner_mapper.dart';

class FirestoreOwnerRepository implements OwnerRepository {
  FirestoreOwnerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _owners =>
      _firestore.collection('owners');

  @override
  Future<Result<Owner>> create(Owner owner) async {
    try {
      final docRef = _owners.doc(owner.id.isEmpty ? owner.ownerId : owner.id);
      await docRef.set(OwnerMapper.toMap(owner));
      final saved = Owner(
        id: docRef.id,
        name: owner.name,
        phone: owner.phone,
        email: owner.email,
        ownerId: owner.ownerId,
        createdAt: owner.createdAt,
        updatedAt: owner.updatedAt,
      );
      return Result.ok(saved);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo crear el dueño',
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
  Future<Result<Owner?>> findById(String id) async {
    try {
      final doc = await _owners.doc(id).get();
      if (!doc.exists) {
        return Result.ok(null);
      }
      final owner = OwnerMapper.fromMap(doc.id, doc.data());
      if (owner == null) {
        return Result.failure(
          const DomainError(message: 'El dueño no se pudo leer'),
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
  Future<Result<Owner?>> findByPhone(String phone) async {
    try {
      final query = await _owners
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        return Result.ok(null);
      }
      final doc = query.docs.first;
      final owner = OwnerMapper.fromMap(doc.id, doc.data());
      if (owner == null) {
        return Result.failure(
          const DomainError(message: 'El dueño no se pudo leer'),
        );
      }
      return Result.ok(owner);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo buscar el dueño por teléfono',
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
  Future<Result<Owner>> update(Owner owner) async {
    try {
      await _owners.doc(owner.id).update(OwnerMapper.toMap(owner));
      return Result.ok(owner);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo actualizar el dueño',
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
}
