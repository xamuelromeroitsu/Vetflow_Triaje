import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/register_with_email.dart';
import 'package:vetflow_triaje/features/auth/domain/model/app_user.dart';
import 'package:vetflow_triaje/features/auth/domain/model/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/port/user_profile_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_role.dart';

/// Doble de prueba del puerto de autenticación.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository();

  Result<AuthAccount> registerResult = Result.ok(
    const AuthAccount(uid: 'uid-1', email: 'ana@ejemplo.com'),
  );
  int registerCalls = 0;
  bool signOutCalled = false;

  @override
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    registerCalls++;
    return registerResult;
  }

  @override
  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCalled = true;
    return Result<void>.ok(null);
  }

  @override
  AuthAccount? get currentAccount => null;

  @override
  Stream<AuthAccount?> authStateChanges() => const Stream.empty();
}

/// Doble de prueba del puerto de perfiles.
class _FakeProfileRepository implements UserProfileRepository {
  final List<UserProfile> created = [];
  bool failCreate = false;

  @override
  Future<Result<UserProfile>> create(UserProfile profile) async {
    created.add(profile);
    if (failCreate) {
      return Result.failure(
        const DomainError(message: 'permiso denegado'),
      );
    }
    return Result.ok(profile);
  }

  @override
  Future<Result<UserProfile>> getByUid(String uid) {
    throw UnimplementedError();
  }

  @override
  Stream<UserProfile?> watchByUid(String uid) => const Stream.empty();
}

void main() {
  late _FakeAuthRepository auth;
  late _FakeProfileRepository profiles;
  late RegisterWithEmail useCase;

  setUp(() {
    auth = _FakeAuthRepository();
    profiles = _FakeProfileRepository();
    useCase = RegisterWithEmail(
      authRepository: auth,
      profileRepository: profiles,
    );
  });

  test('registro válido crea el perfil con rol dueno', () async {
    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
    );

    expect(result.valueOrNull, isA<AppUser>());
    final user = result.valueOrNull!;
    expect(user.role, UserRole.dueno);
    expect(user.uid, 'uid-1');
    expect(user.ownerId, 'uid-1');
    expect(profiles.created.single.role, UserRole.dueno);
  });

  test('nunca se puede registrar con rol personal', () async {
    await useCase(email: 'ana@ejemplo.com', password: 'secreto123');

    expect(profiles.created.single.role, UserRole.dueno);
  });

  test('credenciales inválidas: no llama a Auth ni crea perfil', () async {
    final result = await useCase(email: 'ana@', password: '123');

    expect(result, isA<Failure<AppUser>>());
    expect(auth.registerCalls, 0);
    expect(profiles.created, isEmpty);
  });

  test('email duplicado: falla y no crea perfil', () async {
    auth.registerResult = Result.failure(
      const DomainError(message: 'No se pudo crear la cuenta'),
    );

    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
    );

    expect(result, isA<Failure<AppUser>>());
    expect(profiles.created, isEmpty);
  });

  test('fallo al crear el perfil se propaga con contexto', () async {
    profiles.failCreate = true;

    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
    );

    final error = (result as Failure<AppUser>).error;
    expect(error.message, contains('permiso denegado'));
  });

  test('el email se recorta antes de enviarlo', () async {
    await useCase(
      email: '  ana@ejemplo.com  ',
      password: 'secreto123',
    );

    expect(auth.registerCalls, 1);
  });
}
