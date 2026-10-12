import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../state/auth_notifier.dart';
import '../validators/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _serverError = null;
    });

    try {
      await context.read<AuthNotifier>().register(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _fullName.text.trim(),
      );
      if (!mounted) return;
      context.go('/');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = _translateAuthError(e.message));
    } catch (e) {
      if (!mounted) return;
      setState(() => _serverError = 'Не удалось зарегистрироваться: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _translateAuthError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('already registered')) {
      return 'Этот email уже зарегистрирован';
    }
    if (lower.contains('password')) {
      return 'Пароль слишком простой (минимум 6 символов)';
    }
    return raw;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.length < 8) return 'Не короче 8 символов';
    if (!RegExp(r'\d').hasMatch(v)) return 'Нужна хотя бы одна цифра';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]').hasMatch(v)) {
      return 'Нужен специальный символ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: _fullName,
                  decoration: const InputDecoration(
                    labelText: 'ФИО',
                    border: OutlineInputBorder(),
                  ),
                  validator: V.compose([
                    V.required('ФИО'),
                    V.minLength(3, 'ФИО'),
                  ]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: V.compose([V.required('Email'), V.email()]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                    helperText: 'Минимум 8 символов, цифра и спецсимвол',
                  ),
                  validator: _validatePassword,
                ),
                if (_serverError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _serverError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Зарегистрироваться'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
