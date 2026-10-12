/// Puerto (interfaz) de autenticación: solo credenciales.
library;

import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_account.dart';

abstract class AuthRepository {
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  AuthAccount? get currentAccount;

  Stream<AuthAccount?> authStateChanges();
}
