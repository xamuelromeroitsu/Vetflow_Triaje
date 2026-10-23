/// Pantalla de confirmación del veterinario.
///
/// El veterinario confirma o corrige el nivel sugerido.
/// Se guardan `suggested` y `confirmed` por separado en la Visita.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/update_visit.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_result.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class VetConfirmationScreen extends StatefulWidget {
  const VetConfirmationScreen({super.key});

  @override
  State<VetConfirmationScreen> createState() => _VetConfirmationScreenState();
}

class _VetConfirmationScreenState extends State<VetConfirmationScreen> {
  TriageLevel? _suggested;
  List<String> _reasons = [];
  TriageLevel? _confirmed;

  bool _isLoading = false;

  late final UpdateVisit _updateVisit =
      main.appDependencies.visitModule.updateVisit;

  String _getVisitId() {
    return GoRouter.of(context).state.queryParams['visitId'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadVisit();
  }

  Future<void> _loadVisit() async {
    final visitId = _getVisitId();
    if (visitId.isEmpty) return;

    final visitResult = await main.appDependencies.visitModule.visitRepository.findById(visitId);
    final visit = visitResult.valueOrNull;
    if (visit == null) return;

    final triageMap = visit.triage;
    if (triageMap != null) {
      final suggestedStr = triageMap['suggested'] as String?;
      if (suggestedStr != null) {
        _suggested = TriageLevel.values.firstWhere(
          (l) => l.value.toString() == suggestedStr,
          orElse: () => TriageLevel.consulta,
        );
      }
      final reasons = triageMap['reasons'];
      if (reasons is List) {
        _reasons = List<String>.from(reasons);
      }
    }

    setState(() {});
  }

  Future<void> _confirm() async {
    if (_confirmed == null || _suggested == null) return;

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
          symptoms: visit.symptoms,
          vitals: visit.vitals,
          photos: visit.photos,
          triage: {
            'suggested': _suggested!.value.toString(),
            'confirmed': _confirmed!.value.toString(),
            'reasons': _reasons,
            'rulesVersion': '0.2',
          },
          status: visit.status,
          createdAt: visit.createdAt,
          updatedAt: DateTime.now(),
        );
        await _updateVisit(updated);
      }
    }

    if (mounted) {
      context.go('/queue?visitId=$visitId');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_suggested == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Confirmación veterinaria'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmar nivel de triaje',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El veterinario revisa y confirma o corrige el nivel sugerido.',
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: kTextSecondaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Nivel sugerido (sistema)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TriageLevelIndicator(
                        level: _suggested!.value.toString(),
                        size: 56,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_suggested!.label}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: triageLevelColor(
                                  _suggested!.value.toString(),
                                ),
                              ),
                            ),
                            Text(
                              _suggested!.message,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Motivos del sistema:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kTextSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._reasons.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $r',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Nivel confirmado (veterinario)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...TriageLevel.values.map((level) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _confirmed = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _confirmed == level
                          ? triageLevelColor(level.value.toString())
                              .withValues(alpha: 0.15)
                          : kSurfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _confirmed == level
                            ? triageLevelColor(level.value.toString())
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _confirmed == level
                                ? triageLevelColor(level.value.toString())
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: triageLevelColor(level.value.toString()),
                            ),
                          ),
                          child: _confirmed == level
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    triageLevelIcon(level.value.toString()),
                                    size: 16,
                                    color: triageLevelColor(
                                      level.value.toString(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    level.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: triageLevelColor(
                                        level.value.toString(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                level.message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            if (_confirmed != null && _confirmed!.value < _suggested!.value)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kErrorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kErrorColor),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: kErrorColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Advertencia: el nivel confirmado es inferior al '
                        'sugerido. Esto no se recomienda por seguridad.',
                        style: TextStyle(
                          fontSize: 12,
                          color: kErrorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Guardar confirmación',
              onPressed: _confirmed == null || _isLoading ? null : _confirm,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: 'Saltar confirmación',
              onPressed: _isLoading
                  ? null
                  : () => context.go('/queue?visitId=${_getVisitId()}'),
            ),
          ],
        ),
      ),
    );
  }
}
