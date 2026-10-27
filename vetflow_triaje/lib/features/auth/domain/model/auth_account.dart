/// Cuenta de autenticación, sin información de rol.
///
/// El rol **nunca** viene de aquí: se lee del perfil persistido para que RLS
/// pueda confiar en él.
library;

class AuthAccount {
  const AuthAccount({required this.uid, required this.email});

  final String uid;
  final String email;
}
