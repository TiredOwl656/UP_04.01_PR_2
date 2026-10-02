import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/brand.dart';
import '../repositories/brand_repository.dart';
import '../validators/validators.dart';
import '../widgets/entity_form.dart';

class BrandFormScreen extends StatefulWidget {
  final int? id;
  const BrandFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<BrandFormScreen> createState() => _BrandFormScreenState();
}

class _BrandFormScreenState extends State<BrandFormScreen> {
  Brand? _existing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      final repo = context.read<BrandRepository>();
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
      title: widget.isEditing ? 'Редактирование бренда' : 'Новый бренд',
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      fields: [
        FormFieldSpec(
          key: 'name',
          label: 'Название бренда',
          initialValue: _existing?.name ?? '',
          validator: V.compose([
            V.required('Название'),
            V.minLength(2, 'Название'),
            V.maxLength(64, 'Название'),
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
          key: 'foundedYear',
          label: 'Год основания',
          initialValue: _existing?.foundedYear.toString() ?? '',
          keyboardType: TextInputType.number,
          validator: V.compose([
            V.required('Год основания'),
            V.year(),
          ]),
        ),
      ],
      onSubmit: (values) async {
        final repo = context.read<BrandRepository>();
        final router = GoRouter.of(context);
        final brand = Brand(
          id: _existing?.id ?? 0,
          name: values['name']!,
          country: values['country']!,
          foundedYear: int.tryParse(values['foundedYear']!) ?? 0,
        );
        if (widget.isEditing) {
          await repo.update(brand);
        } else {
          await repo.create(brand);
        }
        if (!mounted) return;
        router.go('/brands');
      },
    );
  }
}