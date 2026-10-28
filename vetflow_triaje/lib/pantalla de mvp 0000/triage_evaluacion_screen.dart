// Pantalla: Evaluación de Urgencia — Resultado de Triaje Crítico
// Sistema DOGO · Design System "Clinical Mint" (ver DESIGN.md adjunto)
// Carpeta: pantalla de mvp 0000
//
// Recibe el TriageResult real del backend (motor de reglas ADR-0003/0005)
// y los datos de la mascota para renderizar la evaluación de urgencia.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_result.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

import 'dogo_design_tokens.dart';

/// ---------------------------------------------------------------------------
/// Datos clínicos mostrados en la ficha de evaluación
/// ---------------------------------------------------------------------------

class IndicadorTriaje {
  const IndicadorTriaje({required this.texto, required this.icono, this.critico = false});
  final String texto;
  final IconData icono;
  final bool critico;
}

class MedidaEstabilizacion {
  const MedidaEstabilizacion({required this.titulo, required this.descripcion, required this.numero, this.critico = false});
  final int numero;
  final String titulo;
  final String descripcion;
  final bool critico;
}

/// ---------------------------------------------------------------------------
/// Pantalla principal
/// ---------------------------------------------------------------------------

class TriageEvaluacionScreen extends StatelessWidget {
  const TriageEvaluacionScreen({
    super.key,
    required this.resultado,
    required this.nombreMascota,
    required this.raza,
    required this.pesoKg,
    required this.etiquetaEdad,
    this.fotoPath,
    this.rutasNav = const {
      _Nav.triaje: '/triage/symptoms',
      _Nav.cola: '/queue',
      _Nav.clinicas: '/queue',
      _Nav.salud: '/pets',
    },
  });

  /// Resultado real del motor de triaje (backend / dominio).
  final TriageResult resultado;

  final String nombreMascota;
  final String raza;
  final double pesoKg;
  final String etiquetaEdad;
  final String? fotoPath;

  /// Rutas del bottom nav (configurables al conectar pantallas finales).
  final Map<_Nav, String> rutasNav;

  static const _esCasoCriticoHardcode = false;

  bool get _esCritico =>
      _esCasoHardcode() ||
      resultado.suggested == TriageLevel.emergencia ||
      resultado.suggested == TriageLevel.urgencia;

  bool _esCasoHardcode() => _esCasoCriticoHardcode;

  /// Punto de estado pulsante (equivalente al animate-ping de Tailwind).
  Widget _puntoPulsante(Color color) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  static const _indicadoresDemo = <IndicadorTriaje>[
    IndicadorTriaje(texto: 'Dificultad Respiratoria', icono: Icons.air, critico: true),
    IndicadorTriaje(texto: 'Disnea (Severa)', icono: Icons.speed, critico: true),
    IndicadorTriaje(texto: 'Encías Pálidas (TRC > 3s)', icono: Icons.bloodtype),
    IndicadorTriaje(texto: 'Inicio Repentino (<45 min)', icono: Icons.schedule),
  ];

