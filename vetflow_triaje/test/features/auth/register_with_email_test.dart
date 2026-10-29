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
  String? registeredName;
  String? registeredPhone;
  bool signOutCalled = false;

  @override
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    registerCalls++;
    registeredName = name;
    registeredPhone = phone;
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
      return Result.failure(const DomainError(message: 'permiso denegado'));
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
      name: 'Ana Pérez',
      phone: '+52 55 1234 5678',
    );

    expect(result.valueOrNull, isA<AppUser>());
    final user = result.valueOrNull!;
    expect(user.role, UserRole.dueno);
    expect(user.uid, 'uid-1');
    expect(user.ownerId, 'uid-1');
    expect(profiles.created.single.role, UserRole.dueno);
  });

  test('nunca se puede registrar con rol personal', () async {
    await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
      name: 'Ana Pérez',
      phone: '+52 55 1234 5678',
    );

    expect(profiles.created.single.role, UserRole.dueno);
  });

  test('credenciales inválidas: no llama a Auth ni crea perfil', () async {
    final result = await useCase(
      email: 'ana@',
      password: '123',
      name: 'Ana Pérez',
      phone: '+52 55 1234 5678',
    );

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
      name: 'Ana Pérez',
      phone: '+52 55 1234 5678',
    );

    expect(result, isA<Failure<AppUser>>());
    expect(profiles.created, isEmpty);
  });

  test('fallo al crear el perfil se propaga con contexto', () async {
    profiles.failCreate = true;

    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
      name: 'Ana Pérez',
      phone: '+52 55 1234 5678',
    );

    final error = (result as Failure<AppUser>).error;
    expect(error.message, contains('permiso denegado'));
  });

  test('el email se recorta antes de enviarlo', () async {
    await useCase(
      email: '  ana@ejemplo.com  ',
      password: 'secreto123',
      name: ' Ana Pérez ',
      phone: ' +52 55 1234 5678 ',
    );

    expect(auth.registerCalls, 1);
    expect(auth.registeredName, 'Ana Pérez');
    expect(auth.registeredPhone, '+52 55 1234 5678');
  });

  test(
    'cuenta pendiente de confirmación no requiere una sesión activa',
    () async {
      auth.registerResult = Result.ok(
        const AuthAccount(
          uid: 'uid-1',
          email: 'ana@ejemplo.com',
          requiresEmailConfirmation: true,
        ),
      );

      final result = await useCase(
        email: 'ana@ejemplo.com',
        password: 'secreto123',
        name: 'Ana Pérez',
        phone: '+52 55 1234 5678',
      );

      expect(result.valueOrNull?.requiresEmailConfirmation, isTrue);
      expect(profiles.created, isEmpty);
    },
  );

  test('datos inválidos del dueño no crean cuenta de Auth', () async {
    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
      name: 'Ana Pérez',
      phone: 'teléfono inválido',
    );

    expect(result, isA<Failure<AppUser>>());
    expect(auth.registerCalls, 0);
    expect(profiles.created, isEmpty);
  });
}
