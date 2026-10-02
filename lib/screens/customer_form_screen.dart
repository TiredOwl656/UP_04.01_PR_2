import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../models/loyalty_card.dart';
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
  bool _hasCard = false;
  final _cardNumberCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      final repo = context.read<CustomerRepository>();
      _existing = await repo.findById(widget.id!);
      if (_existing?.card != null) {
        _hasCard = true;
        _cardNumberCtrl.text = _existing!.card!.number;
        _bonusCtrl.text = _existing!.card!.bonusPoints.toString();
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _bonusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return EntityForm(
      title:
          widget.isEditing ? 'Редактирование покупателя' : 'Новый покупатель',
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
      afterFields: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Есть карта лояльности'),
            value: _hasCard,
            onChanged: (v) => setState(() => _hasCard = v ?? false),
          ),
          if (_hasCard) ...[
            TextFormField(
              controller: _cardNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Номер карты',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Номер карты обязателен'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bonusCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Бонусные баллы',
                border: OutlineInputBorder(),
              ),
              validator: V.intRange(0, 1000000, 'Баллы'),
            ),
          ],
        ],
      ),
      onSubmit: (values) async {
        final notifier = context.read<CustomerListNotifier>();
        final router = GoRouter.of(context);

        final customer = Customer(
          id: _existing?.id ?? 0,
          fullName: values['fullName']!,
          email: values['email']!,
          phone: values['phone']!,
          card: _hasCard
              ? LoyaltyCard(
                  number: _cardNumberCtrl.text.trim(),
                  bonusPoints: int.tryParse(_bonusCtrl.text.trim()) ?? 0,
                  issuedAt: _existing?.card?.issuedAt ?? DateTime.now(),
                )
              : null,
        );

        if (widget.isEditing) {
          await notifier.update(customer);
        } else {
          await notifier.create(customer);
        }
        if (!mounted) return;
        router.go('/customers');
      },
    );
  }
}