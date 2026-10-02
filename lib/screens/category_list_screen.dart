import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/persistent_product_repository.dart';
import '../repositories/product_repository.dart';
import '../state/category_list_notifier.dart';
import '../widgets/state_views.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  bool _showDeleted = false;

  Future<void> _tryDelete(int id, String name) async {
    final productRepo = context.read<ProductRepository>();
    final notifier = context.read<CategoryListNotifier>();

    var linked = 0;
    if (productRepo is PersistentProductRepository) {
      linked = await productRepo.countByCategory(id);
    }

    if (linked > 0) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(
            'На категорию «$name» ссылаются товары: $linked шт.\n'
            'Сначала удалите или переназначьте эти товары.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    await notifier.softDelete(id);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<CategoryListNotifier>();
    final items = _showDeleted
        ? n.items
        : n.items.where((c) => !c.isDeleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/categories/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text('Показывать удалённые'),
            value: _showDeleted,
            onChanged: (v) => setState(() => _showDeleted = v ?? false),
          ),
          const Divider(height: 1),
          Expanded(
            child: buildStateView(
              status: n.status,
              isEmpty: items.isEmpty,
              error: n.error,
              onRetry: n.load,
              onData: () => ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) {
                  final c = items[i];
                  final deleted = c.isDeleted;
                  return ListTile(
                    title: Text(
                      c.name,
                      style: deleted
                          ? const TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                    subtitle: Text(c.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (deleted)
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: 'Восстановить',
                            onPressed: () => n.restore(c.id),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/categories/${c.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _tryDelete(c.id, c.name),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}