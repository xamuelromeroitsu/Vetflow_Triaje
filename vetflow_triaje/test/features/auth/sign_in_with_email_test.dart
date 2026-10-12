import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/application/sign_in_with_email.dart';
import 'package:vetflow_triaje/features/auth/domain/app_user.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_role.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<AuthAccount> signInResult = Result.ok(
    const AuthAccount(uid: 'uid-1', email: 'ana@ejemplo.com'),
  );
  bool signOutCalled = false;

  @override
  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return signInResult;
  }

  @override
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
  }) {
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

class _FakeProfileRepository implements UserProfileRepository {
  Result<UserProfile>? stored;
  final List<UserProfile> created = [];

  @override
  Future<Result<UserProfile>> getByUid(String uid) async {
    return stored ??
        Result.failure(const DomainError(message: 'El perfil no existe'));
  }

  @override
  Future<Result<UserProfile>> create(UserProfile profile) async {
    created.add(profile);
    stored = Result.ok(profile);
    return Result.ok(profile);
  }

  @override
  Stream<UserProfile?> watchByUid(String uid) => const Stream.empty();
}

void main() {
  late _FakeAuthRepository auth;
  late _FakeProfileRepository profiles;
  late SignInWithEmail useCase;

  setUp(() {
    auth = _FakeAuthRepository();
    profiles = _FakeProfileRepository();
    useCase = SignInWithEmail(
      authRepository: auth,
      profileRepository: profiles,
    );
  });

  test('el rol sale del perfil guardado, no del cliente', () async {
    profiles.stored = Result.ok(
      const UserProfile(
        uid: 'uid-1',
        email: 'ana@ejemplo.com',
        role: UserRole.dueno,
      ),
    );

    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
    );

    final user = result.valueOrNull!;
    expect(user.role, UserRole.dueno);
    expect(profiles.created, isEmpty);
  });

  test('cuenta sin perfil: se crece como dueno', () async {
    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: 'secreto123',
    );

    expect(result.valueOrNull?.role, UserRole.dueno);
    expect(profiles.created.single.role, UserRole.dueno);
  });

  test('contraseña incorrecta: falla con el motivo', () async {
    auth.signInResult = Result.failure(
      const DomainError(
        message: 'No se pudo iniciar sesión',
        fields: [
          FieldError(field: 'credentials', code: FieldErrorCode.invalid),
        ],
      ),
    );

    final result = await useCase(
      email: 'ana@ejemplo.com',
      password: ' mala',
    );

    expect(result, isA<Failure<AppUser>>());
    expect(profiles.created, isEmpty);
  });

  test('email inválido: no llama a Auth', () async {
    final result = await useCase(email: 'ana@', password: 'secreto123');

    expect(result, isA<Failure<AppUser>>());
    expect(profiles.created, isEmpty);
  });
}
