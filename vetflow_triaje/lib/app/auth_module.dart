/// Composition root de autenticación.
///
/// La UI (cuando llegue) recibe los casos de uso ya construidos. El gestor de
/// estado y la navegación se decidirán en el ADR-0004.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetflow_triaje/features/auth/application/register_with_email.dart';
import 'package:vetflow_triaje/features/auth/application/sign_in_with_email.dart';
import 'package:vetflow_triaje/features/auth/application/sign_out.dart';
import 'package:vetflow_triaje/features/auth/data/auth_repository_firebase.dart';
import 'package:vetflow_triaje/features/auth/data/user_profile_repository_firestore.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_repository.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile_repository.dart';

class AuthModule {
  const AuthModule({
    required this.registerWithEmail,
    required this.signInWithEmail,
    required this.signOut,
    required this.profileRepository,
  });

  factory AuthModule.create({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    final AuthRepository authRepository = AuthRepositoryFirebase(auth: auth);
    final UserProfileRepository profileRepository =
        UserProfileRepositoryFirestore(firestore: firestore);

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
    );
  }

  final RegisterWithEmail registerWithEmail;
  final SignInWithEmail signInWithEmail;
  final SignOut signOut;
  final UserProfileRepository profileRepository;
}
