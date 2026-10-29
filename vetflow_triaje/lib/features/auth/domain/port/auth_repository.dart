/// Puerto (interfaz) de autenticación: solo credenciales.
library;

import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/auth/domain/model/auth_account.dart';

abstract class AuthRepository {
  Future<Result<AuthAccount>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  Future<Result<AuthAccount>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  AuthAccount? get currentAccount;

  Stream<AuthAccount?> authStateChanges();
}
