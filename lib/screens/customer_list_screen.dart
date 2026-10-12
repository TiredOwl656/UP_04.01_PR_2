import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../state/customer_list_notifier.dart';
import '../widgets/state_views.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  bool _showDeleted = false;

  Future<void> _tryDelete(int id) async {
    final n = context.read<CustomerListNotifier>();
    try {
      await n.softDelete(id);
    } on ConflictException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(e.message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
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
    final n = context.watch<CustomerListNotifier>();
    final items = _showDeleted
        ? n.items
        : n.items.where((c) => !c.isDeleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Покупатели'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Добавить покупателя',
            onPressed: () => context.go('/admin/customers/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text('Показывать удалённых'),
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
                      c.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: deleted
                          ? const TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                    subtitle: Text('${c.email} • ${c.phone}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (deleted)
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: () => n.restore(c.id),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/admin/customers/${c.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _tryDelete(c.id),
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
