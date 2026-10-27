import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetflow_triaje/features/auth/domain/model/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_role.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/port/user_profile_repository.dart';
import 'package:vetflow_triaje/features/clinics/domain/model/clinic.dart';
import 'package:vetflow_triaje/features/clinics/domain/port/clinic_repository.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/port/owner_repository.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';
import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/queue/domain/port/queue_repository.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

DomainError _repositoryError(String operation, String source, Object error) {
  final code = switch (error) {
    PostgrestException(:final code) => code ?? 'database_error',
    AuthException(:final statusCode) => statusCode ?? 'auth_error',
    StorageException(:final statusCode) => statusCode ?? 'storage_error',
    _ => error.runtimeType.toString(),
  };
  return DomainError(
    message: operation,
    fields: [
      FieldError(
        field: source,
        code: FieldErrorCode.invalid,
        message: '$code: $error',
      ),
    ],
  );
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

String? _string(Object? value) => value is String ? value : null;

Map<String, dynamic>? _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

List<String> _strings(Object? value) =>
    value is List ? value.whereType<String>().toList() : <String>[];

Map<String, dynamic> _profileMap(UserProfile profile) => {
  'id': profile.uid,
  'email': profile.email,
  'role': profile.role.storageValue,
  'owner_id': profile.ownerId,
  'company_id': profile.companyId,
  if (profile.createdAt != null)
    'created_at': profile.createdAt!.toUtc().toIso8601String(),
};

UserProfile? _profileFromMap(Map<String, dynamic>? row) {
  if (row == null) return null;
  final uid = row['id'];
  final email = row['email'];
  final role = switch (row['role']) {
    'dueno' => UserRole.dueno,
    'personal' => UserRole.personal,
    _ => null,
  };
  if (uid is! String || email is! String || role == null) return null;
  return UserProfile(
    uid: uid,
    email: email,
    role: role,
    ownerId: _string(row['owner_id']),
    companyId: _string(row['company_id']),
    createdAt: _date(row['created_at']),
  );
}

class SupabaseUserProfileMapper {
  const SupabaseUserProfileMapper._();

  static Map<String, dynamic> toMap(UserProfile profile) =>
      _profileMap(profile);

  static UserProfile? fromMap(Map<String, dynamic>? row) =>
      _profileFromMap(row);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  AuthAccount _account(User user) =>
      AuthAccount(uid: user.id, email: user.email ?? '');

  @override
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return Result.failure(
          const DomainError(message: 'Supabase no devolvió el usuario creado'),
        );
      }
      if (response.session == null) {
        return Result.failure(
          const DomainError(
            message:
                'Cuenta creada. Confirma tu correo para poder iniciar sesión.',
          ),
        );
      }
      return Result.ok(_account(user));
    } on AuthException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo crear la cuenta', 'auth', error),
      );
    }
  }

  @override
  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return Result.failure(
          const DomainError(message: 'Supabase no devolvió el usuario'),
        );
      }
      return Result.ok(_account(user));
    } on AuthException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo iniciar sesión', 'auth', error),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await client.auth.signOut();
      return Result<void>.ok(null);
    } on AuthException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo cerrar la sesión', 'auth', error),
      );
    }
  }

  @override
  AuthAccount? get currentAccount {
    final user = client.auth.currentUser;
    return user == null ? null : _account(user);
  }

  @override
  Stream<AuthAccount?> authStateChanges() => client.auth.onAuthStateChange.map(
    (state) =>
        state.session?.user == null ? null : _account(state.session!.user),
  );
}

class SupabaseUserProfileRepository implements UserProfileRepository {
  SupabaseUserProfileRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  @override
  Future<Result<UserProfile>> getByUid(String uid) async {
    try {
      final row = await client
          .from('user_profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      final profile = _profileFromMap(row);
      if (profile == null) {
        return Result.failure(
          const DomainError(message: 'El perfil no existe o no es válido'),
        );
      }
      return Result.ok(profile);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo leer el perfil', 'database', error),
      );
    }
  }

