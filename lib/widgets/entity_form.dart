import 'package:flutter/material.dart';

/// Описание одного поля формы.
class FormFieldSpec {
  final String key;
  final String label;
  final String? initialValue;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int maxLines;

  const FormFieldSpec({
    required this.key,
    required this.label,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
  });
}

/// Универсальная форма: список полей + коллбэк отправки.
class EntityForm extends StatefulWidget {
  final String title;
  final List<FormFieldSpec> fields;
  final Widget? beforeFields;
  final Widget? afterFields;
  final Future<void> Function(Map<String, String> values) onSubmit;
  final String submitLabel;

  const EntityForm({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.beforeFields,
    this.afterFields,
    this.submitLabel = 'Сохранить',
  });

  @override
  State<EntityForm> createState() => _EntityFormState();
}

class _EntityFormState extends State<EntityForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  bool _dirty = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      _controllers[f.key] = TextEditingController(text: f.initialValue ?? '');
      _controllers[f.key]!.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Несохранённые изменения'),
        content: const Text('Уйти без сохранения?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Остаться'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Уйти'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final values = {
        for (final e in _controllers.entries) e.key: e.value.text.trim(),
      };
      await widget.onSubmit(values);
      _dirty = false;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.beforeFields != null) ...[
                widget.beforeFields!,
                const SizedBox(height: 16),
              ],
              for (final f in widget.fields) ...[
                TextFormField(
                  controller: _controllers[f.key],
                  decoration: InputDecoration(
                    labelText: f.label,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: f.keyboardType,
                  validator: f.validator,
                  obscureText: f.obscureText,
                  maxLines: f.maxLines,
                ),
                const SizedBox(height: 12),
              ],
              if (widget.afterFields != null) ...[
                widget.afterFields!,
                const SizedBox(height: 16),
              ],
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.submitLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}