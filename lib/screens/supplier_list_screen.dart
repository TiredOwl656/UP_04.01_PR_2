import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
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
    final notifier = context.read<SupplierListNotifier>();
    try {
      await notifier.softDelete(id);
    } on ConflictException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AlertDialog(
            title: const Text('Удаление невозможно'),
            content: Text(e.message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Понятно'),
              ),
            ],
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
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
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Добавить поставщика',
            onPressed: () => context.go('/suppliers/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Checkbox(
                  value: _showDeleted,
                  onChanged: (v) => setState(() => _showDeleted = v ?? false),
                ),
                const Text('Показывать удалённых'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: buildStateView(
              status: n.status,
              isEmpty: items.isEmpty,
              error: n.error,
              onRetry: n.load,
              onData: () => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final s = items[i];
                      final deleted = s.isDeleted;
                      return ListTile(
                        title: Text(
                          s.name,
                          overflow: TextOverflow.ellipsis,
                          style: deleted
                              ? const TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.lineThrough,
                                )
                              : null,
                        ),
                        subtitle: Text(
                          '${s.country} • ${s.email} • ${s.phone}',
                          overflow: TextOverflow.ellipsis,
                        ),
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
                                tooltip: 'Редактировать',
                                onPressed: () =>
                                    context.go('/suppliers/${s.id}/edit'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Удалить',
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
            ),
          ),
        ],
      ),
    );
  }
}
