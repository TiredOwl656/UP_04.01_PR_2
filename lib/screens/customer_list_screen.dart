import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/customer_list_notifier.dart';
import '../widgets/state_views.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<CustomerListNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Покупатели'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/customers/new'),
          ),
        ],
      ),
      body: buildStateView(
        status: n.status,
        isEmpty: n.items.isEmpty,
        error: n.error,
        onRetry: n.load,
        onData: () => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: n.items.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) {
            final c = n.items[i];
            return ListTile(
              title: Text(c.fullName),
              subtitle: Text(
                '${c.email} • ${c.phone}'
                '${c.card != null ? " • карта ${c.card!.number} (${c.card!.bonusPoints} б.)" : ""}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/customers/${c.id}/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => n.softDelete(c.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}