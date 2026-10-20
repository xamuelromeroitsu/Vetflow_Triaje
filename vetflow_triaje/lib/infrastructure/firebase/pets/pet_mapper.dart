/// Códec entre documentos de Firestore (pets/{petId}) y [Pet].
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';

class PetMapper {
  const PetMapper._();

  static Pet? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    final ownerId = data['ownerId'];
    final name = data['name'];
    final species = data['species'];
    final breed = data['breed'];
    final ageMonths = data['ageMonths'];
    if (ownerId is! String ||
        name is! String ||
        species is! String ||
        breed is! String ||
        ageMonths is! int) {
      return null;
    }

    return Pet(
      id: id,
      ownerId: ownerId,
      name: name,
      species: species,
      breed: breed,
      ageMonths: ageMonths,
      sex: data['sex'] is String ? data['sex'] : null,
      neutered: data['neutered'] is bool ? data['neutered'] : null,
      history: data['history'] is String ? data['history'] : null,
      allergies: data['allergies'] is String ? data['allergies'] : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toMap(Pet pet) => {
        'ownerId': pet.ownerId,
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'ageMonths': pet.ageMonths,
        if (pet.sex != null) 'sex': pet.sex,
        if (pet.neutered != null) 'neutered': pet.neutered,
        if (pet.history != null) 'history': pet.history,
        if (pet.allergies != null) 'allergies': pet.allergies,
        if (pet.createdAt != null) 'createdAt': pet.createdAt,
        if (pet.updatedAt != null) 'updatedAt': pet.updatedAt,
      };
}