  @override
  Stream<UserProfile?> watchByUid(String uid) => client
      .from('user_profiles')
      .stream(primaryKey: ['id'])
      .eq('id', uid)
      .map((rows) => rows.isEmpty ? null : _profileFromMap(rows.first));

  @override
  Future<Result<UserProfile>> create(UserProfile profile) async {
    try {
      final row = await client
          .from('user_profiles')
          .upsert(_profileMap(profile), onConflict: 'id')
          .select()
          .single();
      final saved = _profileFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'El perfil guardado no es válido'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo guardar el perfil', 'database', error),
      );
    }
  }
}

Map<String, dynamic> _ownerMap(Owner owner) => {
  if (owner.id.isNotEmpty) 'id': owner.id,
  'owner_id': owner.ownerId,
  'name': owner.name,
  'phone': owner.phone,
  'email': owner.email,
  if (owner.createdAt != null)
    'created_at': owner.createdAt!.toUtc().toIso8601String(),
  if (owner.updatedAt != null)
    'updated_at': owner.updatedAt!.toUtc().toIso8601String(),
};

Owner? _ownerFromMap(Map<String, dynamic>? row) {
  if (row == null ||
      row['id'] is! String ||
      row['name'] is! String ||
      row['phone'] is! String ||
      row['owner_id'] is! String) {
    return null;
  }
  return Owner(
    id: row['id'] as String,
    ownerId: row['owner_id'] as String,
    name: row['name'] as String,
    phone: row['phone'] as String,
    email: _string(row['email']),
    createdAt: _date(row['created_at']),
    updatedAt: _date(row['updated_at']),
  );
}

class SupabaseOwnerRepository implements OwnerRepository {
  SupabaseOwnerRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  @override
  Future<Result<Owner>> create(Owner owner) async {
    try {
      final id = owner.id.isNotEmpty ? owner.id : owner.ownerId;
      final row = await client
          .from('owners')
          .upsert({..._ownerMap(owner), 'id': id}, onConflict: 'id')
          .select()
          .single();
      final saved = _ownerFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'El dueño guardado no es válido'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo crear el dueño', 'database', error),
      );
    }
  }

  @override
  Future<Result<Owner?>> findById(String id) async {
    try {
      final row = await client
          .from('owners')
          .select()
          .eq('id', id)
          .maybeSingle();
      final owner = row == null ? null : _ownerFromMap(row);
      if (row != null && owner == null) {
        return Result.failure(
          const DomainError(message: 'El dueño no se pudo leer'),
        );
      }
      return Result.ok(owner);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo leer el dueño', 'database', error),
      );
    }
  }

  @override
  Future<Result<Owner?>> findByPhone(String phone) async {
    try {
      final row = await client
          .from('owners')
          .select()
          .eq('phone', phone)
          .maybeSingle();
      final owner = row == null ? null : _ownerFromMap(row);
      if (row != null && owner == null) {
        return Result.failure(
          const DomainError(message: 'El dueño no se pudo leer'),
        );
      }
      return Result.ok(owner);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError(
          'No se pudo buscar el dueño por teléfono',
          'database',
          error,
        ),
      );
    }
  }

  @override
  Future<Result<Owner>> update(Owner owner) async {
    try {
      final row = await client
          .from('owners')
          .update(_ownerMap(owner))
          .eq('id', owner.id)
          .select()
          .single();
      final saved = _ownerFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'El dueño actualizado no es válido'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo actualizar el dueño', 'database', error),
      );
    }
  }
}

Map<String, dynamic> _petMap(Pet pet) => {
  if (pet.id.isNotEmpty) 'id': pet.id,
  'owner_id': pet.ownerId,
  'name': pet.name,
  'species': pet.species,
  'breed': pet.breed,
  'age_months': pet.ageMonths,
  'sex': pet.sex,
  'neutered': pet.neutered,
  'weight_kg': pet.weightKg,
  'history': pet.history,
  'allergies': pet.allergies,
  if (pet.createdAt != null)
    'created_at': pet.createdAt!.toUtc().toIso8601String(),
  if (pet.updatedAt != null)
    'updated_at': pet.updatedAt!.toUtc().toIso8601String(),
};

