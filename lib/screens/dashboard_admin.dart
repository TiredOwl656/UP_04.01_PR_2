import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_notifier.dart';
import '../widgets/adaptive_scaffold.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return AdaptiveScaffold(
      title: 'Администратор — ${auth.user?.fullName ?? ""}',
      items: const [
        AdaptiveNavItem(Icons.inventory_2, 'Товары', '/admin/products'),
        AdaptiveNavItem(Icons.category, 'Категории', '/admin/categories'),
        AdaptiveNavItem(Icons.storefront, 'Бренды', '/admin/brands'),
        AdaptiveNavItem(Icons.manage_accounts, 'Пользователи', '/admin/users'),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Панель администратора',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Товары'),
              onTap: () => context.go('/admin/products'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Категории'),
              onTap: () => context.go('/admin/categories'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Бренды'),
              onTap: () => context.go('/admin/brands'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Поставщики'),
              onTap: () => context.go('/admin/suppliers'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Пользователи и роли'),
              onTap: () => context.go('/admin/users'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Журнал действий'),
              onTap: () => context.go('/admin/audit'),
            ),
          ),
        ],
      ),
    );
  }
}
