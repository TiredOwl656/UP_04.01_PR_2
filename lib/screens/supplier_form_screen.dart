import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../state/supplier_list_notifier.dart';
import '../validators/validators.dart';
import '../widgets/entity_form.dart';

class SupplierFormScreen extends StatefulWidget {
  final int? id;
  const SupplierFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  Supplier? _existing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      final repo = context.read<SupplierRepository>();
      _existing = await repo.findById(widget.id!);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return EntityForm(
      title: widget.isEditing
          ? 'Редактирование поставщика'
          : 'Новый поставщик',
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      fields: [
        FormFieldSpec(
          key: 'name',
          label: 'Название',
          initialValue: _existing?.name ?? '',
          validator: V.compose([
            V.required('Название'),
            V.minLength(2, 'Название'),
            V.maxLength(120, 'Название'),
          ]),
        ),
        FormFieldSpec(
          key: 'country',
          label: 'Страна',
          initialValue: _existing?.country ?? '',
          validator: V.compose([
            V.required('Страна'),
            V.maxLength(64, 'Страна'),
          ]),
        ),
        FormFieldSpec(
          key: 'email',
          label: 'Email',
          initialValue: _existing?.email ?? '',
          keyboardType: TextInputType.emailAddress,
          validator: V.compose([
            V.required('Email'),
            V.email(),
          ]),
        ),
        FormFieldSpec(
          key: 'phone',
          label: 'Телефон',
          initialValue: _existing?.phone ?? '',
          keyboardType: TextInputType.phone,
          validator: V.compose([
            V.required('Телефон'),
            V.phone(),
          ]),
        ),
      ],
      onSubmit: (values) async {
        final notifier = context.read<SupplierListNotifier>();
        final router = GoRouter.of(context);
        final s = Supplier(
          id: _existing?.id ?? 0,
          name: values['name']!,
          country: values['country']!,
          email: values['email']!,
          phone: values['phone']!,
        );
        if (widget.isEditing) {
          await notifier.update(s);
        } else {
          await notifier.create(s);
        }
        if (!mounted) return;
        router.go('/suppliers');
      },
    );
  }
}