/// Adaptador de Firestore para [PetRepository].
///
/// Capa de datos: el dominio no la conoce. Se inyecta desde la app.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/pets/data/pet_codec.dart';
import 'package:vetflow_triaje/features/pets/domain/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/pet_repository.dart';

class PetRepositoryFirestore implements PetRepository {
  PetRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('pets');

  @override
  Future<Result<Pet>> create(Pet pet) async {
    try {
      final doc = pet.id.isEmpty ? _pets.doc() : _pets.doc(pet.id);
      final saved = pet.copyWith(id: doc.id);
      await doc.set(
        PetCodec.toMap(saved, createdAt: DateTime.now()),
      );
      return Result.ok(saved);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo guardar la mascota',
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
  Future<Result<Pet>> getById(String petId) async {
    try {
      final doc = await _pets.doc(petId).get();
      final pet = PetCodec.fromMap(petId, doc.data());
      if (pet == null) {
        return Result.failure(
          const DomainError(message: 'La mascota no existe'),
        );
      }
      return Result.ok(pet);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo leer la mascota',
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
  Future<Result<List<Pet>>> byOwner(String ownerId) async {
    try {
      final snapshot =
          await _pets.where('ownerId', isEqualTo: ownerId).get();
      return Result.ok(
        snapshot.docs
            .map((doc) => PetCodec.fromMap(doc.id, doc.data()))
            .whereType<Pet>()
            .toList(),
      );
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudieron leer las mascotas',
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
  Stream<List<Pet>> watchByOwner(String ownerId) {
    return _pets.where('ownerId', isEqualTo: ownerId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => PetCodec.fromMap(doc.id, doc.data()))
              .whereType<Pet>()
              .toList(),
        );
  }
}
