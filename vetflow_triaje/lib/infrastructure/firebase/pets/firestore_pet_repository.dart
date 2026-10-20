/// Adaptador de Firestore para [PetRepository].
///
/// Escribe y lee documentos en la colección `pets/{petId}`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/pets/pet_mapper.dart';

class FirestorePetRepository implements PetRepository {
  FirestorePetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('pets');

  @override
  Future<Result<Pet>> create(Pet pet) async {
    try {
      final docRef = _pets.doc(pet.id.isEmpty ? _generateId() : pet.id);
      await docRef.set(PetMapper.toMap(pet));
      final saved = Pet(
        id: docRef.id,
        ownerId: pet.ownerId,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        ageMonths: pet.ageMonths,
        sex: pet.sex,
        neutered: pet.neutered,
        history: pet.history,
        allergies: pet.allergies,
        createdAt: pet.createdAt,
        updatedAt: pet.updatedAt,
      );
      return Result.ok(saved);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo crear la mascota',
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
  Future<Result<Pet?>> findById(String id) async {
    try {
      final doc = await _pets.doc(id).get();
      if (!doc.exists) {
        return Result.ok(null);
      }
      final pet = PetMapper.fromMap(doc.id, doc.data());
      if (pet == null) {
        return Result.failure(
          const DomainError(message: 'La mascota no se pudo leer'),
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
  Future<Result<List<Pet>>> findByOwnerId(String ownerId) async {
    try {
      final query = await _pets
          .where('ownerId', isEqualTo: ownerId)
          .get();
      final pets = <Pet>[];
      for (final doc in query.docs) {
        final pet = PetMapper.fromMap(doc.id, doc.data());
        if (pet != null) {
          pets.add(pet);
        }
      }
      return Result.ok(pets);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudieron listar las mascotas',
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
  Future<Result<Pet>> update(Pet pet) async {
    try {
      await _pets.doc(pet.id).update(PetMapper.toMap(pet));
      return Result.ok(pet);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo actualizar la mascota',
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
    // Usar el ID generado por el cliente o un UUID simple.
    // En producción, este puerto debería delegar en IdGenerator.
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
