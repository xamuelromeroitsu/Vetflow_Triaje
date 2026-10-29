/// Pantalla de inicio de sesión - Clinical Mint design.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/sign_in_with_email.dart';
import 'package:vetflow_triaje/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme_clinical_mint.dart';

class LoginScreenClinicalMint extends StatefulWidget {
  const LoginScreenClinicalMint({super.key});

  @override
  State<LoginScreenClinicalMint> createState() =>
      _LoginScreenClinicalMintState();
}

class _LoginScreenClinicalMintState extends State<LoginScreenClinicalMint> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isOwner = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final SignInWithEmail _signInWithEmail = AppDependencies.create().authModule.signInWithEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final appUser = result.when(ok: (u) => u, failure: (_) => null);
      if (appUser == null) {
        final err = result.when(ok: (_) => null, failure: (e) => e);
        setState(() {
          _errorMessage = err?.message ?? 'No se pudo iniciar sesión';
        });
        return;
      }

      if (mounted) {
        context.go('/pets');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo iniciar sesión. Intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClinicalMintColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthHeader(),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: ClinicalMintColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D111827),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1551717743-49959800b1f6?q=80&w=200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64,
                              height: 64,
                              color: ClinicalMintColors.surfaceContainer,
                              child: const Icon(
                                Icons.pets,
                                color: ClinicalMintColors.primaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: ClinicalMintColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'RED ASISTENCIAL DOGO',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: ClinicalMintColors.primary,
                                          letterSpacing: 1.6,
                                        ),
                                  ),
                                ],
                              ),
                              Text(
                                'Atención y Triaje 24/7',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Conectado con clínicas veterinarias',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¡Hola de nuevo!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ingresa a tu cuenta para gestionar el cuidado y triaje de tus mascotas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  RoleSwitcher(
                    isOwner: _isOwner,
                    onChanged: (v) => setState(() => _isOwner = v),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: ClinicalMintColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D111827),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: ClinicalMintColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isOwner
                                ? 'Acceso a historial médico, citas y triaje rápido'
                                : 'Consola clínica: cola de pacientes, guardias y triaje de urgencias',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          label: 'Correo Electrónico',
                          hint: _isOwner
                              ? 'ejemplo@correo.com'
                              : 'dr.apellido@hospitaldogo.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El correo es obligatorio';
                            }
                            if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$')
                                .hasMatch(value)) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: 'Contraseña',
                          hint: 'Ingresa tu contraseña',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: ClinicalMintColors.secondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: ClinicalMintColors.primary,
                                  ),
                            ),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: ClinicalMintColors.error,
                                  ),
                            ),
                          ),
                        PrimaryActionButton(
                          text: 'Iniciar Sesión',
                          icon: Icons.arrow_forward,
                          onPressed: _signIn,
                          loading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: ClinicalMintColors.surfaceContainer,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'O CONTINÚA CON',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: ClinicalMintColors.surfaceContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SocialButton(
                    label: 'Continuar con Google',
                    onPressed: () {},
                    icon: const _GoogleIcon(),
                  ),
                  const SizedBox(height: 10),
                  _SocialButton(
                    label: 'Continuar con Apple',
                    onPressed: () {},
                    icon: const Icon(
                      Icons.apple,
                      size: 22,
                    ),
                    filled: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          'Regístrate aquí',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: ClinicalMintColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_clock,
                        size: 16,
                        color: ClinicalMintColors.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Conexión segura cifrada de punto a punto',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? ClinicalMintColors.inverseSurface
        : ClinicalMintColors.surfaceContainerLowest;
    final fg = filled ? ClinicalMintColors.inverseOnSurface : ClinicalMintColors.onSurface;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: fg,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _GooglePainter(),
      ),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, size.height * 0.4, size.width * 0.5, size.height * 0.35), paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.55, size.width * 0.48, size.height * 0.35), paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.48, size.height * 0.45), paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.52, 0, size.width * 0.48, size.height * 0.45), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
