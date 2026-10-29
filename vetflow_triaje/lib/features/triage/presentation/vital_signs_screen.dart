/// Pantalla de captura de signos vitales.
///
/// Temperatura, frecuencia cardíaca, peso. Los campos vacíos se tratan
/// como faltantes y activan la regla de seguridad (no bajar de Urgencia).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/update_visit.dart';
import 'package:vetflow_triaje/features/triage/domain/model/vital_signs.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final _tempController = TextEditingController();
  final _hrController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;
  bool _hasMissingVitals = false;

  late final UpdateVisit _updateVisit = appDependencies.visitModule.updateVisit;

  String _getVisitId() {
    final state = GoRouterState.of(context);
    return state.uri.queryParameters['visitId'] ?? '';
  }

  @override
  void dispose() {
    _tempController.dispose();
    _hrController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);

    // Detectar si faltan signos vitales obligatorios
    _hasMissingVitals =
        _tempController.text.isEmpty ||
        _hrController.text.isEmpty ||
        _weightController.text.isEmpty;

    final visitId = _getVisitId();
    if (visitId.isEmpty) {
      _showSaveError(
        'No se encontró la visita. Vuelve a seleccionar la mascota.',
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final visitResult = await appDependencies.visitModule.visitRepository
        .findById(visitId);
    if (!mounted) return;
    final visit = visitResult.valueOrNull;
    if (visit == null) {
      _showSaveError(
        visitResult.errorOrNull?.message ?? 'No se pudo cargar la visita.',
      );
      setState(() => _isLoading = false);
      return;
    }

    final vitals = _getVitals();
    final updated = Visit(
      id: visit.id,
      petId: visit.petId,
      companyId: visit.companyId,
      redFlags: visit.redFlags,
      symptoms: visit.symptoms,
      vitals: {
        'tempC': vitals.tempC,
        'weightKg': vitals.weightKg,
        'heartRate': vitals.heartRate,
        'flags': vitals.flags,
      },
      photos: visit.photos,
      triage: visit.triage,
      status: visit.status,
      createdAt: visit.createdAt,
      updatedAt: DateTime.now(),
    );
    final saveResult = await _updateVisit(updated);
    if (!mounted) return;
    if (saveResult.valueOrNull == null) {
      _showSaveError(
        saveResult.errorOrNull?.message ??
            'No se pudieron guardar los signos vitales.',
      );
      setState(() => _isLoading = false);
      return;
    }

    context.go(
      Uri(
        path: '/triage/result',
        queryParameters: {'visitId': visitId},
      ).toString(),
    );
  }

  void _showSaveError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  VitalSigns _getVitals() {
    return VitalSigns(
      tempC: _tempController.text.isNotEmpty
          ? double.tryParse(_tempController.text)
          : null,
      heartRate: _hrController.text.isNotEmpty
          ? int.tryParse(_hrController.text)
          : null,
      weightKg: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Signos vitales'),
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
              'Signos vitales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa los valores actuales de tu mascota',
              style: TextStyle(fontSize: 14, color: kTextSecondaryColor),
            ),
            const SizedBox(height: 24),

            AppTextField(
              label: 'Temperatura (°C)',
              hint: '38.5',
              controller: _tempController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.thermostat,
            ),
            const SizedBox(height: 16),
            const Text(
              'Rango normal: 37.5 - 39.5 °C',
              style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
            ),
            const SizedBox(height: 24),

            AppTextField(
              label: 'Frecuencia cardíaca (lpm)',
              hint: '80',
              controller: _hrController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.favorite,
            ),
            const SizedBox(height: 16),
            const Text(
              'Rango normal: 60 - 140 lpm',
              style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
            ),
            const SizedBox(height: 24),

            AppTextField(
              label: 'Peso (kg)',
              hint: '12.5',
              controller: _weightController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.line_weight,
            ),
            const SizedBox(height: 16),
            const Text(
              'Rango normal: varía según especie y edad',
              style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
            ),
            const SizedBox(height: 32),

            InfoCard(
              icon: Icons.info_outline,
              title: '¿Qué pasa si no tengo todos los valores?',
              subtitle:
                  'Si faltan signos vitales obligatorios, el triaje no puede '
                  'bajar de Urgencia por seguridad.',
              color: kWarningColor,
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Continuar',
              onPressed: _isLoading ? null : () => _continue(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
