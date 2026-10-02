import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_category.dart';
import '../repositories/category_repository.dart';
import '../state/category_list_notifier.dart';
import '../validators/validators.dart';
import '../widgets/entity_form.dart';

class CategoryFormScreen extends StatefulWidget {
  final int? id;
  const CategoryFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  ProductCategory? _existing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      final repo = context.read<CategoryRepository>();
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
          ? 'Редактирование категории'
          : 'Новая категория',
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      fields: [
        FormFieldSpec(
          key: 'name',
          label: 'Название',
          initialValue: _existing?.name ?? '',
          validator: V.compose([
            V.required('Название'),
            V.minLength(2, 'Название'),
            V.maxLength(64, 'Название'),
          ]),
        ),
        FormFieldSpec(
          key: 'description',
          label: 'Описание',
          initialValue: _existing?.description ?? '',
          maxLines: 3,
          validator: V.maxLength(255, 'Описание'),
        ),
      ],
      onSubmit: (values) async {
        final notifier = context.read<CategoryListNotifier>();
        final router = GoRouter.of(context);
        final c = ProductCategory(
          id: _existing?.id ?? 0,
          name: values['name']!,
          description: values['description'] ?? '',
        );
        if (widget.isEditing) {
          await notifier.update(c);
        } else {
          await notifier.create(c);
        }
        if (!mounted) return;
        router.go('/categories');
      },
    );
  }
}