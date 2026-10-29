/// Caso de uso: registro con email y contraseña.
///
/// Crea la cuenta de autenticación y, solo si eso funciona, el perfil con rol
/// `dueno`. El rol no se acepta como parámetro: el
/// auto-registro nunca puede crear personal.
library;

import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/auth/domain/model/app_user.dart';
import 'package:vetflow_triaje/features/auth/domain/validation/auth_validation.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/port/user_profile_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_role.dart';
import 'package:vetflow_triaje/features/owners/domain/validation/owner_validation.dart';

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
    required String name,
    required String phone,
  }) async {
    final credentials = validateCredentials(email: email, password: password);
    final valid = credentials.valueOrNull;
    if (valid == null) {
      return Result.failure(
        credentials.errorOrNull ??
            const DomainError(message: 'Revisa el email y la contraseña'),
      );
    }

    final ownerDetails = validateOwner(
      name: name,
      phone: phone,
      email: valid.email,
      ownerId: 'pending',
    );
    final validOwner = ownerDetails.valueOrNull;
    if (validOwner == null) {
      return Result.failure(
        ownerDetails.errorOrNull ??
            const DomainError(message: 'Revisa los datos del dueño'),
      );
    }

    final account = await authRepository.registerWithEmail(
      email: valid.email,
      password: valid.password,
      name: validOwner.name,
      phone: validOwner.phone,
    );
    final created = account.valueOrNull;
    if (created == null) {
      return Result.failure(
        account.errorOrNull ??
            const DomainError(message: 'No se pudo crear la cuenta'),
      );
    }

    if (created.requiresEmailConfirmation) {
      return Result.ok(
        AppUser(
          uid: created.uid,
          email: created.email,
          role: UserRole.dueno,
          ownerId: created.uid,
          requiresEmailConfirmation: true,
        ),
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
