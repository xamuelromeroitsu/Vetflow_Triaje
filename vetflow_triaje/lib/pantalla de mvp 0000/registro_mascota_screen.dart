// Pantalla: Registrar Nueva Mascota (US-01) — Sistema DOGO
// Design System: "Clinical Mint" (ver DESIGN.md adjunto)
// Carpeta: pantalla de mvp 0000

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vetflow_triaje/main.dart';
import 'dogo_design_tokens.dart';

/// ---------------------------------------------------------------------------
/// Modelo de datos de la mascota
/// ---------------------------------------------------------------------------

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

/// ---------------------------------------------------------------------------
/// Pantalla principal
/// ---------------------------------------------------------------------------

class RegistroMascotaScreen extends StatefulWidget {
  /// Callback al continuar al Triaje (US-02).
  final void Function(MascotaRegistro mascota)? onGuardar;

  /// Ruta a la que navega al guardar (Pantalla 4: síntomas del triaje).
  final String rutaSiguiente;

  const RegistroMascotaScreen({super.key, this.onGuardar, this.rutaSiguiente = '/triage/symptoms'});

  @override
  State<RegistroMascotaScreen> createState() => _RegistroMascotaScreenState();
}

class _RegistroMascotaScreenState extends State<RegistroMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mascota = MascotaRegistro();

  final _nombreCtrl = TextEditingController();
  final _razaCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _condicionesCtrl = TextEditingController();

  bool _guardando = false;

  /// Caso de uso real de backend (Firestore) para persistir la mascota.
  late final _registrarMascota = appDependencies.petModule.registerPet;

  static const _razasPerro = [
    'Golden Retriever',
    'Mestizo / Criollo',
    'Labrador Retriever',
    'Bulldog Francés',
    'Pastor Alemán',
    'Pug',
    'Caniche / Poodle',
  ];

  static const _razasGato = [
    'Siamés (Gato)',
    'Común Europeo (Gato)',
    'Mestizo (Gato)',
    'Persa (Gato)',
    'Bengalí (Gato)',
  ];

  String get _especieEmoji => switch (_mascota.especie) {
        Especie.perro => '🐕',
        Especie.gato => '🐈',
        Especie.exotico => '🦎',
      };

  List<String> get _razasSugeridas => switch (_mascota.especie) {
        Especie.perro => _razasPerro,
        Especie.gato => _razasGato,
        Especie.exotico => const ['Conejo', 'Hurón', 'Ave', 'Reptil'],
      };

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _razaCtrl.dispose();
    _edadCtrl.dispose();
    _pesoCtrl.dispose();
    _condicionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (foto != null) setState(() => _mascota.fotoPath = foto.path);
  }

  Future<void> _guardarYContinuar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos obligatorios (*)'),
          backgroundColor: DogoColors.tertiary,
        ),
      );
      return;
    }
    _formKey.currentState!.save();
    setState(() => _guardando = true);

    try {
      final ownerId = appDependencies.authModule.authRepository.currentAccount?.uid ??
          'local-demo-owner';

      // Convierte la edad al formato del backend (meses).
      final edadMeses = switch (_mascota.unidadEdad) {
        'Meses' => _mascota.edad ?? 0,
        _ => (_mascota.edad ?? 0) * 12,
      };

      final resultado = await _registrarMascota(
        name: _mascota.nombre.trim(),
        species: switch (_mascota.especie) {
          Especie.perro => 'perro',
          Especie.gato => 'gato',
          Especie.exotico => 'reptil',
        },
        breed: _mascota.raza.trim(),
        ageMonths: edadMeses.round(),
        ownerId: ownerId,
        sex: _mascota.sexo == Sexo.macho ? 'Macho' : 'Hembra',
        neutered: _mascota.esterilizado,
        weightKg: _mascota.pesoKg,
        history: null,
        allergies: _mascota.condicionesPrevias.trim().isEmpty
            ? null
            : _mascota.condicionesPrevias.trim(),
      );

      if (!mounted) return;

      final error = resultado.when(
        ok: (_) => null,
        failure: (domainError) => domainError,
      );
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: DogoColors.tertiary,
          ),
        );
        setState(() => _guardando = false);
        return;
      }

      // Éxito: navega a la Pantalla 4 (síntomas del triaje).
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Paciente Guardado! Continuando al Triaje...'),
          backgroundColor: DogoColors.primary,
        ),
      );
      widget.onGuardar?.call(_mascota);
      context.go(widget.rutaSiguiente);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la mascota. Revisa tu conexión.'),
          backgroundColor: DogoColors.tertiary,
        ),
      );
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DogoColors.surface,
      appBar: _buildAppBar(context),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            DogoSpacing.margin, DogoSpacing.sm,
            DogoSpacing.margin, DogoSpacing.xl,
          ),
          children: [
            _subHeader(),
            const SizedBox(height: DogoSpacing.sm),
            _barraProgreso(),
            const SizedBox(height: DogoSpacing.md),
            _bannerInformativo(),
            const SizedBox(height: DogoSpacing.lg),
            _selectorFoto(),
            const SizedBox(height: DogoSpacing.lg),
            _campoNombre(),
            const SizedBox(height: DogoSpacing.md),
            _selectorEspecie(),
            const SizedBox(height: DogoSpacing.md),
            _campoRaza(),
            const SizedBox(height: DogoSpacing.md),
            _filaEdadPeso(),
            const SizedBox(height: DogoSpacing.md),
            _sexoYReproduccion(),
            const SizedBox(height: DogoSpacing.md),
            _campoCondiciones(),
            const SizedBox(height: DogoSpacing.md),
            _insigniaProtocolo(),
            const SizedBox(height: DogoSpacing.md),
            _botonGuardar(),
          ],
        ),
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
        icon: const Icon(Icons.arrow_back, color: DogoColors.onSurfaceVariant),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: DogoColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pets, color: DogoColors.onPrimary, size: 18),
          ),
          const SizedBox(width: 8),
          const Text(
            'DOGO',
            style: TextStyle(
              color: DogoColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      actions: [
        const Text(
          'REGISTRO DE MASCOTA',
          style: TextStyle(
            color: DogoColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: DogoSpacing.md),
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: DogoSpacing.margin),
          decoration: const BoxDecoration(
            color: DogoColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: DogoColors.onPrimary, size: 18),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- Sub-header

  Widget _subHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DogoSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DogoColors.surfaceContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back,
                size: 20, color: DogoColors.onSurface),
          ),
          const SizedBox(width: DogoSpacing.sm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar Nueva Mascota',
                  style: TextStyle(
                    color: DogoColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ADMISIÓN RÁPIDA',
                  style: TextStyle(
                    color: DogoColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: DogoColors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'US-01',
              style: TextStyle(
                color: DogoColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- Barra progreso

  Widget _barraProgreso() {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in,
                  color: DogoColors.primary, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Paso 1 de 2: Datos Clínicos de la Mascota',
                  style: TextStyle(
                    color: DogoColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                '50%',
                style: TextStyle(
                  color: DogoColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.5,
              minHeight: 8,
              backgroundColor: DogoColors.surfaceContainer,
              valueColor:
                  const AlwaysStoppedAnimation(DogoColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- Banner

  Widget _bannerInformativo() {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: DogoColors.primary, size: 24),
          const SizedBox(width: DogoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Importancia en el Triaje',
                  style: TextStyle(
                    color: DogoColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Un peso y especie exactos son vitales para calcular los rangos de signos vitales e índices de alerta en el triaje de DOGO.',
                  style: TextStyle(
                    color: DogoColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- Selector foto

  Widget _selectorFoto() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: DogoColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: _mascota.fotoPath != null
                  ? Image.file(
                      File(_mascota.fotoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.pets, color: DogoColors.primary, size: 44),
                    )
                  : Icon(
                      Icons.pets,
                      color: DogoColors.primary,
                      size: 44,
                      semanticLabel: _especieEmoji,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _seleccionarFoto,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DogoColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: DogoColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.photo_camera,
                      color: DogoColors.onPrimary, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DogoSpacing.sm),
        const Text(
          'Foto del Paciente (Opcional)',
          style: TextStyle(
            color: DogoColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ Campos

  Widget _etiqueta(String texto, {bool obligatorio = false, String? sufijo}) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            text: texto,
            style: const TextStyle(
              color: DogoColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            children: obligatorio
                ? const [TextSpan(text: ' *', style: TextStyle(color: DogoColors.tertiary))]
                : null,
          ),
        ),
        const Spacer(),
        if (sufijo != null)
          Text(
            sufijo,
            style: TextStyle(
              color: sufijo == 'Opcional'
                  ? DogoColors.secondary
                  : DogoColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  InputDecoration _decoracionCampo(IconData? icono, String hint,
      {String? sufijo, Color? borde}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borde ?? DogoColors.surfaceContainerHighest),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: DogoColors.outlineVariant, fontSize: 14),
      filled: true,
      fillColor: DogoColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: border.copyWith(
        borderSide: BorderSide(color: borde ?? DogoColors.surfaceContainerHighest, width: 1),
      ),
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: DogoColors.primaryContainer, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: DogoColors.tertiary, width: 1.5),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: DogoColors.tertiary, width: 1.5),
      ),
      prefixIcon: icono != null
          ? Icon(icono, size: 20, color: DogoColors.secondary)
          : null,
      suffixText: sufijo,
      suffixStyle:
          const TextStyle(color: DogoColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  Widget _campoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiqueta('Nombre de la Mascota', obligatorio: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nombreCtrl,
          decoration: _decoracionCampo(Icons.flag, 'Ej. Rocky, Luna, Milo'),
          style: const TextStyle(color: DogoColors.onSurface, fontSize: 14),
          validator: (v) =>
              (v == null || v.trim().length < 2) ? 'Mínimo 2 caracteres' : null,
          onChanged: (v) => _mascota.nombre = v,
        ),
      ],
    );
  }

  Widget _selectorEspecie() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiqueta('Especie', obligatorio: true),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final especie in Especie.values) ...[
              Expanded(
                child: _chipEspecie(especie),
              ),
              if (especie != Especie.exotico) const SizedBox(width: DogoSpacing.xs),
            ],
          ],
        ),
      ],
    );
  }

  Widget _chipEspecie(Especie especie) {
    final seleccionado = _mascota.especie == especie;
    final nombre = switch (especie) {
      Especie.perro => 'Perro',
      Especie.gato => 'Gato',
      Especie.exotico => 'Exótico',
    };
    final emoji = switch (especie) {
      Especie.perro => '🐕',
      Especie.gato => '🐈',
      Especie.exotico => '🦎',
    };
    return GestureDetector(
      onTap: () => setState(() => _mascota.especie = especie),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: seleccionado ? DogoColors.primary : DogoColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              nombre,
              style: TextStyle(
                color: seleccionado ? DogoColors.onPrimary : DogoColors.onSurface,
                fontSize: 12,
                fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoRaza() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiqueta('Raza', obligatorio: true),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (value) {
            final texto = value.text.toLowerCase();
            if (texto.isEmpty) return _razasSugeridas;
            return _razasSugeridas.where((r) => r.toLowerCase().contains(texto));
          },
          fieldViewBuilder: (context, ctrl, focus, onFieldSubmitted) {
            ctrl.value = TextEditingValue(
              text: _razaCtrl.text,
              selection: TextSelection.collapsed(offset: _razaCtrl.text.length),
            );
            return TextFormField(
              controller: ctrl,
              focusNode: focus,
              decoration: _decoracionCampo(Icons.category,
                  'Ej. Golden Retriever, Mestizo, Siames...'),
              style: const TextStyle(color: DogoColors.onSurface, fontSize: 14),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              onChanged: (v) => _mascota.raza = v,
              onFieldSubmitted: (_) => onFieldSubmitted(),
            );
          },
          onSelected: (v) => _mascota.raza = v,
        ),
      ],
    );
  }

  InputDecoration _decoracionEdadPeso({String? sufijo}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      filled: true,
      fillColor: DogoColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: DogoColors.primaryContainer, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: DogoColors.tertiary, width: 1.5),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: DogoColors.tertiary, width: 1.5),
      ),
      suffixText: sufijo,
      suffixStyle:
          const TextStyle(color: DogoColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  Widget _filaEdadPeso() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Edad
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _etiqueta('Edad', obligatorio: true),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: DogoColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: TextFormField(
                        controller: _edadCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: _decoracionEdadPeso(),
                        style: const TextStyle(
                          color: DogoColors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        validator: (v) =>
                            (double.tryParse(v ?? '') == null) ? ' ' : null,
                        onSaved: (v) =>
                            _mascota.edad = double.tryParse(v ?? ''),
                        onChanged: (v) =>
                            _mascota.edad = double.tryParse(v),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: const BoxDecoration(
                          color: DogoColors.surfaceContainerLow,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              value: _mascota.unidadEdad,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                              style: const TextStyle(
                                color: DogoColors.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              dropdownColor: DogoColors.surfaceContainerLow,
                              items: const [
                                DropdownMenuItem(
                                    value: 'Años', child: Text('Años')),
                                DropdownMenuItem(
                                    value: 'Meses', child: Text('Meses')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _mascota.unidadEdad = v ?? 'Años'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DogoSpacing.md),
        // Peso
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _etiqueta('Peso', obligatorio: true, sufijo: 'Kg'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pesoCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _decoracionCampo(null, '14.5', sufijo: 'kg'),
                style: const TextStyle(
                  color: DogoColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                validator: (v) {
                  final w = double.tryParse(v ?? '');
                  if (w == null || w <= 0 || w > 120) return 'Peso inválido';
                  return null;
                },
                onSaved: (v) => _mascota.pesoKg = double.tryParse(v ?? ''),
                onChanged: (v) => _mascota.pesoKg = double.tryParse(v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sexoYReproduccion() {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.md),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _etiqueta('Sexo y Reproducción', obligatorio: true),
          const SizedBox(height: DogoSpacing.sm),
          Row(
            children: [
              Expanded(child: _btnSexo(Sexo.macho, Icons.male, 'Macho')),
              const SizedBox(width: DogoSpacing.xs),
              Expanded(child: _btnSexo(Sexo.hembra, Icons.female, 'Hembra')),
            ],
          ),
          const SizedBox(height: DogoSpacing.sm),
          Row(
            children: [
              Checkbox(
                value: _mascota.esterilizado,
                activeColor: DogoColors.primary,
                onChanged: (v) => setState(() => _mascota.esterilizado = v ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Esterilizado / Castrado',
                      style: TextStyle(
                        color: DogoColors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Relevante para diagnósticos hormonales y reproductivos',
                      style: TextStyle(
                        color: DogoColors.onSurfaceVariant,
                        fontSize: 13,
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

  Widget _btnSexo(Sexo sexo, IconData icono, String texto) {
    final seleccionado = _mascota.sexo == sexo;
    return GestureDetector(
      onTap: () => setState(() => _mascota.sexo = sexo),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: seleccionado
              ? DogoColors.secondaryContainer
              : DogoColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 18, color: DogoColors.onSurface),
            const SizedBox(width: 6),
            Text(
              texto,
              style: TextStyle(
                color: DogoColors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoCondiciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiqueta('Condiciones Previas o Alergias', sufijo: 'Opcional'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _condicionesCtrl,
          maxLines: 3,
          decoration: _decoracionCampo(null,
              'Ej. Alergia a cefalosporinas, soplo cardíaco Grado II, epilepsia diagnosticada...')
              .copyWith(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(color: DogoColors.onSurface, fontSize: 14),
          onChanged: (v) => _mascota.condicionesPrevias = v,
        ),
      ],
    );
  }

  // --------------------------------------------------------- Insignia y botón

  Widget _insigniaProtocolo() {
    return Container(
      padding: const EdgeInsets.all(DogoSpacing.sm + 4),
      decoration: BoxDecoration(
        color: DogoColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: DogoColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.monitor_heart,
                color: DogoColors.onPrimary, size: 20),
          ),
          const SizedBox(width: DogoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Protocolo de Triaje DOGO Activo',
                  style: TextStyle(
                    color: DogoColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Los datos ingresados configurarán los umbrales de emergencia médica.',
                  style: TextStyle(
                    color: DogoColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _guardando ? null : _guardarYContinuar,
        style: ElevatedButton.styleFrom(
          backgroundColor: DogoColors.primary,
          disabledBackgroundColor:
              DogoColors.primary.withOpacity(0.5),
          foregroundColor: DogoColors.onPrimary,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _guardando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(DogoColors.onPrimary),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Guardar y Continuar al Triaje',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
