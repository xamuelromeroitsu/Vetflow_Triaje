// Pantalla: Ficha de Signos Vitales en Tiempo Real — Sistema DOGO
// Design System: "Clinical Mint" (ver DESIGN.md adjunto)
// Carpeta: pantalla de mvp 0000
//
// Sigue la arquitectura feature-first del proyecto: la UI captura los datos,
// los empaqueta en el modelo de dominio VitalSigns y delega la evaluación al
// caso de uso EvaluateTriage (motor de reglas ADR-0003). El TriageResult real
// que devuelve el backend viaja como extra a la pantalla de Evaluación.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/vital_signs.dart';

import 'dogo_design_tokens.dart';

/// ---------------------------------------------------------------------------
/// Modelo de estado de los signos vitales capturados en pantalla
/// ---------------------------------------------------------------------------

enum TlcOption { hiperemico, normal, prolongado, cianotico }

extension TlcLabel on TlcOption {
  String get label => switch (this) {
        TlcOption.hiperemico => '< 1s (Hiperémico)',
        TlcOption.normal => '1-2s (Normal)',
        TlcOption.prolongado => '> 2s (Prolongado)',
        TlcOption.cianotico => 'Cianótico / Pálido',
      };
}

/// ---------------------------------------------------------------------------
/// Pantalla principal
/// ---------------------------------------------------------------------------

class FichaSignosVitalesScreen extends StatefulWidget {
  const FichaSignosVitalesScreen({
    super.key,
    required this.nombreMascota,
    required this.raza,
    required this.sexoTexto,
    required this.etiquetaEdad,
    required this.especie,
    this.fotoPath,
    this.nombreTecnico = 'Técnico de Admisión',
    this.rutaResultado = '/triage/result',
  });

  final String nombreMascota;
  final String raza;
  final String sexoTexto;
  final String etiquetaEdad;
  final String especie;
  final String? fotoPath;
  final String nombreTecnico;
  final String rutaResultado;

  @override
  State<FichaSignosVitalesScreen> createState() => _FichaSignosVitalesScreenState();
}

class _FichaSignosVitalesScreenState extends State<FichaSignosVitalesScreen> {
  // ---------------- Valores basales normales (botón Restablecer) ----------------
  static const double _tempBasal = 38.5;
  static const int _lpmBasal = 170;
  static const int _rpmBasal = 24;

  static const String _especiePerfil = 'Felino'; // cambia con los datos reales
  static const String _referenciaPerfil = 'Ref: Cuidados Críticos AAFP';

  // Rangos normales por defecto (se actualizan con el perfil real de especie).
  String _rangoTemp = 'Normal: 38.0°C – 39.2°C';
  String _rangoLpm = 'Normal: 140 – 220 lpm';
  String _rangoRpm = 'Normal: 20 – 30 rpm';

  // ---------------- Estado capturado ----------------
  double _tempC = 41.2;
  int _lpm = 230;
  int _rpm = 48;
  double _pesoKg = 4.2;
  TlcOption _tlc = TlcOption.prolongado;
  final _notasCtrl = TextEditingController(text:
      'El tutor informa respiración rápida tras exposición al exterior. Jadeo con boca abierta, marcha descoordinada, hipersalivación y extremidades calientes al tacto.');

  bool _calculando = false;
  String? _resultadoEtiqueta;
  bool _resultadoCritico = false;

  static const _etiquetasRapidas = <(String, IconData, bool)>[
    ('Jadeo con Boca Abierta', Icons.bolt, true),
    ('Estrés Térmico', Icons.warning_amber_rounded, true),
    ('Letargo', Icons.snooze, false),
  ];

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ Reset basal

  void _restablecer() {
    setState(() {
      _tempC = _tempBasal;
      _lpm = _lpmBasal;
      _rpm = _rpmBasal;
      _tlc = TlcOption.normal;
      _resultadoEtiqueta = null;
      _resultadoCritico = false;
      _notasCtrl.text =
          'Signos vitales de triaje rutinario comprobados. El paciente descansa cómodamente.';
    });
  }

