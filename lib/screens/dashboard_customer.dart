import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_notifier.dart';
import '../widgets/adaptive_scaffold.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return AdaptiveScaffold(
      title: 'Магазин — ${auth.fullName ?? ""}',
      items: const [
        AdaptiveNavItem(Icons.store, 'Каталог', '/products'),
        AdaptiveNavItem(Icons.shopping_cart, 'Корзина', '/cart'),
        AdaptiveNavItem(Icons.receipt_long, 'Заказы', '/orders/my'),
        AdaptiveNavItem(Icons.card_giftcard, 'Карта', '/loyalty'),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Покупатель',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Каталог'),
              onTap: () => context.go('/products'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Корзина'),
              onTap: () => context.go('/cart'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Мои заказы'),
              onTap: () => context.go('/orders/my'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Карта лояльности'),
              onTap: () => context.go('/loyalty'),
            ),
          ),
        ],
      ),
    );
  }
}
