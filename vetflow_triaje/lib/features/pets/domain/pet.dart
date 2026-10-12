/// Mascota (docs/05-arquitectura/modelo-de-datos.md).
library;

import 'package:vetflow_triaje/core/domain/species.dart';

class Pet {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageMonths,
    this.sex,
    this.neutered,
    this.history,
    this.allergies,
  });

  final String id;
  final String ownerId;
  final String name;
  final Species species;
  final String breed;
  final int ageMonths;
  final String? sex;
  final bool? neutered;
  final String? history;
  final String? allergies;

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    Species? species,
    String? breed,
    int? ageMonths,
    String? sex,
    bool? neutered,
    String? history,
    String? allergies,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageMonths: ageMonths ?? this.ageMonths,
      sex: sex ?? this.sex,
      neutered: neutered ?? this.neutered,
      history: history ?? this.history,
      allergies: allergies ?? this.allergies,
    );
  }
}
