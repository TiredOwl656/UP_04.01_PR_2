import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../state/auth_notifier.dart';
import '../validators/validators.dart';

class LoginScreen extends StatefulWidget {
  final String? from;
  const LoginScreen({super.key, this.from});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _serverError = null;
    });

    try {
      await context.read<AuthNotifier>().login(
        _email.text.trim(),
        _password.text,
      );
      if (!mounted) return;
      final target = widget.from ?? '/';
      context.go(target);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = _translateAuthError(e.message));
    } catch (e) {
      if (!mounted) return;
      setState(() => _serverError = 'Не удалось войти: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _translateAuthError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login')) {
      return 'Неверный email или пароль';
    }
    if (lower.contains('email not confirmed')) {
      return 'Email не подтверждён. Проверьте почту.';
    }
    if (lower.contains('too many requests')) {
      return 'Слишком много попыток. Подождите минуту.';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
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
                const Icon(Icons.storefront, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Магазин одежды',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
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
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: V.required('Пароль'),
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
                FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: Text(_saving ? 'Вход…' : 'Войти'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Нет аккаунта? Зарегистрироваться'),
                ),
                const Divider(height: 32),
                const Text(
                  'Демо-аккаунты:',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'customer@shop.local / customer123!\n'
                  'manager@shop.local / manager123!\n'
                  'admin@shop.local / admin123!',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
