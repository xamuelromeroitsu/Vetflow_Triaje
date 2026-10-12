/// Credenciales validadas listas para enviar al adaptador de Auth.
library;

class Credentials {
  const Credentials({required this.email, required this.password});

  final String email;
  final String password;
}
