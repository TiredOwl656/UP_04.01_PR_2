import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_notifier.dart';
import '../widgets/adaptive_scaffold.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return AdaptiveScaffold(
      title: 'Менеджер — ${auth.fullName ?? ""}',
      items: const [
        AdaptiveNavItem(Icons.store, 'Каталог', '/products'),
        AdaptiveNavItem(Icons.receipt_long, 'Заказы', '/orders'),
        AdaptiveNavItem(Icons.rate_review, 'Отзывы', '/reviews/moderation'),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Панель менеджера',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
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
