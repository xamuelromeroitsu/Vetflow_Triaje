/// Pantalla de resultado de triaje.
///
/// Muestra el nivel sugerido con color + ícono + texto (nunca solo color),
/// los motivos, y opciones para confirmar con veterinario o ver clínicas.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/evaluate_triage.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/update_visit.dart';
import 'package:vetflow_triaje/features/triage/domain/model/symptom_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/vital_signs.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class TriageResultScreen extends StatefulWidget {
  const TriageResultScreen({super.key, this.visitId});

  final String? visitId;

  @override
  State<TriageResultScreen> createState() => _TriageResultScreenState();
}

class _TriageResultScreenState extends State<TriageResultScreen> {
  TriageLevel? _suggestedLevel;
  List<String> _reasons = [];
  String _rulesVersion = '0.2';
  bool _isLoading = true;
  String? _errorMessage;

  late final EvaluateTriage _evaluateTriage =
      appDependencies.triageModule.evaluateTriage;
  late final UpdateVisit _updateVisit =
      appDependencies.visitModule.updateVisit;

  @override
  void initState() {
    super.initState();
    _loadAndEvaluate();
  }

  Future<void> _loadAndEvaluate() async {
    final visitId = widget.visitId ?? '';
    if (visitId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se encontró la visita';
      });
      return;
    }

    final visitResult = await appDependencies.visitModule.visitRepository.findById(visitId);
    if (!mounted) return;

    final visit = visitResult.valueOrNull;
    if (visit == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo cargar la visita';
      });
      return;
    }

    final symptomsMap = visit.symptoms;
    final vitalsMap = visit.vitals;
    final redFlags = visit.redFlags ?? {};

    final symptomEntries = <SymptomEntry>[];
    if (symptomsMap != null) {
      final items = (symptomsMap['items'] as List<dynamic>?)
          ?.cast<String>()
          .toList() ??
          [];
      final notes = (symptomsMap['notes'] as String?) ?? '';
      final since = (symptomsMap['since'] as String?) ?? '';
      final category = (symptomsMap['category'] as String?) ?? 'General';
      if (items.isNotEmpty) {
        symptomEntries.add(
          SymptomEntry(
            category: category,
            items: items,
            notes: notes.isEmpty ? null : notes,
            since: since.isEmpty ? null : since,
          ),
        );
      }
    }

    final vitals = VitalSigns(
      tempC: vitalsMap != null && vitalsMap['tempC'] is num
          ? (vitalsMap['tempC'] as num).toDouble()
          : null,
      heartRate: vitalsMap != null && vitalsMap['heartRate'] is int
          ? vitalsMap['heartRate'] as int
          : null,
      weightKg: vitalsMap != null && vitalsMap['weightKg'] is num
          ? (vitalsMap['weightKg'] as num).toDouble()
          : null,
      flags: vitalsMap != null && vitalsMap['flags'] is List
          ? List<String>.from(vitalsMap['flags'])
          : null,
    );

    final species = 'perro'; // TODO: obtener de la mascota asociada

    final result = _evaluateTriage.call(
      redFlags: Map<String, bool?>.from(redFlags),
      symptoms: symptomEntries,
      vitals: vitals,
      species: species,
      hasMissingVitals: vitals.tempC == null ||
          vitals.heartRate == null ||
          vitals.weightKg == null,
    );

    // Guardar resultado en la visita
    final updated = Visit(
      id: visit.id,
      petId: visit.petId,
      companyId: visit.companyId,
      redFlags: visit.redFlags,
      symptoms: visit.symptoms,
      vitals: visit.vitals,
      photos: visit.photos,
      triage: {
        'suggested': result.suggested.value.toString(),
        'confirmed': null,
        'reasons': result.reasons,
        'rulesVersion': result.rulesVersion,
      },
      status: visit.status,
      createdAt: visit.createdAt,
      updatedAt: DateTime.now(),
    );
    await _updateVisit(updated);
    if (!mounted) return;

    setState(() {
      _suggestedLevel = result.suggested;
      _reasons = result.reasons;
      _rulesVersion = result.rulesVersion;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: kErrorColor),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: kTextPrimaryColor),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Volver',
                onPressed: () => context.go('/pets'),
              ),
            ],
          ),
        ),
      );
    }

    final suggestedLevel = _suggestedLevel!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Resultado del triaje'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: triageLevelColor(suggestedLevel.name).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: triageLevelColor(suggestedLevel.name),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                TriageLevelIndicator(
                  level: suggestedLevel.name,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nivel sugerido: ${suggestedLevel.label}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: triageLevelColor(suggestedLevel.name),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  suggestedLevel.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Motivos de la evaluación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                ..._reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 14,
                              color: kTextPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Aviso importante: este resultado es una sugerencia '
                  'automatizada y no sustituye la evaluación de un '
                  'veterinario colegiado.',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                PrimaryButton(
                  text: 'Confirmar con veterinario',
                  onPressed: () => context.go(
                    '/triage/vet-confirmation?visitId=${widget.visitId ?? ''}',
                  ),
                  icon: Icons.medical_information,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Ver clínicas cercanas y cola',
                  onPressed: () => context.go('/queue'),
                  icon: Icons.local_hospital,
                ),
                const SizedBox(height: 12),
                if (suggestedLevel == TriageLevel.emergencia)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: kErrorColor,
                      side: const BorderSide(color: kErrorColor),
                    ),
                    onPressed: () => context.go('/emergency'),
                    icon: const Icon(Icons.phone),
                    label: const Text('Llamada de emergencia directa'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
