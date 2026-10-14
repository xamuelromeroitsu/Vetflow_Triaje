/// Caso de uso: cierre de sesión.
library;

import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/auth/domain/port/auth_repository.dart';

class SignOut {
  const SignOut({required this.authRepository});

  final AuthRepository authRepository;

  Future<Result<void>> call() {
    return authRepository.signOut();
  }
}