Pet? _petFromMap(Map<String, dynamic>? row) {
  if (row == null ||
      row['id'] is! String ||
      row['owner_id'] is! String ||
      row['name'] is! String ||
      row['species'] is! String ||
      row['breed'] is! String ||
      row['age_months'] is! int) {
    return null;
  }
  return Pet(
    id: row['id'] as String,
    ownerId: row['owner_id'] as String,
    name: row['name'] as String,
    species: row['species'] as String,
    breed: row['breed'] as String,
    ageMonths: row['age_months'] as int,
    sex: _string(row['sex']),
    neutered: row['neutered'] is bool ? row['neutered'] as bool : null,
    weightKg: row['weight_kg'] is num
        ? (row['weight_kg'] as num).toDouble()
        : null,
    history: _string(row['history']),
    allergies: _string(row['allergies']),
    createdAt: _date(row['created_at']),
    updatedAt: _date(row['updated_at']),
  );
}

class SupabasePetRepository implements PetRepository {
  SupabasePetRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  @override
  Future<Result<Pet>> create(Pet pet) async {
    try {
      final row = await client
          .from('pets')
          .insert(_petMap(pet))
          .select()
          .single();
      final saved = _petFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'La mascota guardada no es válida'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo crear la mascota', 'database', error),
      );
    }
  }

  @override
  Future<Result<Pet?>> findById(String id) async {
    try {
      final row = await client.from('pets').select().eq('id', id).maybeSingle();
      final pet = row == null ? null : _petFromMap(row);
      if (row != null && pet == null) {
        return Result.failure(
          const DomainError(message: 'La mascota no se pudo leer'),
        );
      }
      return Result.ok(pet);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo leer la mascota', 'database', error),
      );
    }
  }

  @override
  Future<Result<List<Pet>>> findByOwnerId(String ownerId) async {
    try {
      final rows = await client.from('pets').select().eq('owner_id', ownerId);
      final pets = <Pet>[];
      for (final row in rows) {
        final pet = _petFromMap(row);
        if (pet == null) {
          return Result.failure(
            const DomainError(
              message: 'La lista contiene una mascota inválida',
            ),
          );
        }
        pets.add(pet);
      }
      return Result.ok(pets);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError(
          'No se pudieron listar las mascotas',
          'database',
          error,
        ),
      );
    }
  }

  @override
  Future<Result<Pet>> update(Pet pet) async {
    try {
      final row = await client
          .from('pets')
          .update(_petMap(pet)..remove('id'))
          .eq('id', pet.id)
          .select()
          .single();
      final saved = _petFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'La mascota actualizada no es válida'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo actualizar la mascota', 'database', error),
      );
    }
  }
}

Map<String, dynamic> _visitMap(Visit visit) => {
  'pet_id': visit.petId,
  'company_id': visit.companyId,
  'red_flags': visit.redFlags,
  'symptoms': visit.symptoms,
  'vitals': visit.vitals,
  'photos': visit.photos,
  'triage': visit.triage,
  'status': visit.status,
  if (visit.createdAt != null)
    'created_at': visit.createdAt!.toUtc().toIso8601String(),
  if (visit.updatedAt != null)
    'updated_at': visit.updatedAt!.toUtc().toIso8601String(),
};

Visit? _visitFromMap(Map<String, dynamic>? row) {
  if (row == null || row['id'] is! String || row['pet_id'] is! String) {
    return null;
  }
  return Visit(
    id: row['id'] as String,
    petId: row['pet_id'] as String,
    companyId: _string(row['company_id']),
    redFlags: _map(row['red_flags']),
    symptoms: _map(row['symptoms']),
    vitals: _map(row['vitals']),
    photos: row['photos'] == null ? null : _strings(row['photos']),
    triage: _map(row['triage']),
    status: _string(row['status']),
    createdAt: _date(row['created_at']),
    updatedAt: _date(row['updated_at']),
  );
}

