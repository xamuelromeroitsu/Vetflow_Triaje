/// Composition root de autenticación.
///
/// La UI (cuando llegue) recibe los casos de uso ya construidos. El gestor de
/// estado y la navegación se decidirán en el ADR-0004.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/register_with_email.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/sign_in_with_email.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/sign_out.dart';
import 'package:vetflow_triaje/features/auth/domain/model/auth_account.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/port/user_profile_repository.dart';
import 'package:vetflow_triaje/infrastructure/demo/demo_repositories.dart';
import 'package:vetflow_triaje/infrastructure/firebase/auth/firebase_auth_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/profile/firestore_user_profile_repository.dart';

class AuthModule {
  const AuthModule({
    required this.registerWithEmail,
    required this.signInWithEmail,
    required this.signOut,
    required this.profileRepository,
    required this.authRepository,
  });

  factory AuthModule.create({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    bool demoMode = true,
  }) {
    final authRepository = demoMode
        ? DemoAuthRepository()
        : AuthRepositoryFirebase(auth: auth);
    final profileRepository = demoMode
        ? DemoUserProfileRepository()
        : UserProfileRepositoryFirestore(firestore: firestore);

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
