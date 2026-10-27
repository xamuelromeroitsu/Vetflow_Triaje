/// Repositorios locales para pruebas del flujo sin Firebase.
///
/// Mantienen el comportamiento principal del dominio para que la UI pueda
/// revisarse sin depender de creds reales ni de Firestore.
library;

import 'package:vetflow_triaje/features/auth/domain/model/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/port/user_profile_repository.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/port/owner_repository.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository()
    : _currentAccount = AuthAccount(
        uid: 'demo-owner',
        email: 'demo@vetflow.local',
      );

  AuthAccount? _currentAccount;

  @override
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _currentAccount = AuthAccount(
      uid: 'demo-${normalizedEmail.hashCode.abs()}',
      email: normalizedEmail,
    );
    return Result.ok(_currentAccount!);
  }

  @override
  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _currentAccount = AuthAccount(
      uid: 'demo-${normalizedEmail.hashCode.abs()}',
      email: normalizedEmail,
    );
    return Result.ok(_currentAccount!);
  }

  @override
  Future<Result<void>> signOut() async {
    _currentAccount = null;
    return Result<void>.ok(null);
  }

  @override
  AuthAccount? get currentAccount => _currentAccount;

  @override
  Stream<AuthAccount?> authStateChanges() => Stream.value(_currentAccount);
}

class DemoUserProfileRepository implements UserProfileRepository {
  final Map<String, UserProfile> _profiles = {};

  @override
  Future<Result<UserProfile>> getByUid(String uid) async {
    final profile = _profiles[uid];
    if (profile == null) {
      return Result.failure(
        DomainError(message: 'Perfil no encontrado para $uid'),
      );
    }
    return Result.ok(profile);
  }

  @override
  Stream<UserProfile?> watchByUid(String uid) => Stream.value(_profiles[uid]);

  @override
  Future<Result<UserProfile>> create(UserProfile profile) async {
    final nextProfile = UserProfile(
      uid: profile.uid,
      email: profile.email,
      role: profile.role,
      ownerId: profile.ownerId,
      companyId: profile.companyId,
      createdAt: profile.createdAt ?? DateTime.now(),
    );
    _profiles[nextProfile.uid] = nextProfile;
    return Result.ok(nextProfile);
  }
}

class DemoOwnerRepository implements OwnerRepository {
  final Map<String, Owner> _owners = {};

  @override
  Future<Result<Owner>> create(Owner owner) async {
    final stored = Owner(
      id: owner.id,
      name: owner.name,
      phone: owner.phone,
      email: owner.email,
      ownerId: owner.ownerId,
      createdAt: owner.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _owners[stored.id] = stored;
    return Result.ok(stored);
  }

  @override
  Future<Result<Owner?>> findById(String id) async {
    return Result.ok(_owners[id]);
  }

  @override
  Future<Result<Owner?>> findByPhone(String phone) async {
    for (final owner in _owners.values) {
      if (owner.phone == phone) {
        return Result.ok(owner);
      }
    }
    return Result.ok(null);
  }

  @override
  Future<Result<Owner>> update(Owner owner) async {
    final updated = Owner(
      id: owner.id,
      name: owner.name,
      phone: owner.phone,
      email: owner.email,
      ownerId: owner.ownerId,
      createdAt: owner.createdAt,
      updatedAt: DateTime.now(),
    );
    _owners[updated.id] = updated;
    return Result.ok(updated);
  }
}

class DemoPetRepository implements PetRepository {
  final Map<String, Pet> _pets = {};

  @override
  Future<Result<Pet>> create(Pet pet) async {
    final id = pet.id.isNotEmpty
        ? pet.id
        : 'pet-${DateTime.now().microsecondsSinceEpoch}';
    final stored = Pet(
      id: id,
      ownerId: pet.ownerId,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      ageMonths: pet.ageMonths,
      sex: pet.sex,
      neutered: pet.neutered,
      weightKg: pet.weightKg,
      history: pet.history,
      allergies: pet.allergies,
      createdAt: pet.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _pets[stored.id] = stored;
    return Result.ok(stored);
  }

  @override
  Future<Result<Pet?>> findById(String id) async {
    return Result.ok(_pets[id]);
  }

  @override
  Future<Result<List<Pet>>> findByOwnerId(String ownerId) async {
    return Result.ok(
      _pets.values.where((pet) => pet.ownerId == ownerId).toList(),
    );
  }

  @override
  Future<Result<Pet>> update(Pet pet) async {
    final updated = Pet(
      id: pet.id,
      ownerId: pet.ownerId,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      ageMonths: pet.ageMonths,
      sex: pet.sex,
      neutered: pet.neutered,
      weightKg: pet.weightKg,
      history: pet.history,
      allergies: pet.allergies,
      createdAt: pet.createdAt,
      updatedAt: DateTime.now(),
    );
    _pets[updated.id] = updated;
    return Result.ok(updated);
  }
}