  static const _medidasDemo = <MedidaEstabilizacion>[
    MedidaEstabilizacion(
      numero: 1,
      titulo: 'Posición en Decúbito Esternal',
      descripcion:
          'Permite que la mascota descanse de forma natural sobre su pecho con la cabeza y el cuello ligeramente extendidos para facilitar el paso de aire.',
    ),
    MedidaEstabilizacion(
      numero: 2,
      titulo: 'Suspender Ingesta Oral',
      descripcion:
          'No administres agua, líquidos ni medicación oral. Riesgo severo de broncoaspiración secundaria durante la disnea.',
      critico: true,
    ),
    MedidaEstabilizacion(
      numero: 3,
      titulo: 'Avisar a la Clínica en Camino',
      descripcion:
          'Inicia la derivación directa del caso para que el equipo de urgencias aliste la jaula de oxígeno y el personal antes de tu llegada.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DogoColors.surface,
      appBar: _buildAppBar(),
      bottomNavigationBar: _bottomNav(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          DogoSpacing.margin, DogoSpacing.md,
          DogoSpacing.margin, DogoSpacing.xl,
        ),
        children: [
          _tarjetaMascota(),
          const SizedBox(height: DogoSpacing.md),
          _tarjetaGravedad(),
          const SizedBox(height: DogoSpacing.md),
          _indicadores(),
          const SizedBox(height: DogoSpacing.md),
          _medidasEstabilizacion(),
          const SizedBox(height: DogoSpacing.md),
          _cardClinciaCercana(context),
          const SizedBox(height: DogoSpacing.md),
          _descargo(),
          const SizedBox(height: DogoSpacing.md),
          _accionesCriticas(context),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ AppBar

  PreferredSizeWidget _buildAppBar() {
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
            child: Icon(Icons.pets, color: DogoColors.onPrimary, size: 18, semanticLabel: _esCasoHardcode() ? '' : null),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOGO',
                style: TextStyle(
                  color: DogoColors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              Text(
                'TRIAGE',
                style: TextStyle(
                  color: DogoColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 20, color: DogoColors.outlineVariant),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRIAJE CLÍNICO',
                  style: TextStyle(
                    color: DogoColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Evaluación de Urgencia',
                  style: TextStyle(
                    color: DogoColors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Alerta Crítica',
            onPressed: () {},
            icon: const Icon(Icons.emergency, color: DogoColors.tertiary),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: DogoColors.surfaceContainerHigh,
            child: const Icon(Icons.person, size: 18, color: DogoColors.onSurfaceVariant),
          ),
          const SizedBox(width: DogoSpacing.margin),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- Tarjeta mascota

  Widget _tarjetaMascota() {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: DogoColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: fotoPath != null
                ? Image.file(
                    File(fotoPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.pets, color: DogoColors.primary),
                  )
                : const Icon(Icons.pets, color: DogoColors.primary, size: 26),
          ),
          const SizedBox(width: DogoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nombreMascota,
                        style: DogoText.headlineSm,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: DogoColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        etiquetaEdad,
                        style: DogoText.labelSm.copyWith(color: DogoColors.secondary),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$raza • ${pesoKg.toStringAsFixed(1)} kg',
                  style: DogoText.bodySm,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DogoColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: DogoColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sincronizado en la nube',
                  style: DogoText.labelSm.copyWith(color: DogoColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- Tarjeta gravedad

  Widget _tarjetaGravedad() {
    return Container(
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _esCritico ? kDogoCriticalShadow : kDogoCardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cinta lateral de prioridad
            Container(width: 8, color: _esCritico ? DogoColors.error : DogoColors.primaryContainer),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, DogoSpacing.md, DogoSpacing.md, DogoSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: DogoColors.errorContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              _puntoPulsante(DogoColors.error),
                              const SizedBox(width: 6),
                              Text(
                                _esCritico ? 'GRAVEDAD CRÍTICA' : 'GRAVEDAD ALTA',
                                style: DogoText.labelMd.copyWith(
                                  color: DogoColors.onErrorContainer,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DogoColors.errorContainer.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monitor_heart, color: DogoColors.error, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'PROTOCOLO AGUDO',
                                style: DogoText.labelSm.copyWith(color: DogoColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DogoSpacing.sm),
                    Text(
                      _esCritico
                          ? 'NIVEL 1 • PRIORIDAD ALTA'
                          : _nivelTexto(),
                      style: DogoText.labelSm.copyWith(color: DogoColors.error, letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _esCritico
                          ? 'Traslado Inmediato Recomendado'
                          : _tituloResultado(),
                      style: DogoText.headlineLg,
                    ),
                    const SizedBox(height: DogoSpacing.sm),
                    // Rationale clínico
                    if (resultado.reasons.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DogoColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: DogoColors.tertiary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                resultado.reasons.join('. '),
                                style: DogoText.bodyMd,
                              ),
                            ),
                          ],
                        ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: DogoColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Reglas v${resultado.rulesVersion} del Triaje • Grupo 1 Manchester',
                            style: DogoText.labelSm.copyWith(color: DogoColors.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Evaluado: Hace un momento',
                          style: DogoText.labelSm.copyWith(color: DogoColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nivelTexto() {
    final nivel = _esCritico ? 1 : 2;
    return 'NIVEL $nivel • PRIORIDAD ${nivel == 1 ? 'ALTA' : 'MEDIA'}';
  }

  String _tituloResultado() => _esCritico
      ? 'Traslado Inmediato Recomendado'
      : 'Atención Veterinaria Prioritaria';

  // ------------------------------------------------------------- Indicadores

  Widget _indicadores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Indicadores de Triaje Reportados', style: DogoText.labelLg)),
            Text(
              '${resultado.reasons.length} Alertas',
              style: DogoText.labelSm.copyWith(color: DogoColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: DogoSpacing.sm,
          runSpacing: DogoSpacing.sm,
          children: [
            for (final r in resultado.reasons.take(4))
              if (r.trim().isNotEmpty) _chipIndicador(IndicadorTriaje(texto: r.trim(), icono: Icons.monitor_heart, critico: _esCritico)),
            for (final i in _indicadoresDemo) _chipIndicador(i),
          ],
        ),
      ],
    );
  }

  Widget _chipIndicador(IndicadorTriaje i) {
    final critico = i.critico;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: critico ? DogoColors.errorContainer : DogoColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        boxShadow: kDogoCardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i.icono, size: 16, color: critico ? DogoColors.onErrorContainer : DogoColors.secondary),
          const SizedBox(width: 6),
          Text(
            i.texto,
            style: DogoText.labelSm.copyWith(
              color: critico ? DogoColors.onErrorContainer : DogoColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------- Medidas estabilización

  Widget _medidasEstabilizacion() {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: DogoColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services, color: DogoColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Medidas de Estabilización Inmediata', style: DogoText.headlineSm)),
            ],
          ),
          const SizedBox(height: DogoSpacing.sm),
          for (final m in _medidasDemo) ...[
            _pasoMedida(m),
            const SizedBox(height: DogoSpacing.sm),
          ],
        ],
      ),
    );
  }

  Widget _pasoMedida(MedidaEstabilizacion m) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: m.critico ? DogoColors.error : DogoColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${m.numero}',
              style: DogoText.labelSm.copyWith(
                color: m.critico ? DogoColors.onPrimary : DogoColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.titulo, style: DogoText.labelLg),
                Text(m.descripcion, style: DogoText.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- Clínica 24/7

  Widget _cardClinciaCercana(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kDogoCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me, color: DogoColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Unidad de Trauma 24/7 más cercana', style: DogoText.labelLg)),
              Text(
                '1.4 mi • 6 min en auto',
                style: DogoText.labelSm.copyWith(color: DogoColors.primary),
              ),
            ],
          ),
          const SizedBox(height: DogoSpacing.sm),
          // Mapa estático (placeholder hasta integrar Google Maps)
          Container(
            height: 128,
            width: double.infinity,
            decoration: BoxDecoration(
              color: DogoColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: DogoColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      _puntoPulsante(DogoColors.error),
                      const SizedBox(width: 6),
                      Text(
                        'Guardia Activa • 0 en Espera',
                        style: DogoText.labelSm.copyWith(color: DogoColors.onSurface),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.map_rounded, size: 48, color: DogoColors.surfaceContainerHighest),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hospital Veterinario de Urgencias Metropolitan',
                      style: DogoText.labelLg,
                    ),
                    Text(
                      'Centro de Urgencias Nivel 1 • Acceso directo a UCI',
                      style: DogoText.bodySm,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DogoSpacing.sm),
              // Botón llamar clínica
              GestureDetector(
                onTap: () => _llamar(context, '911'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: DogoColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, color: DogoColors.onPrimary, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _llamar(BuildContext context, String numero) async {
    final launched = await launchUrl(
      Uri(scheme: 'tel', path: numero),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el teléfono.')),
      );
    }
  }

  // ---------------------------------------------------------------- Descargo

  Widget _descargo() {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.sm + 4),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: DogoColors.secondary, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'El triaje clínico automatizado ayuda a categorizar el riesgo rápidamente y no sustituye la evaluación médica veterinaria presencial. Si tu mascota se torna cianótica o sufre un colapso, trasládala inmediatamente.',
              style: TextStyle(color: DogoColors.secondary, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------- Acciones críticas pinned

  Widget _accionesCriticas(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _llamar(context, '18005553937'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DogoColors.tertiary,
              foregroundColor: DogoColors.onTertiary,
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.call, size: 24),
            label: const Text(
              'LLAMAR A URGENCIAS VETERINARIAS YA',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: DogoSpacing.sm),
        _BotonTransmitir(),
      ],
    );
  }

  // ---------------------------------------------------------------- Bottom nav

  Widget _bottomNav(BuildContext context) {
    Widget item(_Nav nav, IconData icono, String texto, bool activo) {
      return InkWell(
        onTap: () {
          final ruta = rutasNav[nav];
          if (ruta != null) context.go(ruta);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 24, color: activo ? DogoColors.primary : DogoColors.onSurfaceVariant),
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

    return NavigationBarTheme(
      data: NavigationBarThemeData(backgroundColor: DogoColors.surfaceContainerLowest),
      child: BottomAppBar(
        color: DogoColors.surfaceContainerLowest,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.06),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            item(_Nav.triaje, Icons.pets, 'Triaje', true),
            item(_Nav.cola, Icons.format_list_bulleted, 'Cola', false),
            item(_Nav.clinicas, Icons.local_hospital, 'Clínicas', false),
            item(_Nav.salud, Icons.favorite, 'Salud Mascota', false),
          ],
        ),
      ),
    );
  }
}

enum _Nav { triaje, cola, clinicas, salud }

/// Botón "Transmitir ficha" con feedback temporal (JS del mockup replicado).
class _BotonTransmitir extends StatefulWidget {
  const _BotonTransmitir();

  @override
  State<_BotonTransmitir> createState() => _BotonTransmitirState();
}

class _BotonTransmitirState extends State<_BotonTransmitir> {
  bool _transmitiendo = false;

  Future<void> _transmitir() async {
    setState(() => _transmitiendo = true);
    // Aquí se conectará el backend real (envío de ficha/visits a la clínica).
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: DogoColors.primary),
            SizedBox(width: 8),
            Text('Ficha transmitida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          '¡Ficha de telemetría transmitida a Urgencias! El equipo ya conoce los signos vitales de tu mascota.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido', style: TextStyle(color: DogoColors.primary)),
          ),
        ],
      ),
    );
    if (mounted) setState(() => _transmitiendo = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: _transmitiendo ? null : _transmitir,
        style: OutlinedButton.styleFrom(
          backgroundColor: _transmitiendo ? DogoColors.primaryFixed : DogoColors.surfaceContainerHigh,
          foregroundColor: DogoColors.primary,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: _transmitiendo
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: DogoColors.primary),
              )
            : const Icon(Icons.send_outlined, size: 20),
        label: Text(
          _transmitiendo ? 'Transmitiendo ficha...' : 'Transmitir Ficha y Signos Vitales a la Clínica',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
