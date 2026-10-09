import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_notifier.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Менеджер — ${auth.user?.fullName ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await context.read<AuthNotifier>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Панель менеджера',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Каталог (просмотр)'),
              onTap: () => context.go('/products'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Заказы покупателей'),
              onTap: () => context.go('/orders'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Модерация отзывов'),
              onTap: () => context.go('/reviews/moderation'),
            ),
          ),
        ],
      ),
    );
  }
}