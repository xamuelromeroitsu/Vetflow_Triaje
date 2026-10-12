/// Caso de uso: inicio de sesión con email y contraseña.
///
/// El rol sale siempre del perfil en Firestore (users/{uid}), nunca de lo que
/// envíe el cliente. Si la cuenta existe pero el perfil falta, se crece con el
/// rol menos privilegiado (`dueno`) para no dejar al usuario fuera.
library;

import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/app_user.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_validation.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_role.dart';

class SignInWithEmail {
  const SignInWithEmail({
    required this.authRepository,
    required this.profileRepository,
  });

  final AuthRepository authRepository;
  final UserProfileRepository profileRepository;

  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) async {
    final credentials = validateCredentials(email: email, password: password);
    final valid = credentials.valueOrNull;
    if (valid == null) {
      return Result.failure(
        credentials.errorOrNull ??
            const DomainError(message: 'Revisa el email y la contraseña'),
      );
    }

    final account = await authRepository.signInWithEmail(
      email: valid.email,
      password: valid.password,
    );
    final signedIn = account.valueOrNull;
    if (signedIn == null) {
      return Result.failure(
        account.errorOrNull ??
            const DomainError(message: 'No se pudo iniciar sesión'),
      );
    }

    final stored = await profileRepository.getByUid(signedIn.uid);
    final existing = stored.valueOrNull;
    if (existing != null) {
      return Result.ok(_appUser(existing));
    }

    final healed = await _healMissingProfile(signedIn.uid, signedIn.email);
    return healed.when(
      ok: (value) => Result.ok(_appUser(value)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Auto-curación: cuenta sin perfil → se crece como `dueno`.
  Future<Result<UserProfile>> _healMissingProfile(String uid, String email) {
    return profileRepository.create(
      UserProfile(
        uid: uid,
        email: email,
        role: UserRole.dueno,
        ownerId: uid,
      ),
    );
  }

  AppUser _appUser(UserProfile profile) => AppUser(
        uid: profile.uid,
        email: profile.email,
        role: profile.role,
        ownerId: profile.ownerId,
        companyId: profile.companyId,
      );
}
