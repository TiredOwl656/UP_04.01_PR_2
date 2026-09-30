import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/product_repository.dart';

class ProductDetailScreen extends StatelessWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProductRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка товара'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: FutureBuilder(
        future: repo.findById(id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) {
            return const Center(child: Text('Товар не найден'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _row('Артикул', p.sku),
              _row('Бренд ID', '${p.brandId}'),
              _row('Категории', p.categoryIds.join(', ')),
              _row('Размер', p.size),
              _row('Цвет', p.color),
              _row('Цена', '${p.price.toStringAsFixed(0)} ₽'),
              _row('Остаток', '${p.stock}'),
              _row('Год', '${p.year}'),
              if (p.isDeleted) const Text('Удалён', style: TextStyle(color: Colors.red)),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 140, child: Text(k, style: const TextStyle(color: Colors.grey))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}