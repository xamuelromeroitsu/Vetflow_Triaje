enum Especie { perro, gato, exotico }

enum Sexo { macho, hembra }

class MascotaRegistro {
  String nombre = '';
  Especie especie = Especie.perro;
  String raza = '';
  double? edad;
  String unidadEdad = 'Años';
  double? pesoKg;
  Sexo sexo = Sexo.macho;
  bool esterilizado = false;
  String condicionesPrevias = '';
  String? fotoPath;
}
