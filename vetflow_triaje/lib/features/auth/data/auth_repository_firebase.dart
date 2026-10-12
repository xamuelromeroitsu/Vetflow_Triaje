/// Adaptador de Firebase Auth para [AuthRepository].
///
/// MVP: email + contraseña. El rol real es [UserRole.dueno] (dueño fuera de
/// la clínica, ADR-0002). El personal llega con companies/staff en Fase 4.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/app_user.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_role.dart';

class AuthRepositoryFirebase implements AuthRepository {
  AuthRepositoryFirebase({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AppUser _mapUser(User user, {String? ownerId}) => AppUser(
        uid: user.uid,
        email: user.email ?? '',
        role: UserRole.dueno,
        ownerId: ownerId ?? user.uid,
      );

  @override
  Future<Result<AppUser>> signInWithEmail({
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
      return Result.failure(
        DomainError(
          message: 'No se pudo iniciar sesión',
          fields: [
            FieldError(
              field: 'email',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<AppUser>> registerWithEmail({
    required String email,
    required String password,
    String? ownerId,
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
      return Result.ok(_mapUser(user, ownerId: ownerId));
    } on FirebaseAuthException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo crear la cuenta',
          fields: [
            FieldError(
              field: 'email',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result<void>.ok(null);
    } on FirebaseAuthException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo cerrar la sesión',
          fields: [
            FieldError(
              field: 'session',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(
          (user) => user == null ? null : _mapUser(user),
        );
  }
}
