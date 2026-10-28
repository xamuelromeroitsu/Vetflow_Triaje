// Pantalla: Cola en Tiempo Real — Sistema DOGO
// Design System: "Clinical Mint" (ver DESIGN.md adjunto)
// Carpeta: pantalla de mvp 0000
//
// Sigue la arquitectura del proyecto: muestra la cola real del dominio
// (QueueEntry, ordenada por prioridad del triaje) que proviene del backend
// vía WatchQueue/Firestore. Tiene filtros por nivel, métricas y acciones.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

import 'dogo_design_tokens.dart';

/// ---------------------------------------------------------------------------
/// Modelo de presentación de un paciente en la cola
/// ---------------------------------------------------------------------------

enum PrioridadCola { rojoCritico, ambarUrgente, verdeEstable }

extension PrioridadColaX on PrioridadCola {
  String get label => switch (this) {
        PrioridadCola.rojoCritico => 'Rojo Crítico',
        PrioridadCola.ambarUrgente => 'Ámbar Urgente',
        PrioridadCola.verdeEstable => 'Verde Estable',
      };

  static PrioridadCola fromTriage(TriageLevel nivel) => switch (nivel) {
        TriageLevel.emergencia => PrioridadCola.rojoCritico,
        TriageLevel.urgencia => PrioridadCola.ambarUrgente,
        TriageLevel.consulta => PrioridadCola.verdeEstable,
      };
}

/// ViewModel de tarjeta de paciente en la cola.
class PacienteCola {
  const PacienteCola({
    required this.nombre,
    required this.raza,
    required this.pesoKg,
    required this.sexoInicial,
    required this.etiquetaEdad,
    required this.prioridad,
    required this.tiempoEspera,
    required this.diagnostico,
    required this.ubicacion,
    required this.detalleClinico,
    required this.accionPrincipal,
    this.iconoDiagnostico,
    this.iconoUbicacionColor,
    this.tutor,
  });

  final String nombre;
  final String raza;
  final double pesoKg;
  final String sexoInicial;
  final String etiquetaEdad;
  final PrioridadCola prioridad;
  final String tiempoEspera;
  final String diagnostico;
  final String ubicacion;
  final String detalleClinico;
  final String accionPrincipal;
  final IconData? iconoDiagnostico;
  final Color? iconoUbicacionColor;
  final String? tutor;

  /// Mapea la entrada real del backend (QueueEntry + datos de mascota) a ViewModel.
  factory PacienteCola.fromEntry(QueueEntry e,
      {required String nombre,
      required String raza,
      required double pesoKg,
      String? tutor}) {
    // Tiempo transcurrido en espera (real, desde createdAt del backend).
    final espera = DateTime.now().difference(e.createdAt);
    final minutos = espera.inMinutes;
    final textoEspera =
        minutos >= 60 ? '${espera.inHours} h ${minutos % 60} min' : '$minutos min';

    // Acción según estado real de la entrada.
    final accion = switch (e.status) {
      QueueStatus.enAtencion => 'Actualizar Estado',
      QueueStatus.pendiente when e.triageLevel == TriageLevel.emergencia =>
        'Pase a Quirófano',
      QueueStatus.pendiente when e.assignedRoom != null => 'Llamar a Box',
      _ => 'Re-evaluar',
    };

    return PacienteCola(
      nombre: nombre,
      raza: raza,
      pesoKg: pesoKg,
      sexoInicial: 'M',
      etiquetaEdad: '',
      prioridad: PrioridadColaX.fromTriage(e.triageLevel),
      tiempoEspera: textoEspera,
      diagnostico: e.status.label,
      ubicacion: e.assignedRoom ?? 'Sala de Espera',
      detalleClinico: e.assignedVeterinarian ?? '',
      accionPrincipal: accion,
      tutor: tutor,
    );
  }
}

