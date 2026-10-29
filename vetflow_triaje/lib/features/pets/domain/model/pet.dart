/// Entidad de dominio: mascota.
library;

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
    this.weightKg,
    this.history,
    this.allergies,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int ageMonths;
  final String? sex;
  final bool? neutered;
  final double? weightKg;
  final String? history;
  final String? allergies;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
