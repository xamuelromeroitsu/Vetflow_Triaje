/// Entidad de dominio: clínica veterinaria.
///
/// Parte de EPC-06: directorio y geolocalización de clínicas.
library;

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    required this.specialties,
    required this.hours,
    this.emergency24h = false,
    this.services = const [],
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final List<String> specialties;
  final Map<String, dynamic> hours;
  final bool emergency24h;
  final List<String> services;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Indica si la clínica está abierta ahora según su horario.
  bool get isOpenNow {
    final now = DateTime.now();
    final dayKey = _dayKey(now);
    final dayHours = hours[dayKey];
    if (dayHours == null) return false;
    final open = dayHours['open'] as String?;
    final close = dayHours['close'] as String?;
    if (open == null || close == null) return false;
    final nowStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return nowStr >= open && nowStr <= close;
  }

  String _dayKey(DateTime date) {
    switch (date.weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }
}
