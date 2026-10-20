/// Modelo de dominio: visita/triage.
///
/// Una visita agrupa la mascota, síntomas, signos vitales, fotos y el
/// resultado del triaje (sugerido vs confirmado).
library;

class Visit {
  const Visit({
    required this.id,
    required this.petId,
    this.companyId,
    this.redFlags,
    this.symptoms,
    this.vitals,
    this.photos,
    this.triage,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String petId;
  final String? companyId;
  final Map<String, dynamic>? redFlags;
  final Map<String, dynamic>? symptoms;
  final Map<String, dynamic>? vitals;
  final List<String>? photos;
  final Map<String, dynamic>? triage;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
