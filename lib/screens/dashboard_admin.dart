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
      title: 'Администратор — ${auth.fullName ?? ""}',
      items: const [
        AdaptiveNavItem(Icons.inventory_2, 'Товары', '/admin/products'),
        AdaptiveNavItem(Icons.category, 'Категории', '/admin/categories'),
        AdaptiveNavItem(Icons.storefront, 'Бренды', '/admin/brands'),
        AdaptiveNavItem(Icons.local_shipping, 'Поставщики', '/admin/suppliers'),
        AdaptiveNavItem(Icons.people, 'Покупатели', '/admin/customers'),
        AdaptiveNavItem(Icons.receipt_long, 'Заказы', '/orders'),
        AdaptiveNavItem(Icons.rate_review, 'Отзывы', '/reviews/moderation'),
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

          _tile(
            context,
            icon: Icons.inventory_2,
            title: 'Товары',
            subtitle: 'Каталог, цены, остатки',
            route: '/admin/products',
          ),
          _tile(
            context,
            icon: Icons.category,
            title: 'Категории',
            subtitle: 'Классификация товаров',
            route: '/admin/categories',
          ),
          _tile(
            context,
            icon: Icons.storefront,
            title: 'Бренды',
            subtitle: 'Производители',
            route: '/admin/brands',
          ),
          _tile(
            context,
            icon: Icons.local_shipping,
            title: 'Поставщики',
            subtitle: 'Контрагенты, контакты',
            route: '/admin/suppliers',
          ),
          _tile(
            context,
            icon: Icons.people,
            title: 'Покупатели',
            subtitle: 'Профили клиентов',
            route: '/admin/customers',
          ),
          _tile(
            context,
            icon: Icons.receipt_long,
            title: 'Заказы',
            subtitle: 'Обработка, статусы, удаление',
            route: '/orders',
          ),
          _tile(
            context,
            icon: Icons.rate_review,
            title: 'Отзывы',
            subtitle: 'Модерация и удаление',
            route: '/reviews/moderation',
          ),
          _tile(
            context,
            icon: Icons.manage_accounts,
            title: 'Пользователи и роли',
            subtitle: 'Управление доступом',
            route: '/admin/users',
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(route),
      ),
    );
  }
}
