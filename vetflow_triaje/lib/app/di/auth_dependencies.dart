/// Composition root de autenticación.
///
/// La UI (cuando llegue) recibe los casos de uso ya construidos. El gestor de
/// estado y la navegación se decidirán en el ADR-0004.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/register_with_email.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/sign_in_with_email.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/sign_out.dart';
import 'package:vetflow_triaje/features/auth/domain/model/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/port/user_profile_repository.dart';
import 'package:vetflow_triaje/infrastructure/demo/demo_repositories.dart';
import 'package:vetflow_triaje/infrastructure/supabase/supabase_repositories.dart';

class AuthModule {
  const AuthModule({
    required this.registerWithEmail,
    required this.signInWithEmail,
    required this.signOut,
    required this.profileRepository,
    required this.authRepository,
  });

  factory AuthModule.create({SupabaseClient? client, bool demoMode = true}) {
    final authRepository = demoMode
        ? DemoAuthRepository()
        : SupabaseAuthRepository(client: client);
    final profileRepository = demoMode
        ? DemoUserProfileRepository()
        : SupabaseUserProfileRepository(client: client);

    return AuthModule(
      registerWithEmail: RegisterWithEmail(
        authRepository: authRepository,
        profileRepository: profileRepository,
      ),
      signInWithEmail: SignInWithEmail(
        authRepository: authRepository,
        profileRepository: profileRepository,
      ),
      signOut: SignOut(authRepository: authRepository),
      profileRepository: profileRepository,
      authRepository: authRepository,
    );
  }

  final RegisterWithEmail registerWithEmail;
  final SignInWithEmail signInWithEmail;
  final SignOut signOut;
  final UserProfileRepository profileRepository;
  final AuthRepository authRepository;

  /// Emite la cuenta de auth actual (o null si no hay sesión).
  Stream<AuthAccount?> get authStateChanges =>
      authRepository.authStateChanges();
}
