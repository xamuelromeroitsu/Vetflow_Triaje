/// Cuenta de Firebase Authentication, sin información de rol.
///
/// El rol **nunca** viene de aquí: se lee del perfil en Firestore
/// (users/{uid}) para que las reglas puedan confiar en él.
library;

class AuthAccount {
  const AuthAccount({required this.uid, required this.email});

  final String uid;
  final String email;
}