/// Datos demo para cuando la cola del backend está vacía (modo demo).
const _colaDemo = <PacienteCola>[
  PacienteCola(
    nombre: 'Rocky',
    raza: 'Pastor Alemán',
    pesoKg: 34.2,
    sexoInicial: 'M',
    etiquetaEdad: '6a',
    prioridad: PrioridadCola.rojoCritico,
    tiempoEspera: '2 min',
    diagnostico: 'Dilatación y Vólvulo Gástrico (DVG)',
    ubicacion: 'Box 1 Asignado',
    detalleClinico: 'Descompresión inmediata y vía periférica dual preparada.',
    accionPrincipal: 'Pase a Quirófano',
    iconoDiagnostico: Icons.warning_rounded,
    tutor: 'Tutor: Carlos Méndez',
  ),
  PacienteCola(
    nombre: 'Luna',
    raza: 'Común Europeo',
    pesoKg: 4.1,
    sexoInicial: 'H',
    etiquetaEdad: '3a',
    prioridad: PrioridadCola.rojoCritico,
    tiempoEspera: '4 min',
    diagnostico: 'Hipertermia Severa (41.2°C)',
    ubicacion: 'UCI Felina',
    detalleClinico:
        'Enfriamiento activo con compresas y fluidoterapia IV fría en curso.',
    accionPrincipal: 'Actualizar T°',
    iconoDiagnostico: Icons.ac_unit,
    iconoUbicacionColor: DogoColors.primary,
    tutor: 'Tutora: Sofía Rivas',
  ),
  PacienteCola(
    nombre: 'Max',
    raza: 'Labrador Retriever',
    pesoKg: 29.5,
    sexoInicial: 'M',
    etiquetaEdad: '5a',
    prioridad: PrioridadCola.ambarUrgente,
    tiempoEspera: '12 min',
    diagnostico: 'Trauma contuso extremidad posterior',
    ubicacion: 'Box 3 Pre-asignado',
    detalleClinico: 'Sin compromiso hemodinámico. Analgesia administrada 14:10.',
    accionPrincipal: 'Llamar a Box',
    iconoDiagnostico: Icons.medical_information,
    tutor: 'Tutor: Manuel Ortega',
  ),
  PacienteCola(
    nombre: 'Milo',
    raza: 'Golden Retriever',
    pesoKg: 31.0,
    sexoInicial: 'M',
    etiquetaEdad: '3a',
    prioridad: PrioridadCola.verdeEstable,
    tiempoEspera: '25 min',
    diagnostico: 'Control post-estabilización disnea',
    ubicacion: 'Sala de Espera 2',
    detalleClinico: 'SpO2: 98% con aire ambiental. Frecuencia respiratoria 24 rpm.',
    accionPrincipal: 'Re-evaluar',
    iconoDiagnostico: Icons.air,
    iconoUbicacionColor: DogoColors.primary,
    tutor: 'Tutora: Beatriz Sanz',
  ),
];

/// ---------------------------------------------------------------------------
/// Pantalla principal
/// ---------------------------------------------------------------------------

class ColaEnTiempoRealScreen extends StatefulWidget {
  const ColaEnTiempoRealScreen({
    super.key,
    this.pacientes,
    this.veterinarioGuardia = 'Dra. Valenzuela',
    this.rutasNav = const {
      _Nav.triaje: '/triage/symptoms',
      _Nav.cola: '/queue',
      _Nav.clinicas: '/queue',
      _Nav.salud: '/pets',
    },
  });

  /// Cola real desde el backend (WatchQueue). Si es null, usa la demo.
  final List<PacienteCola>? pacientes;
  final String veterinarioGuardia;
  final Map<_Nav, String> rutasNav;

  @override
  State<ColaEnTiempoRealScreen> createState() => _ColaEnTiempoRealScreenState();
}

class _ColaEnTiempoRealScreenState extends State<ColaEnTiempoRealScreen> {
  PrioridadCola? _filtro;
  bool _refrescando = false;

  List<PacienteCola> get _pacientes => widget.pacientes ?? _colaDemo;

  int _conteo(PrioridadCola? prioridad) {
    if (prioridad == null) return _pacientes.length;
    return _pacientes.where((p) => p.prioridad == prioridad).length;
  }

  List<PacienteCola> get _filtrados => _filtro == null
      ? _pacientes
      : _pacientes.where((p) => p.prioridad == _filtro).toList();

