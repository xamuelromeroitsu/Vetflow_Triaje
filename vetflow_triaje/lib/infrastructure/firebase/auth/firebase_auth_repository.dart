/// Adaptador de Firebase Auth para [AuthRepository].
///
/// Solo maneja credenciales y sesión: el rol vive en users/{uid} (Firestore).
/// El auto-registro del MVP crea cuentas de dueño (ADR-0002).
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/auth/domain/model/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';

class AuthRepositoryFirebase implements AuthRepository {
  AuthRepositoryFirebase({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AuthAccount _mapUser(User user) => AuthAccount(
        uid: user.uid,
        email: user.email ?? '',
      );

  DomainError _error(String message, FirebaseAuthException error) => DomainError(
        message: message,
        fields: [
          FieldError(
            field: 'credentials',
            code: FieldErrorCode.invalid,
            message: error.code,
          ),
        ],
      );

  @override
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Result.failure(
          const DomainError(message: 'No se pudo crear la cuenta'),
        );
      }
      return Result.ok(_mapUser(user));
    } on FirebaseAuthException catch (error) {
      return Result.failure(_error('No se pudo crear la cuenta', error));
    }
  }

  @override
  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Result.failure(
          const DomainError(message: 'No se pudo iniciar sesión'),
        );
      }
      return Result.ok(_mapUser(user));
    } on FirebaseAuthException catch (error) {
      return Result.failure(_error('No se pudo iniciar sesión', error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result<void>.ok(null);
    } on FirebaseAuthException catch (error) {
      return Result.failure(_error('No se pudo cerrar la sesión', error));
    }
  }

  @override
  AuthAccount? get currentAccount {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Stream<AuthAccount?> authStateChanges() {
    return _auth.authStateChanges().map(
          (user) => user == null ? null : _mapUser(user),
        );
  }
}
