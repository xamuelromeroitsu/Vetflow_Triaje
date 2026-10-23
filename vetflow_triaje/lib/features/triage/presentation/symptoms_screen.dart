/// Pantalla de captura de síntomas.
///
/// El usuario selecciona síntomas por categoría y nivel de gravedad base.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/update_visit.dart';
import 'package:vetflow_triaje/features/triage/domain/model/symptom_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/symptom_rule.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class SymptomsScreen extends StatefulWidget {
  const SymptomsScreen({super.key});

  @override
  State<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  final List<SymptomEntry> _selectedSymptoms = [];
  final Map<String, List<String>> _symptomsByCategory = {
    'Respiratorio': [
      'Dificultad para respirar',
      'Tos persistente',
      'Estornudos frecuentes',
    ],
    'Digestivo': [
      'Vómito repetido',
      'Diarrea persistente',
      'Abdomen hinchado',
      'Falta de apetito',
    ],
    'Neurológico': [
      'Convulsiones',
      'Pérdida de conciencia',
      'Desorientación',
    ],
    'Urinario': [
      'No puede orinar',
      'Sangre en la orina',
      'Orina con frecuencia',
    ],
    'Movimiento': [
      'Cojera marcada',
      'Dificultad para caminar',
      'Parálisis parcial',
    ],
    'Piel': [
      'Herida abierta',
      'Picazón leve',
      'Erupción cutánea',
    ],
    'General': [
      'Fiebre',
      'Letargo',
      'Pérdida de peso',
      'Otros síntomas',
    ],
  };

  final Map<String, TriageLevel> _symptomLevels = {
    'Dificultad para respirar': TriageLevel.emergencia,
    'Convulsiones': TriageLevel.emergencia,
    'Pérdida de conciencia': TriageLevel.emergencia,
    'No puede orinar': TriageLevel.emergencia,
    'Vómito repetido': TriageLevel.urgencia,
    'Diarrea persistente': TriageLevel.urgencia,
    'Abdomen hinchado': TriageLevel.urgencia,
    'Cojera marcada': TriageLevel.urgencia,
    'Falta de apetito': TriageLevel.urgencia,
    'Fiebre': TriageLevel.urgencia,
    'Herida abierta': TriageLevel.urgencia,
    'Tos persistente': TriageLevel.consulta,
    'Estornudos frecuentes': TriageLevel.consulta,
    'Desorientación': TriageLevel.urgencia,
    'Sangre en la orina': TriageLevel.urgencia,
    'Orina con frecuencia': TriageLevel.consulta,
    'Dificultad para caminar': TriageLevel.urgencia,
    'Parálisis parcial': TriageLevel.emergencia,
    'Picazón leve': TriageLevel.consulta,
    'Erupción cutánea': TriageLevel.consulta,
    'Letargo': TriageLevel.consulta,
    'Pérdida de peso': TriageLevel.consulta,
    'Otros síntomas': TriageLevel.urgencia,
  };

  bool _isLoading = false;

  late final UpdateVisit _updateVisit =
      main.appDependencies.visitModule.updateVisit;

  String _getVisitId() {
    return GoRouter.of(context).state.queryParams['visitId'] ?? '';
  }

  void _toggleSymptom(String category, String item) {
    final entry = SymptomEntry(category: category, items: [item]);
    setState(() {
      final existingIndex = _selectedSymptoms.indexWhere(
        (e) => e.category == category && e.items.contains(item),
      );
      if (existingIndex >= 0) {
        _selectedSymptoms.removeAt(existingIndex);
      } else {
        _selectedSymptoms.add(entry);
      }
    });
  }

  bool _isSymptomSelected(String category, String item) {
    return _selectedSymptoms.any(
      (e) => e.category == category && e.items.contains(item),
    );
  }

  Future<void> _continue() async {
    if (_selectedSymptoms.isEmpty) return;

    setState(() => _isLoading = true);

    final visitId = _getVisitId();
    if (visitId.isNotEmpty) {
      final visitResult = await main.appDependencies.visitModule.visitRepository.findById(visitId);
      final visit = visitResult.valueOrNull;
      if (visit != null) {
        final updated = Visit(
          id: visit.id,
          petId: visit.petId,
          companyId: visit.companyId,
          redFlags: visit.redFlags,
          symptoms: {
            'category': _selectedSymptoms.first.category,
            'items': _selectedSymptoms.expand((e) => e.items).toList(),
            'notes': _selectedSymptoms.map((e) => e.notes).whereType<String>().toList().join('; '),
            'since': _selectedSymptoms.map((e) => e.since).whereType<String>().toList().join('; '),
          },
          vitals: visit.vitals,
          photos: visit.photos,
          triage: visit.triage,
          status: visit.status,
          createdAt: visit.createdAt,
          updatedAt: DateTime.now(),
        );
        await _updateVisit(updated);
      }
    }

    if (mounted) {
      context.go('/triage/red-flags?visitId=$visitId');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Síntomas'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _symptomsByCategory.length,
              itemBuilder: (context, index) {
                final category = _symptomsByCategory.keys.elementAt(index);
                final items = _symptomsByCategory[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimaryColor,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((item) {
                        final isSelected = _isSymptomSelected(category, item);
                        final level = _symptomLevels[item] ?? TriageLevel.consulta;
                        return FilterChip(
                          label: Text(item),
                          selected: isSelected,
                          onSelected: (_) => _toggleSymptom(category, item),
                          backgroundColor: kSurfaceColor,
                          selectedColor: triageLevelColor(level.value.toString())
                              .withValues(alpha: 0.2),
                          checkmarkColor: triageLevelColor(
                            level.value.toString(),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? triageLevelColor(level.value.toString())
                                : kTextPrimaryColor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? triageLevelColor(level.value.toString())
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
          if (_selectedSymptoms.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                border: Border(top: BorderSide(color: const Color(0xFFE5E7EB))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Síntomas seleccionados',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedSymptoms.map((e) {
                      return Chip(
                        label: Text('${e.category}: ${e.items.join(', ')}'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _toggleSymptom(e.category, e.items.first),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: _selectedSymptoms.isEmpty
                ? 'Selecciona al menos un síntoma'
                : 'Continuar',
            onPressed: _selectedSymptoms.isEmpty ? null : _continue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