class SupabaseVisitRepository implements VisitRepository {
  SupabaseVisitRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  @override
  Future<Result<Visit>> create(Visit visit) async {
    try {
      final row = await client
          .from('visits')
          .insert({'id': visit.id, ..._visitMap(visit)})
          .select()
          .single();
      final saved = _visitFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'La visita guardada no es válida'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo crear la visita', 'database', error),
      );
    }
  }

  @override
  Future<Result<Visit?>> findById(String id) async {
    try {
      final row = await client
          .from('visits')
          .select()
          .eq('id', id)
          .maybeSingle();
      final visit = row == null ? null : _visitFromMap(row);
      if (row != null && visit == null) {
        return Result.failure(
          const DomainError(message: 'La visita no se pudo leer'),
        );
      }
      return Result.ok(visit);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo leer la visita', 'database', error),
      );
    }
  }

  @override
  Future<Result<Visit>> update(Visit visit) async {
    try {
      final row = await client
          .from('visits')
          .update(_visitMap(visit))
          .eq('id', visit.id)
          .select()
          .single();
      final saved = _visitFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'La visita actualizada no es válida'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo actualizar la visita', 'database', error),
      );
    }
  }
}

TriageLevel _triageLevel(Object? value) => switch (value) {
  'emergencia' => TriageLevel.emergencia,
  'urgencia' => TriageLevel.urgencia,
  _ => TriageLevel.consulta,
};

QueueStatus _queueStatus(Object? value) => switch (value) {
  'en_atencion' => QueueStatus.enAtencion,
  'atendido' => QueueStatus.atendido,
  'cancelado' => QueueStatus.cancelado,
  _ => QueueStatus.pendiente,
};

QueueEntry? _queueEntryFromMap(Map<String, dynamic> row) {
  final id = row['id'];
  final visitId = row['id'];
  final petId = row['pet_id'];
  final ownerId = row['owner_id'];
  if (id is! String || petId is! String || ownerId is! String) return null;
  final triage = _map(row['triage']);
  return QueueEntry(
    id: id,
    visitId: visitId as String,
    petId: petId,
    ownerId: ownerId,
    triageLevel: _triageLevel(triage?['suggested']),
    status: _queueStatus(row['status']),
    assignedRoom: _string(row['assigned_room']),
    assignedVeterinarian: _string(row['assigned_veterinarian']),
    position: row['position'] is int ? row['position'] as int : null,
    createdAt: _date(row['created_at']) ?? DateTime.now(),
    updatedAt: _date(row['updated_at']),
  );
}

