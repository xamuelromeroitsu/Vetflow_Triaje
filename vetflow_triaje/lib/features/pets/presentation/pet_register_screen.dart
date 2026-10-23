/// Pantalla de registro de nueva mascota.
///
/// Captura nombre, especie, raza, edad, historial básico y relación owner->pet.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/register_pet.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

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

  String _selectedSpecies = 'perro';
  String? _selectedSex;
  bool? _neutered;
  bool _isLoading = false;

  late final RegisterPet _registerPet =
      main.appDependencies.petModule.registerPet;

  final List<String> _species = [
    'perro',
    'gato',
    'huron',
    'conejo',
    'ave',
    'roedor',
    'reptil',
  ];

  final List<String> _sexOptions = ['Macho', 'Hembra'];

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

  Future<void> _registerPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ageMonths = int.tryParse(_ageController.text) ?? 0;
      final weightKg = _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null;

      final account = main.appDependencies.authModule.authRepository.currentAccount;
      final ownerId = account?.uid ?? '';

      final result = await _registerPet(
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim(),
        ageMonths: ageMonths,
        ownerId: ownerId,
        sex: _selectedSex,
        neutered: _neutered,
        weightKg: weightKg,
        history: _historyController.text.isEmpty ? null : _historyController.text,
        allergies: _allergiesController.text.isEmpty ? null : _allergiesController.text,
      );

      final pet = result.valueOrNull;
      if (pet == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        context.go('/triage/symptoms');
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Registrar mascota'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos de tu mascota',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa la información para el triaje clínico',
                style: TextStyle(
                  fontSize: 14,
                  color: kTextSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),

              AppTextField(
                label: 'Nombre',
                hint: 'Max',
                controller: _nameController,
                prefixIcon: Icons.pets,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppDropdownField<String>(
                label: 'Especie',
                value: _selectedSpecies,
                hint: 'Selecciona una especie',
                items: _species
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s[0].toUpperCase() + s.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSpecies = v!),
                validator: (v) => v == null ? 'La especie es obligatoria' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Raza',
                hint: 'Golden Retriever',
                controller: _breedController,
                prefixIcon: Icons.category,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La raza es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Edad (meses)',
                      hint: '36',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_month,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La edad es obligatoria';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 0) {
                          return 'Edad inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sexo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kTextPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _sexOptions.map((sex) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(sex),
                                selected: _selectedSex == sex,
                                onSelected: (selected) =>
                                    setState(() => _selectedSex = sex),
                                selectedColor: kPrimaryColor.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: _selectedSex == sex
                                      ? kPrimaryColor
                                      : kTextSecondaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Peso (kg)',
                hint: '12.5',
                controller: _weightController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.monitor_weight,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Peso inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('¿Está esterilizado?'),
                      value: _neutered ?? false,
                      onChanged: (v) => setState(() => _neutered = v ?? false),
                      activeColor: kPrimaryColor,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Historial clínico (opcional)',
                hint: 'Antecedentes, cirugías, alergias previas',
                controller: _historyController,
                prefixIcon: Icons.medical_information,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Alergias (opcional)',
                hint: 'Medicamentos o alimentos',
                controller: _allergiesController,
                prefixIcon: Icons.warning,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Registrar mascota',
                onPressed: _isLoading ? null : _registerPet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
