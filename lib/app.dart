import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';
import 'screens/audit_screen.dart';
import 'screens/brand_form_screen.dart';
import 'screens/brand_list_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/dashboard_admin.dart';
import 'screens/dashboard_customer.dart';
import 'screens/dashboard_manager.dart';
import 'screens/forbidden_screen.dart';
import 'screens/login_screen.dart';
import 'screens/loyalty_card_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reviews_moderation_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/supplier_list_screen.dart';
import 'screens/users_screen.dart';
import 'state/auth_notifier.dart';
import 'widgets/inactivity_watcher.dart';

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key});

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter(context.read<AuthNotifier>());
  }

  GoRouter _buildRouter(AuthNotifier auth) {
    return GoRouter(
      refreshListenable: auth,
      initialLocation: '/',
      redirect: (context, state) {
        final loggedIn = auth.isAuthenticated;
        final target = state.matchedLocation;
        final isPublic = target == '/login' || target == '/register';

        if (!loggedIn && !isPublic) {
          return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
        }
        if (loggedIn && isPublic) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (c, s) {
            final from = s.uri.queryParameters['from'];
            return LoginScreen(from: from);
          },
        ),
        GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),

        GoRoute(
          path: '/',
          builder: (c, s) {
            return switch (auth.user?.role) {
              null => const LoginScreen(),
              Role.customer => const CustomerDashboard(),
              Role.manager => const ManagerDashboard(),
              Role.admin => const AdminDashboard(),
            };
          },
        ),

        // Каталог — общий для всех залогиненных
        GoRoute(
          path: '/products',
          builder: (c, s) => const ProductListScreen(),
          redirect: (c, s) => auth.canBrowseCatalog ? null : '/login',
          routes: [
            GoRoute(
              path: ':id',
              builder: (c, s) => ProductDetailScreen(
                id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0,
              ),
            ),
          ],
        ),

        // Покупатель
        GoRoute(
          path: '/cart',
          builder: (c, s) => const CartScreen(),
          redirect: (c, s) => auth.canPlaceOrder ? null : '/forbidden',
        ),
        GoRoute(
          path: '/orders/my',
          builder: (c, s) => const MyOrdersScreen(),
          redirect: (c, s) => auth.canViewOwnOrders ? null : '/forbidden',
        ),
        GoRoute(
          path: '/loyalty',
          builder: (c, s) => const LoyaltyCardScreen(),
          redirect: (c, s) => auth.canUseLoyalty ? null : '/forbidden',
        ),

        // Менеджер
        GoRoute(
          path: '/orders',
          builder: (c, s) => const OrdersScreen(),
          redirect: (c, s) => auth.canViewAllOrders ? null : '/forbidden',
        ),
        GoRoute(
          path: '/reviews/moderation',
          builder: (c, s) => const ReviewsModerationScreen(),
          redirect: (c, s) => auth.canModerateReviews ? null : '/forbidden',
        ),

        // Админ — каталог
        GoRoute(
          path: '/admin/products',
          builder: (c, s) => const ProductListScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/products/new',
          builder: (c, s) => const ProductFormScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/products/:id/edit',
          builder: (c, s) => ProductFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/categories',
          builder: (c, s) => const CategoryListScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/categories/new',
          builder: (c, s) => const CategoryFormScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/categories/:id/edit',
          builder: (c, s) => CategoryFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/brands',
          builder: (c, s) => const BrandListScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/brands/new',
          builder: (c, s) => const BrandFormScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/brands/:id/edit',
          builder: (c, s) => BrandFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/suppliers',
          builder: (c, s) => const SupplierListScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/suppliers/new',
          builder: (c, s) => const SupplierFormScreen(),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/suppliers/:id/edit',
          builder: (c, s) => SupplierFormScreen(
            id: int.tryParse(s.pathParameters['id'] ?? ''),
          ),
          redirect: (c, s) => auth.canManageCatalog ? null : '/forbidden',
        ),

        // Админ — люди и лог
        GoRoute(
          path: '/admin/users',
          builder: (c, s) => const UsersScreen(),
          redirect: (c, s) => auth.canManageUsers ? null : '/forbidden',
        ),
        GoRoute(
          path: '/admin/audit',
          builder: (c, s) => const AuditScreen(),
          redirect: (c, s) => auth.canViewAudit ? null : '/forbidden',
        ),

        // Служебные
        GoRoute(
          path: '/forbidden',
          builder: (c, s) => const ForbiddenScreen(),
        ),
      ],
      errorBuilder: (c, s) => Scaffold(
        appBar: AppBar(title: const Text('Не найдено')),
        body: Center(child: Text('Маршрут не найден: ${s.uri}')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return MaterialApp.router(
      title: 'Магазин одежды',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: _router,
      builder: (context, child) {
        if (!auth.isAuthenticated) return child ?? const SizedBox.shrink();
        return InactivityWatcher(
          timeout: const Duration(minutes: 3),
          warningBefore: const Duration(seconds: 30),
          onTimeout: () {
            auth.logout();
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}