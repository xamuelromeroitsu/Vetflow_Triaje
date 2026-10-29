/// Pantalla de registro de nueva mascota.
///
/// Diseñada según el mockup de Stitch DOGO y conectada al flujo real de
/// mascotas del backend del proyecto.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/register_pet.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme_clinical_mint.dart';

class PetRegisterScreen extends StatefulWidget {
  const PetRegisterScreen({super.key});

  @override
  State<PetRegisterScreen> createState() => _PetRegisterScreenState();
}

class _PetRegisterScreenState extends State<PetRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _historyController = TextEditingController();
  final _allergiesController = TextEditingController();

  bool _isClinicRole = false;
  String _selectedSpeciesValue = 'perro';
  String _selectedSex = 'Macho';
  bool _neutered = false;
  bool _isLoading = false;
  bool _showValidationMessage = false;

  late final RegisterPet _registerPetUseCase =
      appDependencies.petModule.registerPet;

  final List<_SpeciesOption> _speciesOptions = const [
    _SpeciesOption(label: 'Perro', value: 'perro', emoji: '🐶'),
    _SpeciesOption(label: 'Gato', value: 'gato', emoji: '🐱'),
    _SpeciesOption(label: 'Exótico', value: 'reptil', emoji: '🐾'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _historyController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _submitPet() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _showValidationMessage = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _showValidationMessage = false;
    });

    try {
      final ownerId = appDependencies.authModule.authRepository.currentAccount?.uid ??
          'local-demo-owner';
      final ageMonths = int.tryParse(_ageController.text.trim()) ?? 0;
      final weightKg = double.tryParse(_weightController.text.trim());

      final result = await _registerPetUseCase(
        name: _nameController.text.trim(),
        species: _selectedSpeciesValue,
        breed: _breedController.text.trim(),
        ageMonths: ageMonths,
        ownerId: ownerId,
        sex: _selectedSex,
        neutered: _neutered,
        weightKg: weightKg,
        history: _historyController.text.trim().isEmpty
            ? null
            : _historyController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
      );

      if (!mounted) return;

      final error = result.when(
        ok: (_) => null,
        failure: (domainError) => domainError,
      );
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: ClinicalMintColors.error,
          ),
        );
        return;
      }

      context.go('/triage/symptoms');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la mascota. Revisa tu conexión.'),
          backgroundColor: ClinicalMintColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ClinicalMintColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/pets');
                            }
                          },
                          icon: const Icon(Icons.arrow_back, size: 28),
                          splashRadius: 20,
                        ),
                        const Spacer(),
                        Text(
                          'DOGO',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: ClinicalMintColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.pets,
                          color: ClinicalMintColors.primary,
                          size: 26,
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: ClinicalMintColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: ClinicalMintColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isClinicRole = false),
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: !_isClinicRole
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Dueño',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: !_isClinicRole
                                          ? ClinicalMintColors.primary
                                          : ClinicalMintColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isClinicRole = true),
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _isClinicRole
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Personal clínico',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: _isClinicRole
                                          ? ClinicalMintColors.primary
                                          : ClinicalMintColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Registrar Nueva Mascota',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          'US-01',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: ClinicalMintColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ClinicalMintColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: ClinicalMintColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Paso 1 de 2: Datos Clínicos de la Mascota',
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                          Text(
                            '50%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: ClinicalMintColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: ClinicalMintColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ClinicalMintColors.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const Expanded(flex: 1, child: SizedBox()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: ClinicalMintColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: ClinicalMintColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Un peso y especie exactos son vitales para calcular los rangos de signos vitales e índices de alerta en el triaje de DOGO.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: ClinicalMintColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 128,
                            height: 128,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDAF5EA),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const Positioned.fill(
                                  child: Icon(
                                    Icons.pets,
                                    size: 60,
                                    color: ClinicalMintColors.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: ClinicalMintColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Foto del paciente (Opcional)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Nombre de la Mascota *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Ej. Rocky, Luna, Milo',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: ClinicalMintColors.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(
                          Icons.pets,
                          color: ClinicalMintColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Especie *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _speciesOptions.map((option) {
                        final selected = _selectedSpeciesValue == option.value;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSpeciesValue = option.value),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? ClinicalMintColors.primaryContainer
                                      : ClinicalMintColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(option.emoji, style: const TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Text(
                                      option.label,
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: selected
                                            ? Colors.white
                                            : ClinicalMintColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Raza *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _breedController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'La raza es obligatoria';
                        }
                        return null;
                      },
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Ej. Golden Retriever, Mestizo, Siames...',
                        prefixIcon: const Icon(
                          Icons.pets,
                          color: ClinicalMintColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edad *',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'La edad es obligatoria';
                                  }
                                  final parsed = int.tryParse(value!.trim());
                                  if (parsed == null || parsed < 0) {
                                    return 'Edad inválida';
                                  }
                                  return null;
                                },
                                style: theme.textTheme.bodyLarge,
                                decoration: const InputDecoration(
                                  hintText: '3',
                                  suffixText: 'Años',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Peso *',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'El peso es obligatorio';
                                  }
                                  final parsed = double.tryParse(value!.trim());
                                  if (parsed == null || parsed <= 0) {
                                    return 'Peso inválido';
                                  }
                                  return null;
                                },
                                style: theme.textTheme.bodyLarge,
                                decoration: const InputDecoration(
                                  hintText: '14.5',
                                  suffixText: 'Kg',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sexo y Reproducción *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Macho', 'Hembra'].map((sex) {
                        final selected = _selectedSex == sex;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSex = sex),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? ClinicalMintColors.primaryContainer
                                      : ClinicalMintColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    sex,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : ClinicalMintColors.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    CheckboxListTile(
                      value: _neutered,
                      onChanged: (value) => setState(() => _neutered = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Esterilizado / Castrado',
                        style: theme.textTheme.bodyLarge,
                      ),
                      activeColor: ClinicalMintColors.primaryContainer,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Condiciones Previas o Alergias',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _allergiesController,
                      maxLines: 2,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Ej. Alergia a cefalosporinas, soplo cardíaco Grado II, epilepsia diagnosticada...',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Historia clínica',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _historyController,
                      maxLines: 3,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Vacunas, consultas previas, eventos relevantes...',
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_showValidationMessage)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ClinicalMintColors.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Completa los datos obligatorios antes de continuar.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ClinicalMintColors.onErrorContainer,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ClinicalMintColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: ClinicalMintColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fact_check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Protocolo de Triaje DOGO activo. Los datos ingresados configurarán los umbrales para la siguiente fase.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submitPet,
                        style: FilledButton.styleFrom(
                          backgroundColor: ClinicalMintColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.save_alt),
                        label: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar y Continuar al Triaje'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeciesOption {
  const _SpeciesOption({
    required this.label,
    required this.value,
    required this.emoji,
  });

  final String label;
  final String value;
  final String emoji;
}
