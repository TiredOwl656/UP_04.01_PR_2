import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/persistent_product_repository.dart';
import '../repositories/product_repository.dart';
import '../state/supplier_list_notifier.dart';
import '../widgets/state_views.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  bool _showDeleted = false;

  Future<void> _tryDelete(int id, String name) async {
    final productRepo = context.read<ProductRepository>();
    final notifier = context.read<SupplierListNotifier>();

    var linked = 0;
    if (productRepo is PersistentProductRepository) {
      linked = await productRepo.countBySupplier(id);
    }

    if (linked > 0) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(
            'На поставщика «$name» ссылаются товары: $linked шт.\n'
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
    final n = context.watch<SupplierListNotifier>();
    final items = _showDeleted
        ? n.items
        : n.items.where((s) => !s.isDeleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поставщики'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/suppliers/new'),
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
                  final s = items[i];
                  final deleted = s.isDeleted;
                  return ListTile(
                    title: Text(
                      s.name,
                      style: deleted
                          ? const TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                    subtitle: Text('${s.country} • ${s.email} • ${s.phone}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (deleted)
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: 'Восстановить',
                            onPressed: () => n.restore(s.id),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/suppliers/${s.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _tryDelete(s.id, s.name),
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