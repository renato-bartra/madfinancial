import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/entities/user.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          RegisterUser(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            dni: _dniController.text,
            email: email,
            password: _passwordController.text,
          ),
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado correctamente. Ahora inicia sesión.'),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login', arguments: email);
      return;
    }

    final error = ref.read(authControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'No se pudo crear el usuario.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear usuario'),
        actions: [
          TextButton(
            onPressed: state.isLoading
                ? null
                : () => Navigator.of(context).pushReplacementNamed('/login'),
            child: const Text('Login'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido a MadFinancial',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Primero crea tu usuario para poder iniciar sesión.',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  controller: _firstNameController,
                  label: 'Nombres',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: _requiredLetters,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _lastNameController,
                  label: 'Apellidos',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: _requiredLetters,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _dniController,
                  label: 'DNI',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!RegExp(r'^\d{8}$').hasMatch(text)) {
                      return 'El DNI debe tener 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!text.contains('@') || !text.contains('.')) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if ((value ?? '').length < 4) {
                      return 'La contraseña debe tener mínimo 4 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Crear usuario',
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredLetters(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Campo requerido';
    if (!RegExp(r'^[a-zA-Z áéíóúÁÉÍÓÚñÑäëïöüÄËÏÖÜ]+$').hasMatch(text)) {
      return 'Solo debe contener letras';
    }
    return null;
  }
}