  // ------------------------------------------------------------ Estado crítico

  bool get _tempCritica => _tempC >= 40.5;
  String get _estadoTemp =>
      _tempCritica ? 'CALOR EXTREMO' : (_tempC > 39.2 ? 'FIEBRE' : 'NORMAL');
  String get _estadoLpm {
    if (_lpm > 220) return 'TAQUICARDIA';
    if (_lpm < 140) return 'BRADICARDIA';
    return 'NORMAL';
  }

  String get _estadoRpm {
    if (_rpm > 35) return 'TAQUIPNEA MARCADA';
    if (_rpm > 30) return 'TAQUIPNEA';
    return 'NORMAL';
  }

  // ------------------------------------------- Cálculo del triaje (backend real)

  Future<void> _calcularTriaje() async {
    setState(() {
      _calculando = true;
      _resultadoEtiqueta = null;
    });

    try {
      final vitals = VitalSigns(
        tempC: _tempC,
        weightKg: _pesoKg,
        heartRate: _lpm,
        flags: [_tlc.label, _estadoRpm, if (_notasCtrl.text.trim().isNotEmpty) _notasCtrl.text.trim()],
      );

      final evaluateTriage = appDependencies.triageModule.evaluateTriage;
      final resultado = evaluateTriage(
        redFlags: const {},
        symptoms: const [],
        vitals: vitals,
        species: widget.especie,
        hasMissingVitals: false,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _calculando = false;
        _resultadoEtiqueta =
            'Nivel ${resultado.suggested.icon} ${resultado.suggested.label} — ${resultado.suggested.message}';
        _resultadoCritico = resultado.suggested == TriageLevel.emergencia;
      });

      if (mounted) {
        // El TriageResult real del motor viaja como extra a la Evaluación.
        context.go(widget.rutaResultado, extra: resultado);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _calculando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al calcular el triaje: $e'),
          backgroundColor: DogoColors.tertiary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DogoColors.surface,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          0, 0, 0, DogoSpacing.xl,
        ),
        children: [
          _bannerEmergencia(),
          _tarjetaPaciente(),
          const SizedBox(height: DogoSpacing.md),
          _tituloVitales(),
          _cardTemperatura(),
          _cardFrecuenciaCardiaca(),
          _cardFrecuenciaRespiratoria(),
          _cardTlc(),
          _cardPeso(),
          _cardObservaciones(),
          _acciones(),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DogoColors.onSurface),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/pets/register');
          }
        },
      ),
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: DogoColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pets,
                color: DogoColors.onPrimaryContainer, size: 16),
          ),
          const SizedBox(width: 4),
          const Text(
            'DOGO',
            style: TextStyle(
              color: DogoColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'TRIAGE',
            style: TextStyle(
              color: DogoColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Ficha de Signos Vitales',
              style: TextStyle(
                color: DogoColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      titleSpacing: 0,
      actions: [
        CircleAvatar(
          radius: 16,
          backgroundColor: DogoColors.surfaceContainerHigh,
          child: const Icon(Icons.person, size: 18, color: DogoColors.onSurfaceVariant),
        ),
        const SizedBox(width: DogoSpacing.md),
      ],
    );
  }

  // ---------------------------------------------------------- Banner emergencia

  Widget _bannerEmergencia() {
    if (!_tempCritica) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(
        DogoSpacing.margin, DogoSpacing.xs,
        DogoSpacing.margin, DogoSpacing.sm,
      ),
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.tertiary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCriticalShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'ALERTA CRÍTICA',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Alerta de Triaje Inmediato',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '¡Alerta de Hipertermia Crítica!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'La temperatura supera el umbral crítico (40.5°C). Alto riesgo de fallo multiorgánico. Se requiere protocolo de enfriamiento activo inmediato.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- Tarjeta paciente

  Widget _tarjetaPaciente() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DogoSpacing.margin),
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: DogoColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.fotoPath != null
                    ? const Icon(Icons.pets, color: DogoColors.primary, size: 26)
                    : const Icon(Icons.pets, color: DogoColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(widget.nombreMascota,
                              style: DogoText.headlineSm, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: DogoColors.tertiaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _tempCritica ? 'CÓDIGO ROJO' : 'ESTABLE',
                            style: DogoText.labelSm.copyWith(color: DogoColors.onTertiaryFixed),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${widget.raza} • ${widget.sexoTexto} • ${widget.etiquetaEdad}',
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
                  Text('PESO', style: DogoText.labelSm.copyWith(color: DogoColors.secondary)),
                  Text(
                    '${_pesoKg.toStringAsFixed(1)}\nkg',
                    style: DogoText.headlineSm.copyWith(height: 1.0),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: DogoColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: DogoColors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.pets,
                      color: DogoColors.onPrimaryContainer, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perfil $_especiePerfil Activo',
                    style: DogoText.labelLg,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _referenciaPerfil,
                  style: DogoText.labelMd.copyWith(color: DogoColors.secondary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: DogoColors.primary, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------- Titular

  Widget _tituloVitales() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DogoSpacing.margin),
      child: Row(
        children: [
          const Expanded(
            child: Text('Signos Vitales Registrados', style: DogoText.headlineSm),
          ),
          Text(
            'UNIDAD: MÉTRICO',
            style: DogoText.labelSm.copyWith(color: DogoColors.secondary, letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------- Helpers de tarjetas

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DogoSpacing.margin),
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCardShadow,
      ),
      child: child,
    );
  }

  Widget _cardHeader({
    required IconData icono,
    required Color colorIcono,
    required Color bgIcono,
    required String titulo,
    required String subtitulo,
    String? badge,
    Color? badgeBg,
    Color? badgeColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgIcono,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, size: 20, color: colorIcono),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: DogoText.labelLg),
              Text(subtitulo, style: DogoText.labelSm.copyWith(color: DogoColors.secondary)),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                if (badgeBg == DogoColors.tertiary) ...[
                  _puntoPulsante(Colors.white),
                  const SizedBox(width: 4),
                ],
                Text(
                  badge.toUpperCase(),
                  style: DogoText.labelSm.copyWith(color: badgeColor),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _puntoPulsante(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _lecturaTexto({
    required String valor,
    required String unidad,
    required TextStyle estiloValor,
    required String detalle1,
    required String detalle2,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(valor, style: estiloValor),
          const SizedBox(width: 4),
          Text(unidad,
              style: DogoText.headlineSm.copyWith(color: DogoColors.secondary)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(detalle1, style: DogoText.labelMd),

              Text(detalle2, style: DogoText.bodySm),

            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ Temperatura

  Widget _cardTemperatura() {
    final critico = _tempCritica;
    return _card(
      child: Column(
        children: [
          _cardHeader(
            icono: Icons.device_thermostat,
            colorIcono: DogoColors.tertiary,
            bgIcono: DogoColors.tertiaryFixed,
            titulo: 'Temperatura Corporal',
            subtitulo: _rangoTemp,
            badge: _estadoTemp,
            badgeBg: critico ? DogoColors.tertiary : DogoColors.secondaryContainer,
            badgeColor: critico ? DogoColors.onTertiary : DogoColors.onSecondaryContainer,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: critico
                  ? DogoColors.tertiaryFixed.withOpacity(0.3)
                  : DogoColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _tempC.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: DogoColors.tertiary,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('°C',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, color: DogoColors.tertiary)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      critico
                          ? '+${(_tempC - 39.2).abs().toStringAsFixed(1)}°C Aumento Crítico'
                          : 'Dentro de rango',
                      style: DogoText.labelMd.copyWith(
                        color: critico ? DogoColors.tertiary : DogoColors.primary,
                      ),
                    ),
                    Text('Basal: 38.5°C', style: DogoText.bodySm),
                  ],
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbColor: critico ? DogoColors.tertiary : DogoColors.primary,
              activeTrackColor: DogoColors.surfaceContainer,
              inactiveTrackColor: DogoColors.surfaceContainer,
              trackShape: const RoundedRectSliderTrackShape(),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 2),
            ),
            child: Slider(
              min: 36.0,
              max: 43.0,
              divisions: 70,
              value: _tempC,
              onChanged: (v) => setState(() => _tempC = double.parse(v.toStringAsFixed(1))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('36.0°C', style: DogoText.labelSm),
              Text('38.5°C Ópt.', style: DogoText.labelSm),
              Text('40.5°C Peligro',
                  style: DogoText.labelSm.copyWith(
                      color: DogoColors.tertiary, fontWeight: FontWeight.w700)),
              Text('43.0°C', style: DogoText.labelSm),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- Frecuencia cardíaca

  Widget _cardFrecuenciaCardiaca() {
    return _card(
      child: Column(
        children: [
          _cardHeader(
            icono: Icons.favorite_rounded,
            colorIcono: DogoColors.primary,
            bgIcono: DogoColors.surfaceContainerHigh,
            titulo: 'Frecuencia Cardíaca',
            subtitulo: _rangoLpm,
            badge: _estadoLpm,
            badgeBg: _lpm > 220 || _lpm < 140
                ? DogoColors.secondaryContainer
                : DogoColors.surfaceContainerLow,
            badgeColor: DogoColors.onSecondaryContainer,
          ),
          const SizedBox(height: 12),
          _lecturaTexto(
            valor: '$_lpm',
            unidad: 'lpm',
            estiloValor: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: DogoColors.onSurface,
            ),
            detalle1: '+${(_lpm - 220).abs().clamp(0, 999)} lpm Sobre Límite',
            detalle2: 'Ritmo: Regular',
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbColor: DogoColors.primary,
              activeTrackColor: DogoColors.surfaceContainer,
              inactiveTrackColor: DogoColors.surfaceContainer,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 2),
            ),
            child: Slider(
              min: 100,
              max: 280,
              divisions: 180,
              value: _lpm.toDouble(),
              onChanged: (v) => setState(() => _lpm = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100 lpm', style: DogoText.labelSm),
              Text('180 lpm Normal',
                  style: DogoText.labelSm.copyWith(color: DogoColors.primary)),
              Text('220 lpm Máx.', style: DogoText.labelSm),
              Text('280 lpm', style: DogoText.labelSm),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ Frecuencia respiratoria

  Widget _cardFrecuenciaRespiratoria() {
    return _card(
      child: Column(
        children: [
          _cardHeader(
            icono: Icons.air,
            colorIcono: DogoColors.primary,
            bgIcono: DogoColors.surfaceContainerHigh,
            titulo: 'Frecuencia Respiratoria',
            subtitulo: _rangoRpm,
            badge: _estadoRpm == 'NORMAL' ? null : _estadoRpm,
            badgeBg: DogoColors.tertiaryFixed,
            badgeColor: DogoColors.onTertiaryFixed,
          ),
          const SizedBox(height: 12),
          _lecturaTexto(
            valor: '$_rpm',
            unidad: 'rpm',
            estiloValor: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: DogoColors.onSurface,
            ),
            detalle1: '+${(_rpm - 30).abs().clamp(0, 999)} Sobre Límite',
            detalle2: 'Patrón: Superficial',
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbColor: DogoColors.primary,
              activeTrackColor: DogoColors.surfaceContainer,
              inactiveTrackColor: DogoColors.surfaceContainer,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 2),
            ),
            child: Slider(
              min: 10,
              max: 80,
              divisions: 70,
              value: _rpm.toDouble(),
              onChanged: (v) => setState(() => _rpm = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10', style: DogoText.labelSm),
              Text('25 Normal',
                  style: DogoText.labelSm.copyWith(color: DogoColors.primary)),
              Text('35 Umbral',
                  style: DogoText.labelSm.copyWith(
                      color: DogoColors.tertiary, fontWeight: FontWeight.w700)),
              Text('80', style: DogoText.labelSm),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------- TLC

  Widget _cardTlc() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            icono: Icons.timer_outlined,
            colorIcono: DogoColors.primary,
            bgIcono: DogoColors.surfaceContainerHigh,
            titulo: 'Tiempo de Llenado Capilar (TLC)',
            subtitulo: 'Evaluación de perfusión en mucosas',
            badge: 'Sel: ${_tlc.label.split('(').first.trim()}',
            badgeBg: DogoColors.surfaceContainer,
            badgeColor: DogoColors.onSurface,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: DogoSpacing.sm,
            mainAxisSpacing: DogoSpacing.sm,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.6,
            children: [
              for (final op in TlcOption.values) _pillTlc(op),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillTlc(TlcOption opcion) {
    final activo = _tlc == opcion;
    return GestureDetector(
      onTap: () => setState(() => _tlc = opcion),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: activo ? DogoColors.primaryContainer : DogoColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          opcion.label,
          style: DogoText.labelMd.copyWith(
            color: activo ? DogoColors.onPrimaryContainer : DogoColors.onSurface,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------- Peso

  Widget _cardPeso() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DogoColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.scale, color: DogoColors.primary, size: 20),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Masa Corporal del Paciente', style: DogoText.labelLg),
                Text(
                  'Registrado hoy en báscula de admisión',
                  style: DogoText.labelSm,
                ),
              ],
            ),
          ),
          Text(
            _pesoKg.toStringAsFixed(1),
            style: DogoText.headlineSm,
          ),
          const SizedBox(width: 4),
          Text('kg',
              style: DogoText.labelLg.copyWith(
                  color: DogoColors.secondary, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ Observaciones

  Widget _cardObservaciones() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DogoColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_outlined,
                    color: DogoColors.primary, size: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Observaciones de Triaje', style: DogoText.labelLg)),
              Text(
                widget.nombreTecnico,
                style: DogoText.labelSm.copyWith(color: DogoColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DogoColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _notasCtrl,
              maxLines: 3,
              style: DogoText.bodyMd,
              decoration: const InputDecoration(
                hintText: 'Añadir notas específicas sobre presentación física...',
                hintStyle: TextStyle(color: DogoColors.outlineVariant, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in _etiquetasRapidas)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: t.$3 ? DogoColors.tertiaryFixed : DogoColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.$2,
                        size: 14,
                        color: t.$3 ? DogoColors.onTertiaryFixed : DogoColors.onSurface,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t.$1,
                        style: DogoText.labelSm.copyWith(
                          color: t.$3 ? DogoColors.onTertiaryFixed : DogoColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ Acciones

  Widget _acciones() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DogoSpacing.margin, DogoSpacing.lg,
        DogoSpacing.margin, 0,
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _calculando ? null : _calcularTriaje,
              style: ElevatedButton.styleFrom(
                backgroundColor: _resultadoCritico
                    ? DogoColors.tertiary
                    : (_resultadoEtiqueta != null
                        ? DogoColors.primaryFixed
                        : DogoColors.primaryContainer),
                foregroundColor:
                    _resultadoCritico ? DogoColors.onTertiary : DogoColors.onPrimaryFixed,
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _calculando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(DogoColors.onPrimaryFixed),
                      ),
                    )
                  : Icon(
                      _resultadoCritico
                          ? Icons.check_circle
                          : Icons.health_and_safety,
                      size: 22,
                    ),
              label: Text(
                _calculando
                    ? 'Calculando Agudeza de Triaje...'
                    : (_resultadoEtiqueta ?? 'Calcular Nivel de Triaje'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: DogoSpacing.sm),
          TextButton.icon(
            onPressed: _restablecer,
            style: TextButton.styleFrom(
              foregroundColor: DogoColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text(
              'Restablecer a Valores Basales Normales',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
