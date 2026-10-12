import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import '../state/customer_list_notifier.dart';
import '../validators/validators.dart';
import '../widgets/entity_form.dart';

class CustomerFormScreen extends StatefulWidget {
  final int? id;
  const CustomerFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  Customer? _existing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      _existing = await context.read<CustomerRepository>().findById(widget.id!);
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
          ? 'Редактирование покупателя'
          : 'Новый покупатель',
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      fields: [
        FormFieldSpec(
          key: 'fullName',
          label: 'ФИО',
          initialValue: _existing?.fullName ?? '',
          validator: V.compose([
            V.required('ФИО'),
            V.minLength(3, 'ФИО'),
            V.maxLength(120, 'ФИО'),
          ]),
        ),
        FormFieldSpec(
          key: 'email',
          label: 'Email',
          initialValue: _existing?.email ?? '',
          keyboardType: TextInputType.emailAddress,
          validator: V.compose([V.required('Email'), V.email()]),
        ),
        FormFieldSpec(
          key: 'phone',
          label: 'Телефон',
          initialValue: _existing?.phone ?? '',
          keyboardType: TextInputType.phone,
          validator: V.compose([V.required('Телефон'), V.phone()]),
        ),
      ],
      onSubmit: (values) async {
        final n = context.read<CustomerListNotifier>();
        final c = Customer(
          id: _existing?.id ?? 0,
          fullName: values['fullName']!,
          email: values['email']!,
          phone: values['phone']!,
        );
        if (widget.isEditing) {
          await n.update(c);
        } else {
          await n.create(c);
        }
        if (!mounted) return;
        context.go('/admin/customers');
      },
    );
  }
}
