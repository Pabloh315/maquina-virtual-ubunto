import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.of(context);
    final success = await state.login(_email.text, _password.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: 'Bienvenido a AutoCare',
      subtitle: 'El control de tu vehículo, en un solo lugar',
      showNavigation: false,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AUTOCARE',
                style: TextStyle(
                  fontSize: 33,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Tu mantenimiento bajo control',
                style: TextStyle(color: Color(0xFFC9DDFC), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ...[
          const Notice(
            'Modo demostración · Los cambios se guardan solo durante esta ejecución.',
          ),
          OutlinedButton(
            onPressed: state.busy
                ? null
                : () {
                    _email.text = 'demo@ejemplo.test';
                    _password.text = 'clave_demo';
                  },
            child: const Text('Usar cuenta de demostración'),
          ),
        ],
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FieldLabel('Correo electrónico'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                enabled: !state.busy,
                decoration: const InputDecoration(
                  hintText: 'usuario@correo.com',
                ),
                validator: (v) =>
                    v == null ||
                        !RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(v.trim())
                    ? 'Introduce un correo válido.'
                    : null,
              ),
              const FieldLabel('Contraseña'),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                enabled: !state.busy,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  suffixIcon: IconButton(
                    tooltip: _obscure
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Introduce tu contraseña.' : null,
                onFieldSubmitted: (_) {
                  if (!state.busy) _submit();
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showMessage(
                    context,
                    'La recuperación de contraseña se habilitará con el servicio de autenticación.',
                  ),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              if (state.error != null) Notice(state.error!, error: true),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: state.busy ? null : _submit,
                child: state.busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => showMessage(
                  context,
                  'El registro de cuentas se incorporará en la siguiente etapa. Puedes usar la cuenta de demostración.',
                ),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
