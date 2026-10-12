/// Códec entre documentos de Firestore y [Pet].
///
/// La validación de tipos es espejo de firestore.rules: si el documento no
/// cumple, se descarta (protege también los datos de la caché offline).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/features/pets/domain/pet.dart';

class PetCodec {
  const PetCodec._();

  static Pet? fromMap(String id, Object? data) {
    if (data is! Map<String, Object?>) return null;
    final map = data;

    final name = map['name'];
    final ownerId = map['ownerId'];
    final breed = map['breed'];
    final ageMonths = map['ageMonths'];
    final speciesValue = map['species'];
    final createdAt = map['createdAt'];
    if (name is! String ||
        ownerId is! String ||
        breed is! String ||
        ageMonths is! int ||
        speciesValue is! String ||
        (createdAt != null && createdAt is! Timestamp)) {
      return null;
    }

    final species = switch (speciesValue) {
      'perro' => Species.perro,
      'gato' => Species.gato,
      _ => null,
    };
    if (species == null) return null;

    return Pet(
      id: id,
      ownerId: ownerId,
      name: name,
      species: species,
      breed: breed,
      ageMonths: ageMonths,
      sex: map['sex'] is String ? map['sex'] as String : null,
      neutered: map['neutered'] is bool ? map['neutered'] as bool : null,
      history: map['history'] is String ? map['history'] as String : null,
      allergies: map['allergies'] is String ? map['allergies'] as String : null,
    );
  }

  static Map<String, Object?> toMap(Pet pet, {required DateTime createdAt}) => {
        'ownerId': pet.ownerId,
        'name': pet.name,
        'species': pet.species.storageValue,
        'breed': pet.breed,
        'ageMonths': pet.ageMonths,
        'sex': pet.sex,
        'neutered': pet.neutered,
        'history': pet.history,
        'allergies': pet.allergies,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
