import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/brand_query.dart';
import 'models/product_query.dart';
import 'screens/brand_detail_screen.dart';
import 'screens/brand_form_screen.dart';
import 'screens/brand_list_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/customer_form_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/supplier_list_screen.dart';
import 'state/brand_list_notifier.dart' show BrandListNotifier;
import 'state/product_list_notifier.dart';

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Магазин одежды',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/products',
  routes: [
    // ---------------- ТОВАРЫ ----------------
    GoRoute(
      path: '/products',
      builder: (context, state) {
        final q = ProductQuery.fromQueryParams(state.uri.queryParameters);
        final notifier = context.read<ProductListNotifier>();
        Future.microtask(() => notifier.applyQuery(q));
        return const ProductListScreen();
      },
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const ProductFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return ProductDetailScreen(id: id ?? 0);
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final id =
                    int.tryParse(state.pathParameters['id'] ?? '');
                return ProductFormScreen(id: id);
              },
            ),
          ],
        ),
      ],
    ),

    // ---------------- БРЕНДЫ ----------------
    GoRoute(
      path: '/brands',
      builder: (context, state) {
        final q = BrandQuery.fromQueryParams(state.uri.queryParameters);
        final notifier = context.read<BrandListNotifier>();
        Future.microtask(() => notifier.applyQuery(q));
        return const BrandListScreen();
      },
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const BrandFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id =
                int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return BrandDetailScreen(id: id);
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final id =
                    int.tryParse(state.pathParameters['id'] ?? '');
                return BrandFormScreen(id: id);
              },
            ),
          ],
        ),
      ],
    ),

    // ---------------- КАТЕГОРИИ ----------------
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoryListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const CategoryFormScreen(),
        ),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) {
            final id =
                int.tryParse(state.pathParameters['id'] ?? '');
            return CategoryFormScreen(id: id);
          },
        ),
      ],
    ),

    // ---------------- ПОСТАВЩИКИ ----------------
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => const SupplierListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const SupplierFormScreen(),
        ),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) {
            final id =
                int.tryParse(state.pathParameters['id'] ?? '');
            return SupplierFormScreen(id: id);
          },
        ),
      ],
    ),

    // ---------------- ПОКУПАТЕЛИ ----------------
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const CustomerFormScreen(),
        ),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) {
            final id =
                int.tryParse(state.pathParameters['id'] ?? '');
            return CustomerFormScreen(id: id);
          },
        ),
      ],
    ),
  ],
);