import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/brand_query.dart';
import 'models/product_query.dart';
import 'screens/brand_detail_screen.dart';
import 'screens/brand_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_list_screen.dart';
import 'state/brand_list_notifier.dart';
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
    GoRoute(
      path: '/products',
      builder: (context, state) {
        // Пункт 16: восстанавливаем условия отбора из адреса
        final q = ProductQuery.fromQueryParams(state.uri.queryParameters);
        final notifier = context.read<ProductListNotifier>();
        // Обновляем состояние без потери выделения
        if (q != notifier.query) {
          Future.microtask(() => notifier.applyQuery(q));
        }
        return const ProductListScreen();
      },
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ProductDetailScreen(id: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/brands',
      builder: (context, state) {
        final q = BrandQuery.fromQueryParams(state.uri.queryParameters);
        final notifier = context.read<BrandListNotifier>();
        if (q != notifier.query) {
          Future.microtask(() => notifier.applyQuery(q));
        }
        return const BrandListScreen();
      },
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return BrandDetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
);