class SupabaseQueueRepository implements QueueRepository {
  SupabaseQueueRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  @override
  Future<Result<QueueEntry>> create(QueueEntry entry) async {
    try {
      final row = await client
          .from('visits')
          .insert({
            if (entry.id.isNotEmpty) 'id': entry.id,
            'pet_id': entry.petId,
            'owner_id': entry.ownerId,
            'status': entry.status.value,
            'triage': {
              'suggested': entry.triageLevel.value,
              'confirmed': null,
              'reasons': <String>[],
              'rulesVersion': '0.2',
            },
            'assigned_room': entry.assignedRoom,
            'assigned_veterinarian': entry.assignedVeterinarian,
            'position': entry.position,
          })
          .select()
          .single();
      final saved = _queueEntryFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(
            message: 'La entrada de cola guardada no es válida',
          ),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError(
          'No se pudo crear la entrada de cola',
          'database',
          error,
        ),
      );
    }
  }

  @override
  Future<Result<QueueEntry?>> findById(String id) async {
    try {
      final row = await client
          .from('visits')
          .select()
          .eq('id', id)
          .maybeSingle();
      final entry = row == null ? null : _queueEntryFromMap(row);
      if (row != null && entry == null) {
        return Result.failure(
          const DomainError(message: 'La entrada de cola no es válida'),
        );
      }
      return Result.ok(entry);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError(
          'No se pudo leer la entrada de cola',
          'database',
          error,
        ),
      );
    }
  }

  @override
  Future<Result<QueueEntry?>> findByVisitId(String visitId) =>
      findById(visitId);

  @override
  Future<Result<List<QueueEntry>>> getPendingQueue({String? companyId}) async {
    try {
      var query = client.from('visits').select().eq('status', 'pendiente');
      if (companyId != null) {
        query = query.eq('company_id', companyId);
      }
      final rows = await query.order('created_at');
      final entries = <QueueEntry>[];
      for (final row in rows) {
        final entry = _queueEntryFromMap(row);
        if (entry == null) {
          return Result.failure(
            const DomainError(message: 'La cola contiene una entrada inválida'),
          );
        }
        entries.add(entry);
      }
      return Result.ok(entries);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError(
          'No se pudo obtener la cola pendiente',
          'database',
          error,
        ),
      );
    }
  }

  @override
  Stream<Result<List<QueueEntry>>> watchPendingQueue({
    String? companyId,
  }) async* {
    try {
      var stream = client
          .from('visits')
          .stream(primaryKey: ['id'])
          .eq('status', 'pendiente');
      if (companyId != null) {
        stream = stream.eq('company_id', companyId);
      }
      await for (final rows in stream) {
        final entries = <QueueEntry>[];
        for (final row in rows) {
          final entry = _queueEntryFromMap(row);
          if (entry == null) {
            yield Result.failure(
              const DomainError(
                message: 'La cola contiene una entrada inválida',
              ),
            );
            break;
          }
          entries.add(entry);
        }
        yield Result.ok(entries);
      }
    } on PostgrestException catch (error) {
      yield Result.failure(
        _repositoryError('No se pudo observar la cola', 'database', error),
      );
    }
  }

  @override
  Future<Result<QueueEntry>> update(QueueEntry entry) async {
    try {
      final row = await client
          .from('visits')
          .update({
            'status': entry.status.value,
            'assigned_room': entry.assignedRoom,
            'assigned_veterinarian': entry.assignedVeterinarian,
            'position': entry.position,
            if (entry.updatedAt != null)
              'updated_at': entry.updatedAt!.toUtc().toIso8601String(),
          })
          .eq('id', entry.id)
          .select()
          .single();
      final saved = _queueEntryFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(
            message: 'La entrada de cola actualizada no es válida',
          ),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError(
          'No se pudo actualizar la entrada de cola',
          'database',
          error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> assignRoomAndVeterinarian({
    required String queueEntryId,
    required String room,
    required String veterinarianId,
  }) async {
    try {
      await client
          .from('visits')
          .update({
            'assigned_room': room,
            'assigned_veterinarian': veterinarianId,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', queueEntryId);
      return Result<void>.ok(null);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError(
          'No se pudo asignar sala y veterinario',
          'database',
          error,
        ),
      );
    }
  }
}

Clinic? _clinicFromMap(Map<String, dynamic>? row) {
  if (row == null || row['id'] is! String) return null;
  return Clinic(
    id: row['id'] as String,
    name: _string(row['name']) ?? '',
    address: _string(row['address']) ?? '',
    phone: _string(row['phone']) ?? '',
    email: _string(row['email']),
    specialties: _strings(row['specialties']),
    hours: _map(row['hours']) ?? <String, dynamic>{},
    emergency24h: row['emergency_24h'] == true,
    services: _strings(row['services']),
    latitude: row['latitude'] is num
        ? (row['latitude'] as num).toDouble()
        : null,
    longitude: row['longitude'] is num
        ? (row['longitude'] as num).toDouble()
        : null,
    createdAt: _date(row['created_at']),
    updatedAt: _date(row['updated_at']),
  );
}

Map<String, dynamic> _clinicMap(Clinic clinic) => {
  'name': clinic.name,
  'address': clinic.address,
  'phone': clinic.phone,
  'email': clinic.email,
  'specialties': clinic.specialties,
  'hours': clinic.hours,
  'emergency_24h': clinic.emergency24h,
  'services': clinic.services,
  'latitude': clinic.latitude,
  'longitude': clinic.longitude,
  if (clinic.createdAt != null)
    'created_at': clinic.createdAt!.toUtc().toIso8601String(),
  if (clinic.updatedAt != null)
    'updated_at': clinic.updatedAt!.toUtc().toIso8601String(),
};

class SupabaseClinicRepository implements ClinicRepository {
  SupabaseClinicRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  @override
  Future<Result<Clinic>> create(Clinic clinic) async {
    try {
      final row = await client
          .from('clinics')
          .insert({
            if (clinic.id.isNotEmpty) 'id': clinic.id,
            ..._clinicMap(clinic),
          })
          .select()
          .single();
      final saved = _clinicFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'La clínica guardada no es válida'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo crear la clínica', 'database', error),
      );
    }
  }

  @override
  Future<Result<Clinic?>> findById(String id) async {
    try {
      final row = await client
          .from('clinics')
          .select()
          .eq('id', id)
          .maybeSingle();
      final clinic = row == null ? null : _clinicFromMap(row);
      if (row != null && clinic == null) {
        return Result.failure(
          const DomainError(message: 'La clínica no se pudo leer'),
        );
      }
      return Result.ok(clinic);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo leer la clínica', 'database', error),
      );
    }
  }

  @override
  Future<Result<List<Clinic>>> listAll() => _listClinics(
    operation: 'No se pudieron listar las clínicas',
    query: () => client.from('clinics').select(),
  );

  @override
  Future<Result<List<Clinic>>> listBySpecialties(
    List<String> specialties,
  ) async {
    if (specialties.isEmpty) return Result.ok(const []);
    return _listClinics(
      operation: 'No se pudieron filtrar clínicas por especialidad',
      query: () =>
          client.from('clinics').select().overlaps('specialties', specialties),
    );
  }

  @override
  Future<Result<List<Clinic>>> listEmergency24h() => _listClinics(
    operation: 'No se pudieron listar clínicas de emergencia 24h',
    query: () => client.from('clinics').select().eq('emergency_24h', true),
  );

  Future<Result<List<Clinic>>> _listClinics({
    required String operation,
    required PostgrestFilterBuilder<List<Map<String, dynamic>>> Function()
    query,
  }) async {
    try {
      final rows = await query();
      final clinics = <Clinic>[];
      for (final row in rows) {
        final clinic = _clinicFromMap(row);
        if (clinic == null) {
          return Result.failure(
            const DomainError(
              message: 'La lista contiene una clínica inválida',
            ),
          );
        }
        clinics.add(clinic);
      }
      return Result.ok(clinics);
    } on PostgrestException catch (error) {
      return Result.failure(_repositoryError(operation, 'database', error));
    }
  }

  @override
  Future<Result<Clinic>> update(Clinic clinic) async {
    try {
      final row = await client
          .from('clinics')
          .update(_clinicMap(clinic))
          .eq('id', clinic.id)
          .select()
          .single();
      final saved = _clinicFromMap(row);
      if (saved == null) {
        return Result.failure(
          const DomainError(message: 'La clínica actualizada no es válida'),
        );
      }
      return Result.ok(saved);
    } on PostgrestException catch (error) {
      return Result.failure(
        _repositoryError('No se pudo actualizar la clínica', 'database', error),
      );
    }
  }
}

class PetPhotoStorage {
  PetPhotoStorage({SupabaseClient? client}) : _client = client;

  static const String bucket = 'pet-photos';
  static const int maxSizeBytes = 5 * 1024 * 1024;
  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  Future<String> uploadPhoto({
    required String petId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (contentType != 'image/jpeg' && contentType != 'image/png') {
      throw ArgumentError('Solo se permiten imágenes JPG y PNG');
    }
    if (bytes.lengthInBytes > maxSizeBytes) {
      throw ArgumentError('La imagen supera el límite de 5 MB');
    }
    final safeName = fileName.split(RegExp(r'[/\\]')).last;
    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      throw ArgumentError('Nombre de archivo no válido');
    }
    final path = 'mascotas/$petId/fotos/$safeName';
    await client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return client.storage.from(bucket).createSignedUrl(path, 3600);
  }

  Future<void> deletePhoto(String path) =>
      client.storage.from(bucket).remove([path]).then((_) {});
}
