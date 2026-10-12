/// Caso de uso: registro con email y contraseña.
///
/// Crea la cuenta en Firebase Auth y, solo si eso funciona, el perfil en
/// Firestore con rol `dueno`. El rol no se acepta como parámetro: el
/// auto-registro nunca puede crear personal.
library;

import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/app_user.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_validation.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_role.dart';

class RegisterWithEmail {
  const RegisterWithEmail({
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

    final account = await authRepository.registerWithEmail(
      email: valid.email,
      password: valid.password,
    );
    final created = account.valueOrNull;
    if (created == null) {
      return Result.failure(
        account.errorOrNull ??
            const DomainError(message: 'No se pudo crear la cuenta'),
      );
    }

    final profile = await profileRepository.create(
      UserProfile(
        uid: created.uid,
        email: created.email,
        role: UserRole.dueno,
        ownerId: created.uid,
      ),
    );

    return profile.when(
      ok: (saved) => Result.ok(_appUser(saved)),
      failure: (error) => Result.failure(
        DomainError(
          message: 'La cuenta se creó pero el perfil no: ${error.message}',
          fields: error.fields,
        ),
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