  /// Tiempo promedio de espera (solo pendientes visibles).
  int get _minutosPromedio {
    final tiempos = _pacientes
        .map((p) {
          final parts = p.tiempoEspera.split(' ');
          final mins = int.tryParse(parts.first.replaceAll(RegExp(r'[^0-9]'), ''));
          if (mins == null) return 0;
          return parts.length > 1 && parts[1].startsWith('h') ? mins * 60 : mins;
        })
        .where((m) => m > 0)
        .toList();
    if (tiempos.isEmpty) return 0;
    return (tiempos.reduce((a, b) => a + b) / tiempos.length).round();
  }

  Future<void> _refrescar() async {
    setState(() => _refrescando = true);
    // Aquí se invocará WatchQueue del backend; por ahora solo refresca la UI.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _refrescando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DogoColors.surface,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _bottomNav(context),
      floatingActionButton: _barraAccionesFlotante(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
        children: [
          _subHeaderEstacion(),
          _dashboardMetricas(),
          _filtros(),
          const SizedBox(height: DogoSpacing.md),
          for (final paciente in _filtrados) ...[
            _tarjetaPaciente(paciente),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ AppBar

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: DogoColors.surface,
      surfaceTintColor: DogoColors.surface,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.04),
      automaticallyImplyLeading: false,
      titleSpacing: DogoSpacing.margin,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DogoColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_circle_outline,
                color: DogoColors.onPrimary, size: 18),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  'DOGO ',
                  style: TextStyle(
                    color: DogoColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                Text(
                  'TRIAGE',
                  style: TextStyle(
                    color: DogoColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    height: 1.0,
                  ),
                ),
              ]),
              Text(
                'Cola en Tiempo Real',
                style: TextStyle(
                  color: DogoColors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: DogoSpacing.margin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Guardia activa',
                style: DogoText.labelSm.copyWith(color: DogoColors.secondary),
              ),
              Text(
                widget.veterinarioGuardia,
                style: DogoText.labelMd.copyWith(color: DogoColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ Sub-header en vivo

  Widget _subHeaderEstacion() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(DogoSpacing.margin, DogoSpacing.md, DogoSpacing.margin, 0),
      child: Row(
        children: [
          Text(
            'DOGO TRIAGE',
            style: DogoText.labelSm.copyWith(color: DogoColors.primary, letterSpacing: 1.2),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: DogoColors.errorContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: DogoColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'En vivo',
                  style: DogoText.labelSm.copyWith(
                    color: DogoColors.onErrorContainer,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Dra. Valenzuela',
            style: DogoText.labelMd,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ Dashboard métricas

  Widget _dashboardMetricas() {
    return Container(
      margin: const EdgeInsets.all(DogoSpacing.margin),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCardShadow,
      ),
      child: Row(
        children: [
          _metrica(
            icono: Icons.group,
            iconoBg: DogoColors.surfaceContainer,
            iconoColor: DogoColors.primary,
            valor: '${_conteo(null)}',
            etiqueta: 'Pacientes en Espera',
          ),
          const SizedBox(width: DogoSpacing.lg),
          _metrica(
            icono: Icons.hourglass_top,
            iconoBg: DogoColors.secondaryContainer,
            iconoColor: DogoColors.onSecondaryContainer,
            valor: '$_minutosPromedio',
            sufijo: 'min',
            etiqueta: 'Tiempo Promedio',
          ),
        ],
      ),
    );
  }

  Widget _metrica({
    required IconData icono,
    required Color iconoBg,
    required Color iconoColor,
    required String valor,
    required String etiqueta,
    String? sufijo,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconoBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 24, color: iconoColor),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      valor,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        color: DogoColors.onSurface,
                      ),
                    ),
                    if (sufijo != null) ...[
                      const SizedBox(width: 4),
                      Text(sufijo, style: DogoText.labelSm.copyWith(color: DogoColors.secondary)),
                    ],
                  ],
                ),
                Text(
                  etiqueta,
                  style: DogoText.labelMd.copyWith(color: DogoColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------- Filtros

  Widget _filtros() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DogoSpacing.margin),
        children: [
          _chipFiltro(
            prioridad: null,
            texto: 'Todos',
            conteo: _conteo(null),
            activo: _filtro == null,
          ),
          for (final p in PrioridadCola.values)
            _chipFiltro(
              prioridad: p,
              texto: p.label,
              conteo: _conteo(p),
              activo: _filtro == p,
            ),
        ],
      ),
    );
  }

  Widget _chipFiltro({
    required PrioridadCola? prioridad,
    required String texto,
    required int conteo,
    required bool activo,
  }) {
    // Color del punto de la prioridad.
    final Color punto = switch (prioridad) {
      PrioridadCola.rojoCritico => DogoColors.error,
      PrioridadCola.ambarUrgente => DogoColors.tertiaryContainer,
      _ => DogoColors.primaryContainer,
    };
    final bool critico = prioridad == PrioridadCola.rojoCritico;
    return Padding(
      padding: const EdgeInsets.only(right: DogoSpacing.sm),
      child: GestureDetector(
        onTap: () => setState(
            () => _filtro = activo ? null : prioridad),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: activo ? DogoColors.primary : DogoColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            boxShadow: kDogoCardShadow,
          ),
          child: Row(
            children: [
              if (prioridad != null)
                _puntoPulsante(punto, critico)
              else
                const Icon(Icons.apps, size: 14, color: DogoColors.onPrimary),
              const SizedBox(width: 6),
              Text(
                texto,
                style: DogoText.labelMd.copyWith(
                  color: activo ? DogoColors.onPrimary : DogoColors.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: activo
                      ? Colors.white.withOpacity(0.2)
                      : (prioridad == PrioridadCola.rojoCritico
                          ? DogoColors.errorContainer
                          : DogoColors.surfaceContainerHigh),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$conteo',
                  style: DogoText.labelSm.copyWith(
                    color: activo
                        ? DogoColors.onPrimary
                        : (prioridad == PrioridadCola.rojoCritico
                            ? DogoColors.onErrorContainer
                            : DogoColors.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _puntoPulsante(Color color, bool critico) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ---------------------------------------------------------------- Tarjeta paciente

  Widget _tarjetaPaciente(PacienteCola p) {
    final (Color cinta, Color badgeBg, Color badgeColor, IconData iconoBadge) = switch (p.prioridad) {
      PrioridadCola.rojoCritico => (
          DogoColors.error,
          DogoColors.errorContainer,
          DogoColors.onErrorContainer,
          Icons.emergency
        ),
      PrioridadCola.ambarUrgente => (
          DogoColors.tertiaryContainer,
          DogoColors.surfaceContainerHigh,
          DogoColors.onSurfaceVariant,
          Icons.medical_services
        ),
      _ => (
          DogoColors.primaryContainer,
          DogoColors.surfaceContainerHigh,
          DogoColors.primary,
          Icons.check_circle
        ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DogoSpacing.margin),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Fila superior
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cinta lateral
                  Container(
                    width: 6,
                    height: 56,
                    decoration: BoxDecoration(
                      color: cinta,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: DogoColors.surfaceContainerHigh,
                        child: const Icon(Icons.pets, color: DogoColors.primary, size: 22),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: cinta,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(iconoBadge, size: 10, color: badgeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(p.nombre,
                                  style: DogoText.headlineSm,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: DogoColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${p.sexoInicial} • ${p.etiquetaEdad}',
                                style: DogoText.labelSm.copyWith(color: DogoColors.secondary),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${p.raza} • ${p.pesoKg.toStringAsFixed(1)} kg',
                          style: DogoText.bodySm,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            if (p.prioridad == PrioridadCola.rojoCritico) ...[
                              _puntoPulsante(DogoColors.error, true),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              'Prioridad Nivel ${_nivel(p)}',
                              style: DogoText.labelSm.copyWith(
                                color: badgeColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.timer,
                              size: 14, color: DogoColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            p.tiempoEspera,
                            style: DogoText.labelMd.copyWith(
                              color: p.prioridad == PrioridadCola.rojoCritico
                                  ? DogoColors.error
                                  : DogoColors.secondary,
                              fontWeight: p.prioridad == PrioridadCola.rojoCritico
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Panel diagnóstico
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DogoColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.diagnostico,
                            style: DogoText.labelMd.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: p.ubicacion.contains('Asignado') || p.ubicacion.contains('UCI')
                                ? (p.ubicacion.contains('UCI') ? DogoColors.tertiaryFixed : DogoColors.primary)
                                : DogoColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.ubicacion,
                            style: DogoText.labelSm.copyWith(
                              color: (p.ubicacion.contains('Asignado') && !p.ubicacion.contains('Pre-'))
                                  ? DogoColors.onPrimary
                                  : (p.ubicacion.contains('UCI')
                                      ? DogoColors.onTertiaryFixed
                                      : DogoColors.secondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          p.iconoDiagnostico ?? Icons.info_outline,
                          size: 15,
                          color: p.iconoUbicacionColor ?? DogoColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(p.detalleClinico, style: DogoText.bodySm),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Pie: tutor + acción
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: DogoColors.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.tutor ?? 'Tutor/a',
                      style: DogoText.labelSm.copyWith(color: DogoColors.secondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _accionPaciente(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _colorAccion(p),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            p.accionPrincipal,
                            style: DogoText.labelMd.copyWith(
                              color: _colorAccionTexto(p),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            p.accionPrincipal == 'Pase a Quirófano'
                                ? Icons.arrow_forward
                                : (p.accionPrincipal == 'Llamar a Box'
                                    ? Icons.volume_up
                                    : Icons.description_outlined),
                            size: 16,
                            color: _colorAccionTexto(p),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _nivel(PacienteCola p) => switch (p.prioridad) {
        PrioridadCola.rojoCritico => 1,
        PrioridadCola.ambarUrgente => 2,
        _ => 3,
      };

  Color _colorAccion(PacienteCola p) => switch (p.accionPrincipal) {
        'Pase a Quirófano' => DogoColors.error,
        'Llamar a Box' => DogoColors.primaryContainer,
        'Actualizar T°' => DogoColors.surfaceContainerHigh,
        _ => DogoColors.surfaceContainerHigh,
      };

  Color _colorAccionTexto(PacienteCola p) => switch (p.accionPrincipal) {
        'Pase a Quirófano' => DogoColors.onPrimary,
        'Llamar a Box' => DogoColors.onPrimaryContainer,
        _ => DogoColors.onSurface,
      };

  void _accionPaciente(PacienteCola p) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.accionPrincipal} — ${p.nombre} (${p.ubicacion})'),
        backgroundColor:
            p.prioridad == PrioridadCola.rojoCritico ? DogoColors.tertiary : DogoColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ------------------------------------------------------------ Barra flotante

  Widget _barraAccionesFlotante() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DogoSpacing.margin),
      child: Row(
        children: [
          // Botón refrescar
          GestureDetector(
            onTap: _refrescar,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DogoColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _refrescando
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: DogoColors.primary,
                      ),
                    )
                  : const Icon(Icons.sync, size: 22, color: DogoColors.onSurface),
            ),
          ),
          const SizedBox(width: DogoSpacing.sm),
          // Botón nuevo ingreso
          Expanded(
            child: GestureDetector(
              onTap: () => context.go('/pets/register'),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: DogoColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, size: 22, color: DogoColors.onPrimary),
                    SizedBox(width: 8),
                    Text(
                      'Ingreso Nuevo Paciente',
                      style: TextStyle(
                        color: DogoColors.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- Bottom nav

  Widget _bottomNav(BuildContext context) {
    Widget item(_Nav nav, IconData icono, String texto, bool activo) {
      return InkWell(
        onTap: () {
          final ruta = widget.rutasNav[nav];
          if (ruta != null) context.go(ruta);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono,
                  size: 24,
                  color: activo ? DogoColors.primary : DogoColors.onSurfaceVariant),
              const SizedBox(height: 2),
              Text(
                texto,
                style: DogoText.labelSm.copyWith(
                  color: activo ? DogoColors.primary : DogoColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BottomAppBar(
      color: DogoColors.surfaceContainerLowest,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(_Nav.triaje, Icons.pets, 'Triaje', false),
          item(_Nav.cola, Icons.format_list_bulleted, 'Cola', true),
          item(_Nav.clinicas, Icons.local_hospital, 'Clínicas', false),
          item(_Nav.salud, Icons.favorite, 'Salud Mascota', false),
        ],
      ),
    );
  }
}

enum _Nav { triaje, cola, clinicas, salud }
