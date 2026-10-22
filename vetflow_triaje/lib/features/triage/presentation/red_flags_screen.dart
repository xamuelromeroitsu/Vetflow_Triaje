/// Pantalla de preguntas de descarte (red flags).
///
/// Un "sí" en cualquiera lleva directamente a Emergencia.
/// Una respuesta "no sé" sube el nivel mínimo a Urgencia.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/triage/domain/model/red_flag_rule.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class RedFlagsScreen extends StatefulWidget {
  const RedFlagsScreen({super.key});

  @override
  State<RedFlagsScreen> createState() => _RedFlagsScreenState();
}

class _RedFlagsScreenState extends State<RedFlagsScreen> {
  final List<RedFlagRule> _redFlags = [
    RedFlagRule(
      id: 'breathing',
      question: '¿Le cuesta respirar o respira con la boca abierta (gato)?',
      appliesTo: const [],
    ),
    RedFlagRule(
      id: 'seizures',
      question: '¿Tiene convulsiones o está inconsciente?',
      appliesTo: const [],
    ),
    RedFlagRule(
      id: 'bleeding',
      question: '¿Sangra sin parar?',
      appliesTo: const [],
    ),
    RedFlagRule(
      id: 'toxic',
      question: '¿Pudo haber ingerido veneno o un tóxico?',
      appliesTo: const [],
    ),
    RedFlagRule(
      id: 'trauma',
      question: '¿Sufrió un golpe fuerte o atropello?',
      appliesTo: const [],
    ),
    RedFlagRule(
      id: 'bloat',
      question: '¿Tiene el abdomen hinchado con arcadas sin vomitar?',
      appliesTo: const [],
    ),
    RedFlagRule(
      id: 'urinary_male_cat',
      question: '(Gato macho) ¿Intenta orinar y no puede?',
      appliesTo: const ['gato'],
    ),
  ];

  final Map<String, bool?> _answers = {};

  bool _isLoading = false;

  bool _hasPositive() => _answers.values.any((v) => v == true);

  int _getYesCount() => _answers.values.where((v) => v == true).length;

  int _getUnknownCount() => _answers.values.where((v) => v == null).length;

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      if (_hasPositive()) {
        context.go('/triage/result');
      } else {
        context.go('/triage/vitals');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Preguntas de descarte'),
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
              itemCount: _redFlags.length,
              itemBuilder: (context, index) {
                final rule = _redFlags[index];
                final answer = _answers[rule.id];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kErrorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.warning_amber,
                                color: kErrorColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rule.question,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kTextPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _OptionButton(
                                label: 'Sí',
                                isSelected: answer == true,
                                color: kErrorColor,
                                onTap: () =>
                                    setState(() => _answers[rule.id] = true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _OptionButton(
                                label: 'No',
                                isSelected: answer == false,
                                color: kSuccessColor,
                                onTap: () =>
                                    setState(() => _answers[rule.id] = false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _OptionButton(
                                label: 'No sé',
                                isSelected: answer == null,
                                color: kTextSecondaryColor,
                                onTap: () =>
                                    setState(() => _answers[rule.id] = null),
                              ),
                            ),
                          ],
                        ),
                        if (answer == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Esta respuesta indica Emergencia directa.',
                              style: TextStyle(
                                fontSize: 12,
                                color: kErrorColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (answer == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Respuesta "no sé": nivel mínimo Urgencia.',
                              style: TextStyle(
                                fontSize: 12,
                                color: kWarningColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Continuar',
            onPressed: _isLoading ? null : _continue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : kSurfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : kTextPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
