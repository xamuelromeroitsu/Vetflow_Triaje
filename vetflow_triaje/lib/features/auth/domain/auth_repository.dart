/// Puerto (interfaz) de autenticación.
library;

import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> registerWithEmail({
    required String email,
    required String password,
    String? ownerId,
  });

  Future<Result<void>> signOut();

  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();
}
