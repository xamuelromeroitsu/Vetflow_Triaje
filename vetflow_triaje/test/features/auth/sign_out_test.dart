import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/application/sign_out.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  bool signOutCalled = false;
  Result<void> result = Result<void>.ok(null);

  @override
  Future<Result<void>> signOut() async {
    signOutCalled = true;
    return result;
  }

  @override
  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  AuthAccount? get currentAccount => null;

  @override
  Stream<AuthAccount?> authStateChanges() => const Stream.empty();
}

void main() {
  test('sign out delega en el repositorio', () async {
    final auth = _FakeAuthRepository();
    final useCase = SignOut(authRepository: auth);

    final result = await useCase();

    expect(auth.signOutCalled, isTrue);
    expect(result.errorOrNull, isNull);
  });

  test('un fallo al cerrar sesión se propaga', () async {
    final auth = _FakeAuthRepository()
      ..result = const Failure<void>(
        DomainError(message: 'No se pudo cerrar la sesión'),
      );
    final useCase = SignOut(authRepository: auth);

    final result = await useCase();

    expect(result.errorOrNull?.message, 'No se pudo cerrar la sesión');
  });
}
