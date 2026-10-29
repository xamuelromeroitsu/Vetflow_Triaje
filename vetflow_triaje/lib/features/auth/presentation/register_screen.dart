/// Pantalla de registro de cuenta.
///
/// Conecta con el caso de uso `RegisterWithEmail` del dominio auth.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/auth/application/use_case/register_with_email.dart';
import 'package:vetflow_triaje/features/owners/application/use_case/register_owner.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  late final RegisterWithEmail _registerWithEmail =
      appDependencies.authModule.registerWithEmail;
  late final RegisterOwner _registerOwner =
      appDependencies.ownerModule.registerOwner;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResult = await _registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final appUser = authResult.valueOrNull;
      if (appUser == null) {
        setState(() {
          _errorMessage = authResult.errorOrNull?.message ??
              'No se pudo crear la cuenta';
        });
        return;
      }

      final ownerResult = await _registerOwner(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        ownerId: appUser.uid,
      );
      if (ownerResult.valueOrNull == null) {
        setState(() {
          _errorMessage = ownerResult.errorOrNull?.message ??
              'La cuenta se creó pero no se pudo registrar el propietario';
        });
        return;
      }

      if (mounted) {
        context.go('/pets');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo crear la cuenta. Intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimaryColor),
          onPressed: _goBack,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: kPrimaryColor),
              const SizedBox(height: 24),
              const Text(
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Regístrate para comenzar a usar VetFlow',
                style: TextStyle(
                  fontSize: 14,
                  color: kTextSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Nombre completo',
                      hint: 'Juan Pérez',
                      controller: _nameController,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Teléfono',
                      hint: '+52 55 1234 5678',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El teléfono es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email',
                      hint: 'tucorreo@ejemplo.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El email es obligatorio';
                        }
                        if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$')
                            .hasMatch(value)) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Contraseña',
                      hint: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
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
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Confirmar contraseña',
                      hint: '••••••••',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirma tu contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: (v) {},
                          activeColor: kPrimaryColor,
                        ),
                        const Expanded(
                          child: Text(
                            'Acepto los términos y condiciones',
                            style: TextStyle(
                              fontSize: 12,
                              color: kTextSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: kErrorColor),
                        ),
                      ),
                    PrimaryButton(
                      text: 'Crear Cuenta',
                      onPressed: _isLoading ? null : _register,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(color: kTextSecondaryColor),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
